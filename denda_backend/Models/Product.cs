using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace denda_backend.Models
{
    public class Product
    {
        [Key]
        public int Id { get; set; }
        [Required]
        [StringLength(150)]
        public string Name { get; set; } = string.Empty;
        public decimal BasePrice { get; set; } 
        public string? ImageUrl { get; set; }   
        public string? Description { get; set; }
        public bool IsAvailable { get; set; } = true;

        [Required]
        public int CategoryId { get; set; }
        [ForeignKey("CategoryId")]
        public Category? Category { get; set; }
    }
}