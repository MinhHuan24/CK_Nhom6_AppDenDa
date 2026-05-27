using denda_backend.DTOs;
using denda_backend.Helpers;
using denda_backend.Models;
using Microsoft.EntityFrameworkCore;

namespace denda_backend.Services
{
    public class AuthService
    {
        private readonly DenDaDbContext _context;
        private readonly JwtHelper _jwtHelper;

        public AuthService(DenDaDbContext context, JwtHelper jwtHelper)
        {
            _context = context;
            _jwtHelper = jwtHelper;
        }

        public async Task<string?> LoginAsync(LoginDto loginDto)
        {
            // Tìm kiếm dựa trên Username mới cập nhật
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Username.ToLower() == loginDto.Username.ToLower());

            if (user == null) return null; 

            // Kiểm tra mật khẩu thô
            if (user.PasswordHash != loginDto.Password) return null; 

            // Cấp mã Token JWT
            return _jwtHelper.GenerateToken(user);
        }
    }
}