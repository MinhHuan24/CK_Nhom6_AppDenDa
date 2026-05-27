using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using denda_backend.Models;
using denda_backend.DTOs;

namespace denda_backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] 
    public class OrderController : ControllerBase
    {
        private readonly DenDaDbContext _context;

        public OrderController(DenDaDbContext context)
        {
            _context = context;
        }

        [HttpPost("checkout")]
        public async Task<IActionResult> Checkout([FromBody] OrderDto model)
        {
            if (model == null || model.OrderDetails == null || !model.OrderDetails.Any())
            {
                return BadRequest(new { message = "Giỏ hàng trống, không thể tạo đơn!" });
            }

            var userEmail = User.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value 
                ?? User.FindFirst("email")?.Value;

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == userEmail);
            if (user == null)
            {
                return Unauthorized(new { message = "Tài khoản không hợp lệ hoặc đã bị đăng xuất!" });
            }

            decimal totalInvoice = 0;
            foreach (var item in model.OrderDetails)
            {
                totalInvoice += item.Price * item.Quantity;
            }

            // ĐÃ SỬA: Lấy chính xác địa chỉ và phương thức thanh toán từ DTO Flutter gửi lên
            var newOrder = new Order
            {
                UserId = user.Id,
                OrderDate = DateTime.Now,
                TotalAmount = totalInvoice,
                DiscountAmount = 0,
                FinalAmount = totalInvoice,
                DeliveryAddress = model.OrderType == "Delivery" 
                    ? (!string.IsNullOrEmpty(model.DeliveryAddress) ? model.DeliveryAddress : "Giao hàng tận nơi") 
                    : "Nhận tại cửa hàng (Takeaway)",
                PaymentMethod = !string.IsNullOrEmpty(model.PaymentMethod) ? model.PaymentMethod : "COD", 
                Status = "Pending"    
            };

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                await _context.Orders.AddAsync(newOrder);
                await _context.SaveChangesAsync();
                foreach (var item in model.OrderDetails)
                {
                    var optionsList = new List<string>();
                    if (!string.IsNullOrEmpty(item.SizeName)) optionsList.Add($"Size: {item.SizeName}");
                    if (!string.IsNullOrEmpty(item.SugarName)) optionsList.Add($"Đường: {item.SugarName}");
                    if (!string.IsNullOrEmpty(item.IceName)) optionsList.Add($"Đá: {item.IceName}");
                    if (item.Toppings != null && item.Toppings.Any())
                    {
                        optionsList.Add($"Topping: {string.Join(", ", item.Toppings)}");
                    }
                    string fullOptionsString = string.Join(" | ", optionsList);
                    if (model.Note != null && !string.IsNullOrEmpty(model.Note))
                    {
                        fullOptionsString += $" [Ghi chú: {model.Note}]";
                    }

                    var detail = new OrderDetail
                    {
                        OrderId = newOrder.Id,
                        ProductId = item.ProductId,
                        Quantity = item.Quantity,
                        PriceAtOrder = item.Price, 
                        SelectedOptions = fullOptionsString 
                    };

                    await _context.OrderDetails.AddAsync(detail);
                }
                int earnedPoints = (int)(totalInvoice / 10000); 
                user.LoyaltyPoints = user.LoyaltyPoints + earnedPoints;

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return Ok(new { message = "Đặt đơn hàng Đen Đá thành công!", orderId = newOrder.Id });
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync(); 
                return StatusCode(500, new { message = "Lỗi hệ thống khi xử lý lưu đơn hàng: " + ex.Message });
            }
        }

        [HttpGet("user-orders")]
        public async Task<IActionResult> GetUserOrders()
        {
            var userEmail = User.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value 
                ?? User.FindFirst("email")?.Value;

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == userEmail);
            if (user == null)
            {
                return Unauthorized(new { message = "Tài khoản không hợp lệ!" });
            }
            var orders = await _context.Orders
                .Where(o => o.UserId == user.Id)
                .OrderByDescending(o => o.OrderDate)
                .Select(o => new {
                    id = o.Id,
                    orderDate = o.OrderDate,
                    totalAmount = o.TotalAmount,
                    discountAmount = o.DiscountAmount,
                    finalAmount = o.FinalAmount,
                    status = o.Status,
                    deliveryAddress = o.DeliveryAddress,
                    paymentMethod = o.PaymentMethod,
                    voucherCode = (string?)null, 
                    items = _context.OrderDetails
                        .Where(d => d.OrderId == o.Id)
                        .Select(d => new {
                            productId = d.ProductId,
                            productName = d.Product != null ? d.Product.Name : "Nước uống Đen Đá", 
                            imageUrl = d.Product != null ? d.Product.ImageUrl : "", 
                            quantity = d.Quantity,
                            price = d.PriceAtOrder,
                            selectedSize = d.SelectedOptions.Contains("Size: Size L") ? "L" : 
                                           d.SelectedOptions.Contains("Size: Size S") ? "S" : "M", 
                            toppingDescription = d.SelectedOptions ?? ""
                        }).ToList()
                })
                .ToListAsync();

            return Ok(orders);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetOrderDetail(int id)
        {
            var userEmail = User.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value 
                ?? User.FindFirst("email")?.Value;

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == userEmail);
            if (user == null)
            {
                return Unauthorized(new { message = "Tài khoản không hợp lệ!" });
            }

            var order = await _context.Orders
                .Where(o => o.Id == id && o.UserId == user.Id)
                .Select(o => new {
                    id = o.Id,
                    orderDate = o.OrderDate,
                    totalAmount = o.TotalAmount,
                    discountAmount = o.DiscountAmount,
                    finalAmount = o.FinalAmount,
                    status = o.Status,
                    deliveryAddress = o.DeliveryAddress,
                    paymentMethod = o.PaymentMethod,
                    items = _context.OrderDetails
                        .Where(d => d.OrderId == o.Id)
                        .Select(d => new {
                            productId = d.ProductId,
                            productName = d.Product != null ? d.Product.Name : "Nước uống Đen Đá", 
                            imageUrl = d.Product != null ? d.Product.ImageUrl : "", 
                            quantity = d.Quantity,
                            price = d.PriceAtOrder,
                            selectedSize = d.SelectedOptions.Contains("Size: Size L") ? "L" : 
                                           d.SelectedOptions.Contains("Size: Size S") ? "S" : "M", 
                            toppingDescription = d.SelectedOptions ?? ""
                        }).ToList()
                })
                .FirstOrDefaultAsync();

            if (order == null)
            {
                return NotFound(new { message = "Không tìm thấy chi tiết đơn hàng này!" });
            }

            return Ok(order);
        }

        [HttpPut("cancel/{id}")]
        public async Task<IActionResult> CancelOrder(int id)
        {
            var userEmail = User.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value 
                ?? User.FindFirst("email")?.Value;

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == userEmail);
            if (user == null)
            {
                return Unauthorized(new { message = "Tài khoản không hợp lệ!" });
            }

            var order = await _context.Orders.FirstOrDefaultAsync(o => o.Id == id && o.UserId == user.Id);
            if (order == null)
            {
                return NotFound(new { message = "Không tìm thấy đơn hàng này hệ thống!" });
            }

            if (!string.Equals(order.Status, "Pending", StringComparison.OrdinalIgnoreCase))
            {
                return BadRequest(new { 
                    message = "Không thể hủy đơn hàng! Đơn hàng của bạn đã được tiếp nhận, đang chuẩn bị món hoặc đang giao." 
                });
            }

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                order.Status = "Cancelled";
                int pointsToDeduct = (int)(order.FinalAmount / 10000);
                if (user.LoyaltyPoints >= pointsToDeduct)
                {
                    user.LoyaltyPoints -= pointsToDeduct;
                }
                else
                {
                    user.LoyaltyPoints = 0;
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return Ok(new { message = "Hủy đơn hàng thành công!", status = "Cancelled" });
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return StatusCode(500, new { message = "Lỗi hệ thống khi xử lý hủy đơn: " + ex.Message });
            }
        }
    }
}