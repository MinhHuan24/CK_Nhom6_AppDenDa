using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using denda_backend.Models;

namespace denda_backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CategoryController : ControllerBase
    {
        private readonly DenDaDbContext _context;

        public CategoryController(DenDaDbContext context)
        {
            _context = context;
        }

        // GET: api/Category
        [HttpGet]
        public async Task<IActionResult> GetCategories()
        {
            try
            {
                var categories = await _context.Categories.ToListAsync();
                return Ok(categories);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi khi lấy danh mục: " + ex.Message });
            }
        }
    }
}