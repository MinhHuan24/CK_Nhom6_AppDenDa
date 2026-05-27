using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using denda_backend.Models;

namespace denda_backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProductController : ControllerBase
    {
        private readonly DenDaDbContext _context;

        public ProductController(DenDaDbContext context)
        {
            _context = context;
        }

        // GET: api/Product  HOẶC  api/Product?categoryId=1
        [HttpGet]
        public async Task<IActionResult> GetProducts([FromQuery] int? categoryId)
        {
            try
            {
                var query = _context.Products.AsQueryable();

                // Nếu người dùng chọn tab danh mục cụ thể, tiến hành lọc
                if (categoryId.HasValue)
                {
                    query = query.Where(p => p.CategoryId == categoryId.Value);
                }

                var products = await query.ToListAsync();
                return Ok(products);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi khi lấy danh sách món: " + ex.Message });
            }
        }

        // GET: api/Product/search?keyword=tra
        [HttpGet("search")]
        public async Task<IActionResult> SearchProducts([FromQuery] string keyword)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(keyword))
                {
                    return Ok(new List<Product>());
                }

                keyword = keyword.Trim().ToLower();

                var products = await _context.Products
                    .Where(p =>
                        p.Name.ToLower().Contains(keyword) ||
                        (p.Description != null &&
                        p.Description.ToLower().Contains(keyword)))
                    .ToListAsync();

                return Ok(products);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = "Lỗi tìm kiếm món: " + ex.Message
                });
            }
        }
    }
}