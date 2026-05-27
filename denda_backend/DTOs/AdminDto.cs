using System.Collections.Generic;

namespace denda_backend.DTOs
{
    public class DashboardStatsDto
    {
        public decimal TotalRevenue { get; set; }
        public int TotalOrders { get; set; }
        public List<RevenueByDateDto> RevenueChart { get; set; } = new();
        public List<TopProductDto> TopProducts { get; set; } = new();
    }

    public class RevenueByDateDto
    {
        public string Date { get; set; } = string.Empty;
        public decimal Revenue { get; set; }
    }

    public class TopProductDto
    {
        public string ProductName { get; set; } = string.Empty;
        public int QuantitySold { get; set; }
    }

    public class ProductSaveDto
    {
        public string Name { get; set; } = string.Empty;
        public decimal BasePrice { get; set; }
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }

        // CHUYỂN SANG ID
        public int CategoryId { get; set; }

        public bool IsAvailable { get; set; } = true;
    }

    public class OrderStatusUpdateDto
    {
        public string Status { get; set; } = string.Empty;
    }
}