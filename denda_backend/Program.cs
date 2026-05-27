using System.Text;
using denda_backend.Helpers;
using denda_backend.Models;
using denda_backend.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Scalar.AspNetCore;
using System.IdentityModel.Tokens.Jwt;

JwtSecurityTokenHandler.DefaultInboundClaimTypeMap.Clear();

var builder = WebApplication.CreateBuilder(args);

// Cấu hình Database kết nối tới SQL Server
builder.Services.AddDbContext<DenDaDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection") ??
        "Server=DESKTOP-MM1MAIT\\SQLEXPRESS;Database=DenDaSignatureDb;Trusted_Connection=True;TrustServerCertificate=True;"
    ));

builder.Services.AddScoped<JwtHelper>();
builder.Services.AddScoped<AuthService>();

// Cấu hình hệ thống xác thực JWT Authentication
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings["SecretKey"] ?? "Chuoi_Bi_Mat_Cua_Den_Da_Signature_2026_Sieu_Dai_Va_Bao_Mat_Nhe_Ban";

var jwtKey = builder.Configuration["JwtSettings:SecretKey"];

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata =
        false;

    options.SaveToken = true;

    options.TokenValidationParameters =
        new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey =
                true,

            ValidIssuer =
                builder.Configuration[
                "JwtSettings:Issuer"],

            ValidAudience =
                builder.Configuration[
                "JwtSettings:Audience"],

            IssuerSigningKey =
                new SymmetricSecurityKey(
                    Encoding.UTF8.GetBytes(
                        jwtKey!
                    )
                ),

            ClockSkew =
                TimeSpan.Zero
        };

    options.Events =
        new JwtBearerEvents
        {
            OnAuthenticationFailed =
                context =>
                {
                    Console.WriteLine(
                        "JWT ERROR: " +
                        context.Exception
                        .Message);

                    return Task
                        .CompletedTask;
                },

            OnTokenValidated =
                context =>
                {
                    Console.WriteLine(
                        "TOKEN OK");

                    return Task
                        .CompletedTask;
                },

            OnChallenge =
                context =>
                {
                    Console.WriteLine(
                        "JWT CHALLENGE");

                    return Task
                        .CompletedTask;
                }
        };
});

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = null;
    });

builder.Services.AddOpenApi();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference();
}

app.UseStaticFiles();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();