using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using denda_backend.DTOs;
using denda_backend.Models;
using System.IdentityModel.Tokens.Jwt;

namespace denda_backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReviewController : ControllerBase
    {
        private readonly DenDaDbContext
            _context;

        public ReviewController(
            DenDaDbContext context)
        {
            _context = context;
        }

        // ======================
        // THÊM REVIEW
        // ======================
        [Authorize]
        [HttpPost]
        public async Task<IActionResult>
            CreateReview(
            [FromBody]
            CreateReviewDto model)
        {
            try
            {
                var userIdStr =
                    User.FindFirst(
                        ClaimTypes.NameIdentifier)
                    ?.Value;

                if (string.IsNullOrEmpty(
                    userIdStr))
                {
                    return Unauthorized(
                        new
                        {
                            message =
                                "Không đọc được UserId từ token"
                        });
                }

                int userId =
                    int.Parse(userIdStr);

                var alreadyReviewed =
                    await _context
                    .ProductReviews
                    .AnyAsync(r =>
                        r.ProductId ==
                        model.ProductId &&
                        r.OrderId ==
                        model.OrderId &&
                        r.UserId ==
                        userId);

                if (alreadyReviewed)
                {
                    return BadRequest(
                        new
                        {
                            message =
                            "Bạn đã đánh giá sản phẩm này."
                        });
                }

                var review =
                    new ProductReview
                    {
                        ProductId =
                            model.ProductId,

                        UserId =
                            userId,

                        OrderId =
                            model.OrderId,

                        Rating =
                            model.Rating,

                        Comment =
                            model.Comment
                    };

                _context.ProductReviews
                    .Add(review);

                await _context
                    .SaveChangesAsync();

                return Ok(new
                {
                    message =
                    "Đánh giá thành công!"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500,
                    ex.Message);
            }
        }

        // ======================
        // GET REVIEW BY PRODUCT
        // ======================
        [HttpGet("{productId}")]
        public async Task<IActionResult>
            GetReviews(int productId)
        {
            var reviews =
                await _context
                .ProductReviews
                .Include(r => r.User)
                .Where(r =>
                    r.ProductId ==
                    productId)
                .OrderByDescending(r =>
                    r.CreatedAt)
                .Select(r => new
                {
                    userName =
                        r.User!.FullName,

                    rating =
                        r.Rating,

                    comment =
                        r.Comment,

                    createdAt =
                        r.CreatedAt
                })
                .ToListAsync();

            return Ok(reviews);
        }

        [Authorize]
        [HttpGet("check")]
        public async Task<IActionResult>
            CheckReviewed(
            int productId,
            int orderId)
        {
            var userIdStr =
                User.FindFirst(
                    ClaimTypes.NameIdentifier
                )?.Value;

            if (string.IsNullOrEmpty(
                userIdStr))
            {
                return Unauthorized();
            }

            int userId =
                int.Parse(userIdStr);

            var reviewed =
                await _context
                .ProductReviews
                .AnyAsync(r =>
                    r.ProductId ==
                    productId &&
                    r.OrderId ==
                    orderId &&
                    r.UserId ==
                    userId);

            return Ok(new
            {
                reviewed
            });
        }
    }
}