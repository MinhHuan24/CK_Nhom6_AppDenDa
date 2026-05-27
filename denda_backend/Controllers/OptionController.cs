using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using denda_backend.Models;

namespace denda_backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OptionController : ControllerBase
    {
        private readonly DenDaDbContext _context;

        public OptionController(DenDaDbContext context)
        {
            _context = context;
        }

        // GET: api/Option
        [HttpGet]
        public async Task<IActionResult> GetOptions()
        {
            try
            {
                var options = await _context.Options.ToListAsync();
                
                // Nhóm dữ liệu lại theo Type (Size, Sugar, Ice, Topping) để Frontend nhận cho gọn
                var groupedOptions = options
                    .GroupBy(o => o.Type)
                    .ToDictionary(g => g.Key, g => g.ToList());

                return Ok(groupedOptions);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi khi lấy danh sách Option: " + ex.Message });
            }
        }
    }
}