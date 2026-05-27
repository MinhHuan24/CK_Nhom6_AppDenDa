namespace denda_backend.DTOs
{
    public class OrderReviewDto
    {
        public int OrderId { get; set; }
        public List<ProductReviewDto> Items { get; set; } = new();
    }

    public class ProductReviewDto
    {
        public int ProductId { get; set; }
        public int Rating { get; set; } // 1 - 5
        public string Comment { get; set; } = string.Empty;
    }
}