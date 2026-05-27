using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace denda_backend.Models
{
    public class ProductReview
    {
        [Key]
        public int Id { get; set; }

        public int ProductId { get; set; }

        [ForeignKey("ProductId")]
        public Product? Product { get; set; }

        public int UserId { get; set; }

        [ForeignKey("UserId")]
        public User? User { get; set; }

        public int OrderId { get; set; }

        public int Rating { get; set; } // 1 -> 5

        public string Comment { get; set; } =
            string.Empty;

        public DateTime CreatedAt { get; set; } =
            DateTime.Now;
    }
}