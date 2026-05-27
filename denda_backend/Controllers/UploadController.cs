using Microsoft.AspNetCore.Mvc;

namespace DenDa_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UploadController : ControllerBase
    {
        private readonly IWebHostEnvironment _env;

        public UploadController(IWebHostEnvironment env)
        {
            _env = env;
        }

        [HttpPost("product-image")]
        public async Task<IActionResult> UploadProductImage(IFormFile file)
        {
            try
            {
                if (file == null || file.Length == 0)
                    return BadRequest("Không có file");

                var folderPath = Path.Combine(
                    _env.WebRootPath,
                    "uploads",
                    "products"
                );

                if (!Directory.Exists(folderPath))
                    Directory.CreateDirectory(folderPath);

                var fileName =
                    $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";

                var filePath = Path.Combine(folderPath, fileName);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                var imageUrl =
                    $"{Request.Scheme}://{Request.Host}/uploads/products/{fileName}";

                return Ok(new
                {
                    imageUrl
                });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpDelete("delete-image")]
        public IActionResult DeleteImage(string imageUrl)
        {
            try
            {
                var fileName = Path.GetFileName(imageUrl);

                var filePath = Path.Combine(
                    _env.WebRootPath,
                    "uploads",
                    "products",
                    fileName
                );

                if (System.IO.File.Exists(filePath))
                {
                    System.IO.File.Delete(filePath);
                }

                return Ok();
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
}