using Microsoft.EntityFrameworkCore;

namespace denda_backend.Models
{
    public class DenDaDbContext : DbContext
    {
        public DenDaDbContext(DbContextOptions<DenDaDbContext> options) : base(options) { }

        public DbSet<Category> Categories { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<Option> Options { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderDetail> OrderDetails { get; set; }

        public DbSet<ProductReview> ProductReviews { get; set; }
        public DbSet<Review> Reviews { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<User>().HasData(
                new User { Id = 1, Username = "admin", PasswordHash = "admin123", FullName = "Quản Trị Viên Đen Đá", Email = "admin@denda.com", Role = "Admin" },
                new User { Id = 2, Username = "user01", PasswordHash = "user123", FullName = "Khách Hàng Thân Thiết", Email = "user@gmail.com", Role = "User" }
            );
            modelBuilder.Entity<Product>()
                .Property(p => p.BasePrice)
                .HasColumnType("decimal(18,2)");

            modelBuilder.Entity<Option>()
                .Property(o => o.AdditionalPrice)
                .HasColumnType("decimal(18,2)");

            modelBuilder.Entity<Order>()
                .Property(o => o.TotalAmount)
                .HasColumnType("decimal(18,2)");

            modelBuilder.Entity<Order>()
                .Property(o => o.DiscountAmount)
                .HasColumnType("decimal(18,2)");

            modelBuilder.Entity<Order>()
                .Property(o => o.FinalAmount)
                .HasColumnType("decimal(18,2)");

            modelBuilder.Entity<OrderDetail>()
                .Property(od => od.PriceAtOrder)
                .HasColumnType("decimal(18,2)");
        }
    }
}