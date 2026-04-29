using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using CarPredictor.Api.Services.PartsFinder.Configuration;
using CarPredictor.Api.Services.PartsFinder.Interfaces;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace CarPredictor.Api.Services.PartsFinder.Adapters;

public sealed class DemoSupplierAdapter : ISupplierAdapter
{
    private readonly HttpClient _http;
    private readonly PartsFinderOptions _options;
    private readonly ILogger<DemoSupplierAdapter> _logger;
    private readonly string _supplierId;
    private readonly string _supplierName;

    public DemoSupplierAdapter(HttpClient http, IOptions<PartsFinderOptions> options, ILogger<DemoSupplierAdapter> logger, string supplierId, string supplierName)
    {
        _http = http;
        _options = options.Value;
        _logger = logger;
        _supplierId = supplierId;
        _supplierName = supplierName;
    }

    public string SupplierId => _supplierId;
    public string SupplierName => _supplierName;
    public int Priority => _options.Suppliers.TryGetValue(_supplierId, out var opts) ? opts.Priority : 100;
    public bool IsEnabled => _options.Suppliers.TryGetValue(_supplierId, out var opts) ? opts.Enabled : true;

    public Task<SupplierSearchResult> SearchAsync(SupplierSearchRequest request, CancellationToken ct = default)
    {
        var stopwatch = Stopwatch.StartNew();
        var results = GenerateDemoResults(request);
        stopwatch.Stop();

        return Task.FromResult(new SupplierSearchResult
        {
            SupplierId = _supplierId,
            Success = true,
            Results = results,
            TotalAvailable = results.Count,
            ResponseTime = stopwatch.Elapsed
        });
    }

    public Task<SupplierPartDetail?> GetPartDetailAsync(string externalPartId, CancellationToken ct = default)
    {
        var part = new SupplierPartResult
        {
            ExternalId = externalPartId,
            Title = $"Demo Part {externalPartId}",
            Brand = "Bosch",
            Price = 49.99m,
            Currency = "GBP",
            ShippingCost = 4.99m,
            Condition = "New",
            Availability = "InStock",
            ProductUrl = $"https://example.com/parts/{externalPartId}"
        };
        return Task.FromResult<SupplierPartDetail?>(new SupplierPartDetail { Part = part });
    }

    public Task<bool> HealthCheckAsync(CancellationToken ct = default) => Task.FromResult(true);

    public string GenerateAffiliateUrl(string productUrl, Dictionary<string, string> trackingParams)
    {
        var queryString = string.Join("&", trackingParams.Select(kv => $"{Uri.EscapeDataString(kv.Key)}={Uri.EscapeDataString(kv.Value)}"));
        return productUrl.Contains('?') ? $"{productUrl}&{queryString}" : $"{productUrl}?{queryString}";
    }

    private IReadOnlyList<SupplierPartResult> GenerateDemoResults(SupplierSearchRequest request)
    {
        var rng = new Random(Math.Abs($"{request.Make}{request.Model}{_supplierId}".GetHashCode()));
        var results = new List<SupplierPartResult>();
        var brands = new[] { "Bosch", "FEBI BILSTEIN", "FAI", "Mann-Filter", "NGK", "Brembo", "Sachs", "TRW", "Gates", "Dayco" };
        var categories = GetPartCategories(request.SearchQuery ?? request.PartCategory ?? "timing chain");

        foreach (var (cat, basePrice) in categories.Take(Math.Min(request.MaxResults, 8)))
        {
            var brand = brands[rng.Next(brands.Length)];
            var price = Math.Round(basePrice * (0.8m + (decimal)rng.NextDouble() * 0.4m), 2);
            results.Add(new SupplierPartResult
            {
                ExternalId = $"{_supplierId}-{Guid.NewGuid():N}".ToUpperInvariant()[..16],
                Title = $"{brand} {cat} for {request.Make} {request.Model}",
                Brand = brand,
                OemPartNumber = $"{rng.Next(10000, 99999)}",
                SupplierPartNumber = $"{brand[..2].ToUpperInvariant()}{rng.Next(1000, 9999)}",
                Price = price,
                Currency = "GBP",
                ShippingCost = Math.Round(2.99m + (decimal)rng.NextDouble() * 5, 2),
                ShippingCurrency = "GBP",
                Condition = "New",
                Availability = rng.NextDouble() > 0.2 ? "InStock" : "LimitedStock",
                StockQuantity = rng.Next(1, 50),
                SellerName = $"{_supplierName} Direct",
                SellerRating = Math.Round(4.0m + (decimal)rng.NextDouble(), 1),
                SellerFeedbackCount = rng.Next(100, 5000),
                EstimatedDeliveryMinDays = _supplierId == SupplierIds.Amazon ? 1 : 2,
                EstimatedDeliveryMaxDays = _supplierId == SupplierIds.Amazon ? 2 : 5,
                ProductUrl = $"https://{_supplierId}.example.com/parts/{rng.Next(100000, 999999)}",
                ImageUrl = "https://via.placeholder.com/200",
                IsPrime = _supplierId == SupplierIds.Amazon && rng.NextDouble() > 0.3,
                IsFeatured = rng.NextDouble() > 0.8
            });
        }
        return results;
    }

    private static IEnumerable<(string name, decimal price)> GetPartCategories(string query)
    {
        var q = query.ToLowerInvariant();
        if (q.Contains("timing")) return new[] { ("Timing Chain Kit", 189.99m), ("Timing Chain Tensioner", 45.99m), ("Chain Guide Rail", 29.99m) };
        if (q.Contains("brake")) return new[] { ("Brake Pads Front", 39.99m), ("Brake Discs Front", 89.99m), ("Brake Pads Rear", 34.99m) };
        if (q.Contains("oil")) return new[] { ("Oil Filter", 8.99m), ("Engine Oil 5W-30 5L", 34.99m), ("Sump Plug", 3.99m) };
        if (q.Contains("clutch")) return new[] { ("Clutch Kit", 149.99m), ("Clutch Release Bearing", 24.99m), ("Clutch Slave Cylinder", 34.99m) };
        return new[] { ("Generic Part", 49.99m), ("Replacement Component", 29.99m) };
    }

    public static decimal ConvertToGbp(decimal amount, string currency)
    {
        return currency.ToUpperInvariant() switch
        {
            "GBP" => amount,
            "EUR" => Math.Round(amount * 0.86m, 2),
            "USD" => Math.Round(amount * 0.79m, 2),
            _ => amount
        };
    }
}