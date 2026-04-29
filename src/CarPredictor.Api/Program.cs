using CarPredictor.Api.Configuration;
using CarPredictor.Api.Middleware;
using CarPredictor.Api.Services;
using CarPredictor.Api.Services.PartsFinder;
using CarPredictor.Core.Interfaces;
using CarPredictor.Data;
using CarPredictor.Data.Repositories;
using CarPredictor.External;
using CarPredictor.Rules.Engine;
using CarPredictor.Rules.Interfaces;
using CarPredictor.Rules.Providers;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Car Repair Cost Predictor API",
        Version = "v1",
        Description = "API for predicting used car repair costs in the UK market"
    });
});

// Configure CORS for frontend access
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins(
                "http://localhost:5173",  // Vite dev server
                "http://localhost:3000",  // Alternate dev port
                "https://carrepairpredictor.co.uk")
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials();
    });
});

// Configure database connection
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddSingleton<IDbConnectionFactory>(_ => new NpgsqlConnectionFactory(connectionString));

// Register repositories
builder.Services.AddScoped<IManufacturerRepository, ManufacturerRepository>();
builder.Services.AddScoped<IVehicleModelRepository, VehicleModelRepository>();
builder.Services.AddScoped<IFailurePatternRepository, FailurePatternRepository>();
builder.Services.AddScoped<IRepairCostRepository, RepairCostRepository>();
builder.Services.AddScoped<IRegionRepository, RegionRepository>();

// Register rule engine services
builder.Services.AddSingleton<IRuleProvider, JsonRuleProvider>();
builder.Services.AddSingleton<IRuleEngine, PredictionEngine>();

// Configure Stripe
builder.Services.Configure<StripeSettings>(builder.Configuration.GetSection(StripeSettings.SectionName));
builder.Services.AddSingleton<IStripeService, StripeService>();

// Configure Parts Finder Engine
builder.Services.AddPartsFinder(builder.Configuration);

// Configure Vehicle Lookup (MOT History API, DVLA API)
builder.Services.AddVehicleLookup(builder.Configuration);

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseExceptionMiddleware();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "Car Repair Predictor API v1");
    });
}

app.UseHttpsRedirection();
app.UseCors("AllowFrontend");
app.UseAuthorization();
app.MapControllers();

app.Run();
