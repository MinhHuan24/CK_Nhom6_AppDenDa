using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace denda_backend.Models
{
    public class OrderDetail
    {
        [Key]
        public int Id { get; set; }
        [Required]
        public int OrderId { get; set; }
        [ForeignKey("OrderId")]
        public Order? Order { get; set; }

        [Required]
        public int ProductId { get; set; }
        [ForeignKey("ProductId")]
        public Product? Product { get; set; }

        public int Quantity { get; set; }
        public decimal PriceAtOrder { get; set; } // Giá món tại thời điểm đặt

        // Giải pháp Topping: Lưu chuỗi ID các Option đã chọn, ví dụ: "1,4" (Size L, Trân châu)
        public string SelectedOptions { get; set; } = string.Empty; 
    }
}