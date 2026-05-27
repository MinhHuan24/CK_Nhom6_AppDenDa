namespace denda_backend.DTOs
{
    public class CreateReviewDto
    {
        public int ProductId { get; set; }

        public int OrderId { get; set; }

        public int Rating { get; set; }

        public string Comment { get; set; } =
            string.Empty;
    }
}