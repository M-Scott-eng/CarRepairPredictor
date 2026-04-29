using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace CarPredictor.Api.Services.PartsFinder.Interfaces;

public interface ISupplierAdapter
{
    string SupplierId { get; }
    string SupplierName { get; }
    int Priority { get; }
    bool IsEnabled { get; }
    Task<SupplierSearchResult> SearchAsync(SupplierSearchRequest request, CancellationToken ct = default);
    Task<SupplierPartDetail?> GetPartDetailAsync(string externalPartId, CancellationToken ct = default);
    Task<bool> HealthCheckAsync(CancellationToken ct = default);
    string GenerateAffiliateUrl(string productUrl, Dictionary<string, string> trackingParams);
}

public record SupplierSearchRequest
{
    public string Make { get; init; } = string.Empty;
    public string Model { get; init; } = string.Empty;
    public int? Year { get; init; }
    public string? EngineCode { get; init; }
    public string? PartCategory { get; init; }
    public string? SearchQuery { get; init; }
    public string? OemPartNumber { get; init; }
    public int MaxResults { get; init; } = 20;
    public decimal? MaxPrice { get; init; }
    public bool NewOnly { get; init; }
}

public record SupplierSearchResult
{
    public string SupplierId { get; init; } = string.Empty;
    public bool Success { get; init; }
    public IReadOnlyList<SupplierPartResult> Results { get; init; } = Array.Empty<SupplierPartResult>();
    public int TotalAvailable { get; init; }
    public TimeSpan ResponseTime { get; init; }
    public string? ErrorMessage { get; init; }
    public bool WasRateLimited { get; init; }
}

public record SupplierPartResult
{
    public string ExternalId { get; init; } = string.Empty;
    public string Title { get; init; } = string.Empty;
    public string? Brand { get; init; }
    public string? OemPartNumber { get; init; }
    public string? SupplierPartNumber { get; init; }
    public decimal Price { get; init; }
    public string Currency { get; init; } = "GBP";
    public decimal? ShippingCost { get; init; }
    public string? ShippingCurrency { get; init; }
    public string? Condition { get; init; }
    public string? Availability { get; init; }
    public int? StockQuantity { get; init; }
    public string? SellerName { get; init; }
    public decimal? SellerRating { get; init; }
    public int? SellerFeedbackCount { get; init; }
    public int? EstimatedDeliveryMinDays { get; init; }
    public int? EstimatedDeliveryMaxDays { get; init; }
    public string? DeliveryInfo { get; init; }
    public string ProductUrl { get; init; } = string.Empty;
    public string? ImageUrl { get; init; }
    public string? ThumbnailUrl { get; init; }
    public string? Description { get; init; }
    public bool IsPrime { get; init; }
    public bool IsFeatured { get; init; }
}

public record SupplierPartDetail
{
    public SupplierPartResult Part { get; init; } = new();
    public IReadOnlyList<SupplierPartResult>? SimilarItems { get; init; }
    public IReadOnlyList<string>? CompatibleVehicles { get; init; }
}