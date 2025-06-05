using OpenTelemetry.Metrics;
using OpenTelemetry.Trace;
using OpenTelemetry.Resources;
using DotNetEnv;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using MvcMovie.Data;

var builder = WebApplication.CreateBuilder(args);

Env.Load();

builder.Services.AddHealthChecks();

string TracingAgentHost = Environment.GetEnvironmentVariable("TRACING_AGENT_HOST");
int TracingAgentPort = int.Parse(Environment.GetEnvironmentVariable("TRACING_AGENT_PORT"));

var connectionString = Environment.GetEnvironmentVariable("CONNECTION_STRINGS")

builder.Services.AddDbContext<MvcMovieContext>(options =>
    options.UseSqlServer(connectionString));

// Tambahkan OpenTelemetry Metrics
builder.Services.AddOpenTelemetry()
    .WithMetrics(metrics =>
    {
        metrics
            .SetResourceBuilder(ResourceBuilder.CreateDefault().AddService("mvcmovie"))
            .AddAspNetCoreInstrumentation()
            .AddRuntimeInstrumentation()
            .AddPrometheusExporter(); // Ini yang expose /metrics untuk Prometheus
    })
    .WithTracing(tracing =>
    {
        tracing
            .SetResourceBuilder(ResourceBuilder.CreateDefault().AddService("mvcmovie"))
            .AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation()
            .AddJaegerExporter(options =>
            {
                options.AgentHost = TracingAgentHost;
                options.AgentPort = TracingAgentPort;
            });
    });

// Add services to the container.
builder.Services.AddControllersWithViews();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();

app.UseAuthorization();

app.MapStaticAssets();

 app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}")
    .WithStaticAssets();

app.MapPrometheusScrapingEndpoint(); // expose di /metrics (default)

app.MapHealthChecks("/healthz");

app.Run();