using System.ComponentModel.DataAnnotations;

namespace denda_backend.DTOs
{
    public class LoginDto
    {
        [Required]
        public string Username { get; set; } = string.Empty; 

        [Required]
        public string Password { get; set; } = string.Empty;
    }
}