public class CreateProductDto
{
    public string Name { get; set; } = string.Empty;

    public decimal BasePrice { get; set; }

    public string? Description { get; set; }

    public string? ImageUrl { get; set; }

    public bool IsAvailable { get; set; }

    public int CategoryId { get; set; }
}