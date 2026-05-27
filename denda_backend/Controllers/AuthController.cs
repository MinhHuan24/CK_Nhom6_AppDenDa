using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using denda_backend.Models; 
using denda_backend.DTOs;   
using Microsoft.AspNetCore.Authorization;

using MailKit.Net.Smtp;
using MimeKit;

namespace denda_backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly DenDaDbContext _context; 
        private readonly IConfiguration _config;
        private readonly IWebHostEnvironment _environment;

        public AuthController(DenDaDbContext context, IConfiguration config, IWebHostEnvironment environment)
        {
            _context = context;
            _config = config;
            _environment = environment;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto model)
        {
            if (model == null || string.IsNullOrEmpty(model.Email) || string.IsNullOrEmpty(model.Password))
            {
                return BadRequest(new { message = "Dữ liệu nhập vào không hợp lệ!" });
            }

            try
            {
                var isEmailExist = await _context.Users.AnyAsync(u => u.Email != null && u.Email.ToLower() == model.Email.ToLower());
                if (isEmailExist)
                {
                    return BadRequest(new { message = "Email này đã được đăng ký trên hệ thống." });
                }

                if (!string.IsNullOrEmpty(model.Username))
                {
                    var isUsernameExist = await _context.Users.AnyAsync(u => u.Username != null && u.Username.ToLower() == model.Username.ToLower());
                    if (isUsernameExist)
                    {
                        return BadRequest(new { message = "Tên đăng nhập này đã có người sử dụng." });
                    }
                }

                var newUser = new User
                {
                    Username = model.Username,
                    FullName = model.FullName,
                    Email = model.Email,
                    PasswordHash = model.Password, 
                    Role = "User",
                    LoyaltyPoints = 0
                };

                await _context.Users.AddAsync(newUser);
                await _context.SaveChangesAsync();

                return Ok(new { message = "Đăng ký tài khoản thành công!", username = model.Username });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống khi đăng ký: " + ex.Message });
            }
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto model)
        {
            if (model == null || string.IsNullOrEmpty(model.Username) || string.IsNullOrEmpty(model.Password))
            {
                return BadRequest(new { message = "Vui lòng nhập đầy đủ thông tin!" });
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == model.Username && u.PasswordHash == model.Password);
            if (user == null)
            {
                return Unauthorized(new { message = "Tài khoản hoặc mật khẩu không chính xác." });
            }

            var tokenHandler = new JwtSecurityTokenHandler();
            string jwtKey = _config["JwtSettings:SecretKey"] ?? "Chuoi_Bi_Mat_Cua_Den_Da_Signature_2026_Sieu_Dai_Va_Bao_Mat_Nhe_Ban";
            var key = Encoding.UTF8.GetBytes(jwtKey);
            
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[] 
                {
                    // 🔥 SỬ DỤNG CHUỖI "sub" ĐỂ LƯU ID - ĐỒNG BỘ TUYỆT ĐỐI KHÔNG BỊ .NET THAY ĐỔI TÊN KEY
                    new Claim("sub", user.Id.ToString()),
                    new Claim("email", user.Email ?? string.Empty),
                     new Claim(ClaimTypes.Role, user.Role ?? "User")
                }),
                Expires = DateTime.UtcNow.AddDays(7),
                Issuer = _config["JwtSettings:Issuer"],
                Audience = _config["JwtSettings:Audience"],
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return Ok(new { token = tokenHandler.WriteToken(token), message = "Đăng nhập thành công!" });
        }

        [HttpGet("profile")]
        [Authorize]
        public async Task<IActionResult> GetProfile()
        {
            var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdStr) || !int.TryParse(userIdStr, out int userId))
            {
                return Unauthorized(new { message = "Phiên làm việc hết hạn hoặc token không hợp lệ." });
            }

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return NotFound(new { message = "Không tìm thấy người dùng cá nhân." });
            }

            return Ok(new {
                name = user.FullName,
                email = user.Email,
                phone = user.Username, // Dùng Username đại diện cho SĐT hiển thị ra UI
                avatarUrl = user.AvatarUrl ?? ""
            });
        }

        [HttpPost("upload-avatar")]
        [Authorize] 
        public async Task<IActionResult> UploadAvatar(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest(new { success = false, message = "Tệp tin hình ảnh không hợp lệ." });

            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");
            if (!Directory.Exists(uploadsFolder))
            {
                Directory.CreateDirectory(uploadsFolder);
            }

            var uniqueFileName = Guid.NewGuid().ToString() + "_" + file.FileName;
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var fileStream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(fileStream);
            }

            var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdStr) || !int.TryParse(userIdStr, out int userId))
            {
                return Unauthorized(new { success = false, message = "Định danh người dùng thất bại." });
            }

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return NotFound(new { success = false, message = "Người dùng không tồn tại trên hệ thống dữ liệu." });
            }

            user.AvatarUrl = "/uploads/" + uniqueFileName;
            await _context.SaveChangesAsync(); 

            return Ok(new { 
                success = true, 
                message = "Cập nhật ảnh đại diện thành công!", 
                avatarUrl = user.AvatarUrl 
            });
        }

        [HttpPut("update-profile")]
        [Authorize]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileDto model)
        {
            if (model == null || string.IsNullOrEmpty(model.Name) || string.IsNullOrEmpty(model.Phone))
            {
                return BadRequest(new { success = false, message = "Dữ liệu cập nhật không được để trống!" });
            }

            var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdStr) || !int.TryParse(userIdStr, out int userId))
            {
                return Unauthorized(new { success = false, message = "Yêu cầu không được xác thực chính xác." });
            }

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return NotFound(new { success = false, message = "Tài khoản không tồn tại." });
            }

            user.FullName = model.Name;
            user.Username = model.Phone; // Ghi đè cập nhật vào trường Username theo model dữ liệu của bạn

            await _context.SaveChangesAsync();
            return Ok(new { success = true, message = "Cập nhật thông tin thành công!" });
        }

        [HttpGet("users")]
        public async Task<IActionResult> GetUsers()
        {
            var users = await _context.Users
                .Select(u => new { id = u.Id.ToString(), email = u.Email, role = new string[] { u.Role ?? "User" } })
                .ToListAsync();
                
            return Ok(users);
        }

        [HttpPost("update-role")]
        public async Task<IActionResult> UpdateRole([FromBody] UpdateRoleModel model)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == model.Email);
            if (user == null)
            {
                return NotFound(new { message = "Không tìm thấy người dùng!" });
            }

            user.Role = model.NewRole;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Cập nhật vai trò thành công!" });
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword(
            [FromBody] ForgotPasswordDto model)
        {
            try
            {
                var user = await _context.Users
                    .FirstOrDefaultAsync(
                        u => u.Email == model.Email);

                if (user == null)
                {
                    return BadRequest(new
                    {
                        message = "Email không tồn tại."
                    });
                }

                var otp = new Random()
                    .Next(100000, 999999)
                    .ToString();

                user.ResetOtp = otp;
                user.OtpExpiredAt =
                    DateTime.UtcNow.AddMinutes(5);

                await _context.SaveChangesAsync();

                var email = new MimeMessage();

                var senderEmail =
                    _config["EmailSettings:Email"];

                var senderPassword =
                    _config["EmailSettings:Password"];

                if (string.IsNullOrEmpty(senderEmail) ||
                    string.IsNullOrEmpty(senderPassword))
                {
                    return StatusCode(500, new
                    {
                        message = "Cấu hình EmailSettings chưa hợp lệ."
                    });
                }

                email.From.Add(
                    MailboxAddress.Parse(senderEmail));

                email.To.Add(
                    MailboxAddress.Parse(model.Email!));

                email.Subject =
                    "Khôi phục mật khẩu Đen Đá Signature";

                email.Body = new TextPart("plain")
                {
                    Text =
                $@"Xin chào!

                Mã OTP khôi phục mật khẩu của bạn là:

                {otp}

                Mã OTP có hiệu lực trong 5 phút.

                Đen Đá Signature"
                };

                using var smtp = new SmtpClient();

                await smtp.ConnectAsync(
                    "smtp.gmail.com",
                    587,
                    false);

                await smtp.AuthenticateAsync(
                    senderEmail,
                    senderPassword);

                await smtp.SendAsync(email);

                await smtp.DisconnectAsync(true);

                return Ok(new
                {
                    message = "Đã gửi OTP."
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = ex.Message
                });
            }
        }

        [HttpPost("verify-otp")]
        public async Task<IActionResult> VerifyOtp(
            [FromBody] VerifyOtpDto model)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(
                    u => u.Email == model.Email);

            if (user == null)
            {
                return BadRequest(new
                {
                    message = "Không tìm thấy email."
                });
            }

            if (user.ResetOtp != model.Otp)
            {
                return BadRequest(new
                {
                    message = "OTP không đúng."
                });
            }

            if (user.OtpExpiredAt < DateTime.UtcNow)
            {
                return BadRequest(new
                {
                    message = "OTP đã hết hạn."
                });
            }

            return Ok(new
            {
                message = "OTP hợp lệ."
            });
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword(
            [FromBody] ResetPasswordDto model)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(
                    u => u.Email == model.Email);

            if (user == null)
            {
                return BadRequest(new
                {
                    message = "Không tìm thấy user."
                });
            }

            user.PasswordHash =
                model.NewPassword;

            user.ResetOtp = null;
            user.OtpExpiredAt = null;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message =
                    "Đổi mật khẩu thành công."
            });
        }
        public class UpdateRoleModel
        {
            public string Email { get; set; } = string.Empty;
            public string NewRole { get; set; } = string.Empty;
        }

        // Lớp đối tượng DTO nhận yêu cầu cập nhật thông tin chữ
        public class UpdateProfileDto
        {
            public string Name { get; set; } = string.Empty;
            public string Phone { get; set; } = string.Empty;
        }
    }
}