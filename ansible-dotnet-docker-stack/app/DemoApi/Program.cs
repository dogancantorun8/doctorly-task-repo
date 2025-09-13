using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.AspNetCore.Http;
using Npgsql;
using MySqlConnector;

var builder = WebApplication.CreateBuilder(args);

// health endpoint
builder.Services.AddHealthChecks();

var app = builder.Build();

app.MapGet("/", () => new { ok = true, message = "Hello from .NET 8 Minimal API!" });

app.MapGet("/db-check", async (HttpContext ctx) =>
{
    // Check env var-style connection string; works with both Postgres and MySQL forms
    var connStr = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection") ?? "";
    if (string.IsNullOrWhiteSpace(connStr))
        return Results.BadRequest(new { ok = false, error = "No connection string set" });

    try
    {
        if (connStr.Contains("Host=") || connStr.Contains("Server=") && connStr.Contains("Port=5432"))
        {
            // Try Postgres if looks like Postgres
            await using var conn = new NpgsqlConnection(connStr);
            await conn.OpenAsync();
            await using var cmd = new NpgsqlCommand("SELECT 1", conn);
            var res = await cmd.ExecuteScalarAsync();
            return Results.Ok(new { ok = true, db = "postgres", result = res });
        }
        else if (connStr.Contains("Server=") || connStr.Contains("Port=3306"))
        {
            // Try MySQL otherwise
            await using var conn = new MySqlConnection(connStr);
            await conn.OpenAsync();
            await using var cmd = new MySqlCommand("SELECT 1", conn);
            var res = await cmd.ExecuteScalarAsync();
            return Results.Ok(new { ok = true, db = "mysql", result = res });
        }
        else
        {
            return Results.BadRequest(new { ok = false, error = "Unknown DB type in connection string" });
        }
    }
    catch (Exception ex)
    {
        return Results.Problem(ex.ToString());
    }
});

app.MapGet("/health", () => Results.Ok(new { status = "healthy" }));

app.Run();
