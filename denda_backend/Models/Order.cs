using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace denda_backend.Models
{
    public class Order
    {
        [Key]
        public int Id { get; set; }
        [Required]
        public int UserId { get; set; }
        [ForeignKey("UserId")]
        public User? User { get; set; }

        public DateTime OrderDate { get; set; } = DateTime.UtcNow;
        public decimal TotalAmount { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal FinalAmount { get; set; }
        
        [StringLength(250)]
        public string DeliveryAddress { get; set; } = string.Empty;
        [StringLength(50)]
        public string PaymentMethod { get; set; } = "COD"; // COD, MoMo, VNPAY
        [StringLength(50)]
        public string Status { get; set; } = "Pending"; // Pending, Preparing, Shipping, Completed, Cancelled
    }
}