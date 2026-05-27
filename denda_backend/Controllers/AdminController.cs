using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.StaticFiles;
using denda_backend.Models;
using denda_backend.DTOs;

namespace denda_backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class AdminController : ControllerBase
    {
        private readonly DenDaDbContext _context;

        public AdminController(DenDaDbContext context)
        {
            _context = context;
        }

        [HttpGet("dashboard-stats")]
        public async Task<IActionResult> GetDashboardStats()
        {
            try
            {
                var completedOrders = _context.Orders
                    .Where(o => o.Status == "Completed");

                decimal totalRevenue =
                    await completedOrders.SumAsync(o => o.FinalAmount);

                int totalOrdersCount =
                    await _context.Orders.CountAsync();

                var sevenDaysAgo = DateTime.UtcNow.AddDays(-7);

                var data = await _context.Orders
                    .Where(o => o.Status == "Completed")
                    .Where(o => o.OrderDate >= sevenDaysAgo)
                    .GroupBy(o => o.OrderDate.Date)
                    .Select(g => new
                    {
                        Date = g.Key,
                        Revenue = g.Sum(x => x.FinalAmount)
                    })
                    .ToListAsync();

                var result = data.Select(x => new RevenueByDateDto
                {
                    Date = x.Date.ToString("dd/MM"),
                    Revenue = x.Revenue
                }).ToList();

                var topProducts = await _context.OrderDetails
                    .Include(od => od.Product)
                    .GroupBy(od => od.Product!.Name)
                    .Select(g => new TopProductDto
                    {
                        ProductName = g.Key,
                        QuantitySold = g.Sum(od => od.Quantity)
                    })
                    .OrderByDescending(p => p.QuantitySold)
                    .Take(5)
                    .ToListAsync();

                return Ok(new DashboardStatsDto
                {
                    TotalRevenue = totalRevenue,
                    TotalOrders = totalOrdersCount,
                    RevenueChart = result,
                    TopProducts = topProducts
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = "Lỗi hệ thống: " + ex.Message
                });
            }
        }

        [HttpGet("products")]
        public async Task<IActionResult> GetAllProducts()
        {
            var products = await _context.Products
                .Include(p => p.Category)
                .Select(p => new
                {
                    p.Id,
                    p.Name,
                    p.BasePrice,
                    p.Description,
                    p.ImageUrl,
                    p.CategoryId,
                    Category = p.Category != null
                        ? p.Category.Name
                        : "",
                    p.IsAvailable
                })
                .ToListAsync();

            var categories = await _context.Categories
                .Select(c => new
                {
                    c.Id,
                    c.Name
                })
                .ToListAsync();

            return Ok(new
            {
                products,
                categories
            });
        }

        [HttpPost("products")]
        public async Task<IActionResult> CreateProduct(
            [FromBody] ProductSaveDto model)
        {
            var category = await _context.Categories
                .FirstOrDefaultAsync(c => c.Id == model.CategoryId);

            if (category == null)
            {
                return BadRequest(new
                {
                    success = false,
                    message = "Danh mục không tồn tại!"
                });
            }

            var product = new Product
            {
                Name = model.Name,
                BasePrice = model.BasePrice,
                Description = model.Description,
                ImageUrl = model.ImageUrl,
                CategoryId = model.CategoryId,
                IsAvailable = model.IsAvailable
            };

            await _context.Products.AddAsync(product);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = "Thêm món thành công!"
            });
        }

        [HttpPut("products/{id}")]
        public async Task<IActionResult> UpdateProduct(int id,[FromBody] ProductSaveDto model)
        {
            var product = await _context.Products.FindAsync(id);

            if (product == null)
            {
                return NotFound(new
                {
                    success = false,
                    message = "Không tìm thấy sản phẩm"
                });
            }

            var category = await _context.Categories
                .FirstOrDefaultAsync(c => c.Id == model.CategoryId);

            if (category == null)
            {
                return BadRequest(new
                {
                    success = false,
                    message = "Danh mục không tồn tại"
                });
            }

            product.Name = model.Name;
            product.BasePrice = model.BasePrice;
            product.Description = model.Description;
            product.ImageUrl = model.ImageUrl;
            product.CategoryId = model.CategoryId;
            product.IsAvailable = model.IsAvailable;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = "Cập nhật thành công!"
            });
        }

        [HttpPatch("products/{id}/toggle-availability")]
        public async Task<IActionResult> ToggleAvailability(int id)
        {
            var product = await _context.Products.FindAsync(id);

            if (product == null)
            {
                return NotFound(new
                {
                    success = false,
                    message = "Không tìm thấy sản phẩm"
                });
            }

            product.IsAvailable = !product.IsAvailable;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                isAvailable = product.IsAvailable
            });
        }

        [HttpDelete("products/{id}")]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            var product = await _context.Products.FindAsync(id);

            if (product == null)
            {
                return NotFound(new
                {
                    success = false,
                    message = "Không tìm thấy món"
                });
            }

            _context.Products.Remove(product);

            await _context.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = "Xóa món thành công!"
            });
        }

        [HttpGet("orders")]
        public async Task<IActionResult> GetAllOrders()
        {
            var orders = await _context.Orders
                .Include(o => o.User)
                .OrderByDescending(o => o.OrderDate)
                .Select(o => new
                {
                    o.Id,
                    CustomerName = o.User != null
                        ? o.User.FullName
                        : "Khách vãng lai",

                    CustomerPhone = o.User != null
                        ? o.User.Username
                        : "",

                    o.OrderDate,
                    o.FinalAmount,
                    o.Status,
                    o.DeliveryAddress,
                    o.PaymentMethod
                })
                .ToListAsync();

            return Ok(orders);
        }

        [HttpPut("orders/{id}/status")]
        public async Task<IActionResult> UpdateOrderStatus(int id,[FromBody] OrderStatusUpdateDto model)
        {
            var order = await _context.Orders.FindAsync(id);

            if (order == null)
            {
                return NotFound(new
                {
                    message = "Không tìm thấy đơn hàng"
                });
            }

            order.Status = model.Status;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = "Cập nhật trạng thái thành công!"
            });
        }
    
        [HttpPost("upload-image")]
        public async Task<IActionResult> UploadImage(IFormFile file)
        {
            try
            {
                if (file == null || file.Length == 0)
                {
                    return BadRequest(new
                    {
                        success = false,
                        message = "Không có file được upload"
                    });
                }

                var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");

                if (!Directory.Exists(uploadsFolder))
                {
                    Directory.CreateDirectory(uploadsFolder);
                }

                var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";

                var filePath = Path.Combine(uploadsFolder, fileName);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                var imageUrl = $"http://10.0.2.2:5019/uploads/{fileName}";

                return Ok(new
                {
                    success = true,
                    imageUrl
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = ex.Message
                });
            }
        }
    }
}