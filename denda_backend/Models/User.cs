using System.ComponentModel.DataAnnotations;

namespace denda_backend.Models
{
    public class User
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(50)]
        public string Username { get; set; } = string.Empty;

        [Required]
        public string PasswordHash { get; set; } = string.Empty;

        [StringLength(100)]
        public string FullName { get; set; } = string.Empty;

        public string? Email { get; set; }

        [Required]
        public string Role { get; set; } = "User";

        public int LoyaltyPoints { get; set; } = 0;

        public string? AvatarUrl { get; set; }

        // OTP RESET PASSWORD
        public string? ResetOtp { get; set; }

        public DateTime? OtpExpiredAt { get; set; }
    }
}