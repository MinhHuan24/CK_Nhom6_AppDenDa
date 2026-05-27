using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace denda_backend.Migrations
{
    /// <inheritdoc />
    public partial class AddOtpResetPassword : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "OtpExpiredAt",
                table: "Users",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ResetOtp",
                table: "Users",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "OtpExpiredAt", "ResetOtp" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "OtpExpiredAt", "ResetOtp" },
                values: new object[] { null, null });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "OtpExpiredAt",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "ResetOtp",
                table: "Users");
        }
    }
}
