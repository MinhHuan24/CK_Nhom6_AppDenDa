using System.ComponentModel.DataAnnotations;

public class ResetPasswordDto
{
    [Required]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string NewPassword { get; set; } = string.Empty;
}