namespace denda_backend.DTOs
{
    public class OrderDto
    {
        public string OrderType { get; set; } = "Takeaway"; 
        public string? Note { get; set; }
        
        public string? DeliveryAddress { get; set; } 
        public string? PaymentMethod { get; set; }
        
        public List<OrderDetailDto> OrderDetails { get; set; } = new();
    }

    public class OrderDetailDto
    {
        public int ProductId { get; set; }
        public string? SizeName { get; set; }
        public string? SugarName { get; set; }
        public string? IceName { get; set; }
        public List<string> Toppings { get; set; } = new();
        public int Quantity { get; set; }
        public decimal Price { get; set; } 
    }
}