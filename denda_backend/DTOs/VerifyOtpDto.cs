using System.ComponentModel.DataAnnotations;

public class VerifyOtpDto
{
    [Required]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string Otp { get; set; } = string.Empty;
}