using System.ComponentModel.DataAnnotations;

namespace denda_backend.Models
{
    public class Option
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(50)]
        public string Type { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;

        public decimal AdditionalPrice { get; set; }
    }
}