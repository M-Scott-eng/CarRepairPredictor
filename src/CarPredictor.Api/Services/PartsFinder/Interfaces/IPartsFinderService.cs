using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace CarPredictor.Api.Services.PartsFinder.Interfaces;

public interface IPartsFinderService
{
    Task<PartsSearchResponse> SearchPartsAsync(PartsSearchRequest request, CancellationToken ct = default);
    Task<PartDetailResponse?> GetPartDetailAsync(string supplierId, string externalPartId, CancellationToken ct = default);
    Task<IReadOnlyList<SupplierHealthStatus>> GetSupplierHealthAsync(CancellationToken ct = default);
}

public record PartsSearchRequest
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
    public string? SortBy { get; init; }
    public bool Ascending { get; init; } = true;
}

public record PartsSearchResponse
{
    public IReadOnlyList<NormalisedPartResult> Results { get; init; } = Array.Empty<NormalisedPartResult>();
    public PartsSearchMetadata Metadata { get; init; } = new();
    public IReadOnlyList<SupplierStatus> SupplierStatuses { get; init; } = Array.Empty<SupplierStatus>();
}

public record PartsSearchMetadata
{
    public string SearchId { get; init; } = string.Empty;
    public int TotalResults { get; init; }
    public decimal? LowestPrice { get; init; }
    public decimal? HighestPrice { get; init; }
    public decimal? AveragePrice { get; init; }
    public int SuppliersQueried { get; init; }
    public int SuppliersSucceeded { get; init; }
    public TimeSpan SearchDuration { get; init; }
    public DateTime SearchedAt { get; init; }
    public bool FromCache { get; init; }
}

public record NormalisedPartResult
{
    public string ResultId { get; init; } = string.Empty;
    public string SupplierId { get; init; } = string.Empty;
    public string SupplierName { get; init; } = string.Empty;
    public string ExternalId { get; init; } = string.Empty;
    public string Title { get; init; } = string.Empty;
    public string? Brand { get; init; }
    public string? OemPartNumber { get; init; }
    public string? SupplierPartNumber { get; init; }
    public decimal PriceGbp { get; init; }
    public decimal? ShippingGbp { get; init; }
    public decimal TotalPriceGbp { get; init; }
    public string? Condition { get; init; }
    public string? Availability { get; init; }
    public int? StockQuantity { get; init; }
    public string? SellerName { get; init; }
    public decimal? SellerRating { get; init; }
    public int? SellerReviewCount { get; init; }
    public int? EstimatedDeliveryDays { get; init; }
    public string? DeliveryInfo { get; init; }
    public string ProductUrl { get; init; } = string.Empty;
    public string? AffiliateUrl { get; init; }
    public string? ImageUrl { get; init; }
    public string? Description { get; init; }
    public bool IsPrime { get; init; }
    public bool IsFeatured { get; init; }
    public double RelevanceScore { get; init; }
    public DateTime FetchedAt { get; init; }
}

public record SupplierStatus
{
    public string SupplierId { get; init; } = string.Empty;
    public string SupplierName { get; init; } = string.Empty;
    public bool Success { get; init; }
    public int ResultCount { get; init; }
    public TimeSpan ResponseTime { get; init; }
    public string? ErrorMessage { get; init; }
    public bool RateLimited { get; init; }
    public bool FromCache { get; init; }
}

public record PartDetailResponse
{
    public NormalisedPartResult Part { get; init; } = new();
    public string? TrackingCode { get; init; }
    public IReadOnlyList<NormalisedPartResult>? SimilarParts { get; init; }
    public IReadOnlyList<string>? CompatibleVehicles { get; init; }
}

public record SupplierHealthStatus
{
    public string SupplierId { get; init; } = string.Empty;
    public string SupplierName { get; init; } = string.Empty;
    public bool IsHealthy { get; init; }
    public double SuccessRate { get; init; }
    public TimeSpan AverageResponseTime { get; init; }
    public int RequestsLastHour { get; init; }
    public int ErrorsLastHour { get; init; }
}