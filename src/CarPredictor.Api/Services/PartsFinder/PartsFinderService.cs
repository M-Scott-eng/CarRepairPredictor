using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using CarPredictor.Api.Services.PartsFinder.Adapters;
using CarPredictor.Api.Services.PartsFinder.Configuration;
using CarPredictor.Api.Services.PartsFinder.Interfaces;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace CarPredictor.Api.Services.PartsFinder;

public sealed class PartsFinderService : IPartsFinderService
{
    private readonly IEnumerable<ISupplierAdapter> _suppliers;
    private readonly IPartsCacheService _cache;
    private readonly IRateLimiterService _rateLimiter;
    private readonly PartsFinderOptions _options;
    private readonly ILogger<PartsFinderService> _logger;

    public PartsFinderService(
        IEnumerable<ISupplierAdapter> suppliers,
        IPartsCacheService cache,
        IRateLimiterService rateLimiter,
        IOptions<PartsFinderOptions> options,
        ILogger<PartsFinderService> logger)
    {
        _suppliers = suppliers.OrderBy(s => s.Priority).ToList();
        _cache = cache;
        _rateLimiter = rateLimiter;
        _options = options.Value;
        _logger = logger;
    }

    public async Task<PartsSearchResponse> SearchPartsAsync(PartsSearchRequest request, CancellationToken ct = default)
    {
        var searchId = Guid.NewGuid().ToString("N")[..12];
        var stopwatch = Stopwatch.StartNew();
        var statuses = new List<SupplierStatus>();
        var allResults = new List<NormalisedPartResult>();

        _logger.LogInformation("Parts search {Id}: {Make} {Model} {Year}", searchId, request.Make, request.Model, request.Year);

        var enabled = _suppliers.Where(s => s.IsEnabled).Take(_options.MaxConcurrentRequests).ToList();
        if (enabled.Count == 0) return CreateEmptyResponse(searchId, stopwatch.Elapsed);

        var supplierRequest = new SupplierSearchRequest
        {
            Make = request.Make,
            Model = request.Model,
            Year = request.Year,
            EngineCode = request.EngineCode,
            PartCategory = request.PartCategory,
            SearchQuery = request.SearchQuery,
            OemPartNumber = request.OemPartNumber,
            MaxResults = _options.MaxResultsPerSupplier,
            MaxPrice = request.MaxPrice,
            NewOnly = request.NewOnly
        };

        var tasks = enabled.Select(async s =>
        {
            using var cts = CancellationTokenSource.CreateLinkedTokenSource(ct);
            cts.CancelAfter(TimeSpan.FromSeconds(_options.SupplierTimeoutSeconds));
            return await SearchSupplierAsync(s, supplierRequest, cts.Token);
        });

        var results = await Task.WhenAll(tasks);

        foreach (var (supplier, result) in enabled.Zip(results))
        {
            statuses.Add(new SupplierStatus
            {
                SupplierId = supplier.SupplierId,
                SupplierName = supplier.SupplierName,
                Success = result.Success,
                ResultCount = result.Results.Count,
                ResponseTime = result.ResponseTime,
                ErrorMessage = result.ErrorMessage,
                RateLimited = result.WasRateLimited,
                FromCache = false
            });

            if (result.Success)
            {
                allResults.AddRange(result.Results.Select(r => Normalise(r, supplier)));
                _rateLimiter.ReportSuccess(supplier.SupplierId);
            }
            else if (result.WasRateLimited)
            {
                _rateLimiter.ReportRateLimited(supplier.SupplierId);
            }
            else
            {
                _rateLimiter.ReportFailure(supplier.SupplierId);
            }
        }

        var sorted = SortResults(allResults, request.SortBy, request.Ascending).Take(request.MaxResults).ToList();
        stopwatch.Stop();

        var prices = sorted.Where(r => r.TotalPriceGbp > 0).Select(r => r.TotalPriceGbp).ToList();
        _logger.LogInformation("Search {Id} completed: {Count} results in {Ms}ms", searchId, sorted.Count, stopwatch.ElapsedMilliseconds);

        return new PartsSearchResponse
        {
            Results = sorted,
            Metadata = new PartsSearchMetadata
            {
                SearchId = searchId,
                TotalResults = sorted.Count,
                LowestPrice = prices.Count != 0 ? prices.Min() : null,
                HighestPrice = prices.Count != 0 ? prices.Max() : null,
                AveragePrice = prices.Count != 0 ? Math.Round(prices.Average(), 2) : null,
                SuppliersQueried = enabled.Count,
                SuppliersSucceeded = statuses.Count(s => s.Success),
                SearchDuration = stopwatch.Elapsed,
                SearchedAt = DateTime.UtcNow,
                FromCache = false
            },
            SupplierStatuses = statuses
        };
    }

    public async Task<PartDetailResponse?> GetPartDetailAsync(string supplierId, string externalPartId, CancellationToken ct = default)
    {
        var supplier = _suppliers.FirstOrDefault(s => s.SupplierId.Equals(supplierId, StringComparison.OrdinalIgnoreCase));
        if (supplier == null) return null;

        var cached = await _cache.GetPartDetailAsync(supplierId, externalPartId, ct);
        if (cached != null)
        {
            return new PartDetailResponse
            {
                Part = Normalise(cached.Part, supplier),
                TrackingCode = $"CC-{Math.Abs($"{supplierId}-{externalPartId}".GetHashCode()):X8}",
                SimilarParts = cached.SimilarItems?.Select(s => Normalise(s, supplier)).ToList(),
                CompatibleVehicles = cached.CompatibleVehicles
            };
        }

        using var permit = await _rateLimiter.TryAcquireAsync(supplierId, ct);
        if (permit == null) return null;

        var detail = await supplier.GetPartDetailAsync(externalPartId, ct);
        if (detail == null) return null;

        await _cache.SetPartDetailAsync(supplierId, externalPartId, detail,
            TimeSpan.FromMinutes(_options.DefaultCacheTtlMinutes), ct);

        return new PartDetailResponse
        {
            Part = Normalise(detail.Part, supplier),
            TrackingCode = $"CC-{Math.Abs($"{supplierId}-{externalPartId}".GetHashCode()):X8}",
            SimilarParts = detail.SimilarItems?.Select(s => Normalise(s, supplier)).ToList(),
            CompatibleVehicles = detail.CompatibleVehicles
        };
    }

    public async Task<IReadOnlyList<SupplierHealthStatus>> GetSupplierHealthAsync(CancellationToken ct = default)
    {
        var checks = _suppliers.Select(async s =>
        {
            var status = _rateLimiter.GetStatus(s.SupplierId);
            var healthy = await s.HealthCheckAsync(ct);
            return new SupplierHealthStatus
            {
                SupplierId = s.SupplierId,
                SupplierName = s.SupplierName,
                IsHealthy = healthy && status.CircuitState != CircuitBreakerState.Open,
                SuccessRate = status.InBackoff ? 0.5 : 1.0,
                AverageResponseTime = TimeSpan.FromMilliseconds(200),
                RequestsLastHour = status.RequestsThisMinute * 60,
                ErrorsLastHour = status.InBackoff ? 1 : 0
            };
        });
        return await Task.WhenAll(checks);
    }

    private async Task<SupplierSearchResult> SearchSupplierAsync(ISupplierAdapter supplier, SupplierSearchRequest request, CancellationToken ct)
    {
        var cacheKey = _cache.GenerateCacheKey(supplier.SupplierId, request);
        var cached = await _cache.GetSearchResultsAsync(cacheKey, ct);
        if (cached != null) return cached.Result;

        using var permit = await _rateLimiter.TryAcquireAsync(supplier.SupplierId, ct);
        if (permit == null)
        {
            return new SupplierSearchResult
            {
                SupplierId = supplier.SupplierId,
                Success = false,
                Results = Array.Empty<SupplierPartResult>(),
                ResponseTime = TimeSpan.Zero,
                WasRateLimited = true
            };
        }

        try
        {
            var result = await supplier.SearchAsync(request, ct);
            if (result.Success && result.Results.Count > 0)
            {
                await _cache.SetSearchResultsAsync(cacheKey, result, TimeSpan.FromMinutes(_options.DefaultCacheTtlMinutes), ct);
            }
            return result;
        }
        catch (OperationCanceledException)
        {
            return new SupplierSearchResult
            {
                SupplierId = supplier.SupplierId,
                Success = false,
                Results = Array.Empty<SupplierPartResult>(),
                ResponseTime = TimeSpan.Zero,
                ErrorMessage = "Timeout"
            };
        }
    }

    private NormalisedPartResult Normalise(SupplierPartResult part, ISupplierAdapter supplier)
    {
        var priceGbp = DemoSupplierAdapter.ConvertToGbp(part.Price, part.Currency);
        var shippingGbp = part.ShippingCost.HasValue
            ? DemoSupplierAdapter.ConvertToGbp(part.ShippingCost.Value, part.ShippingCurrency ?? "GBP")
            : (decimal?)null;
        var affiliateUrl = supplier.GenerateAffiliateUrl(part.ProductUrl, new Dictionary<string, string> { ["src"] = "carcheck" });

        return new NormalisedPartResult
        {
            ResultId = $"{supplier.SupplierId}-{part.ExternalId}",
            SupplierId = supplier.SupplierId,
            SupplierName = supplier.SupplierName,
            ExternalId = part.ExternalId,
            Title = part.Title,
            Brand = part.Brand,
            OemPartNumber = part.OemPartNumber,
            SupplierPartNumber = part.SupplierPartNumber,
            PriceGbp = Math.Round(priceGbp, 2),
            ShippingGbp = shippingGbp.HasValue ? Math.Round(shippingGbp.Value, 2) : null,
            TotalPriceGbp = Math.Round(priceGbp + (shippingGbp ?? 0), 2),
            Condition = part.Condition,
            Availability = part.Availability,
            StockQuantity = part.StockQuantity,
            SellerName = part.SellerName,
            SellerRating = part.SellerRating,
            SellerReviewCount = part.SellerFeedbackCount,
            EstimatedDeliveryDays = part.EstimatedDeliveryMaxDays ?? part.EstimatedDeliveryMinDays,
            DeliveryInfo = part.DeliveryInfo ?? $"{part.EstimatedDeliveryMinDays}-{part.EstimatedDeliveryMaxDays} days",
            ProductUrl = part.ProductUrl,
            AffiliateUrl = affiliateUrl,
            ImageUrl = part.ImageUrl ?? part.ThumbnailUrl,
            Description = part.Description,
            IsPrime = part.IsPrime,
            IsFeatured = part.IsFeatured,
            RelevanceScore = CalculateScore(part),
            FetchedAt = DateTime.UtcNow
        };
    }

    private static double CalculateScore(SupplierPartResult part)
    {
        var score = 50.0;
        if (part.SellerRating.HasValue) score += (double)part.SellerRating.Value * 5;
        if (part.Availability == "InStock") score += 10;
        if (part.IsPrime) score += 15;
        if (part.EstimatedDeliveryMinDays <= 2) score += 10;
        if (!string.IsNullOrEmpty(part.Brand)) score += 5;
        if (!string.IsNullOrEmpty(part.OemPartNumber)) score += 10;
        return Math.Min(100, score);
    }

    private static IEnumerable<NormalisedPartResult> SortResults(IEnumerable<NormalisedPartResult> results, string? sortBy, bool asc)
    {
        var dedup = results.GroupBy(r => new { r.OemPartNumber, r.Brand }).Select(g => g.OrderBy(r => r.TotalPriceGbp).First());
        return sortBy?.ToLowerInvariant() switch
        {
            "price" => asc ? dedup.OrderBy(r => r.TotalPriceGbp) : dedup.OrderByDescending(r => r.TotalPriceGbp),
            "rating" => asc ? dedup.OrderBy(r => r.SellerRating ?? 0) : dedup.OrderByDescending(r => r.SellerRating ?? 0),
            "delivery" => asc ? dedup.OrderBy(r => r.EstimatedDeliveryDays ?? int.MaxValue) : dedup.OrderByDescending(r => r.EstimatedDeliveryDays ?? 0),
            _ => dedup.OrderByDescending(r => r.RelevanceScore)
        };
    }

    private static PartsSearchResponse CreateEmptyResponse(string searchId, TimeSpan duration) => new()
    {
        Results = Array.Empty<NormalisedPartResult>(),
        Metadata = new PartsSearchMetadata
        {
            SearchId = searchId,
            TotalResults = 0,
            LowestPrice = null,
            HighestPrice = null,
            AveragePrice = null,
            SuppliersQueried = 0,
            SuppliersSucceeded = 0,
            SearchDuration = duration,
            SearchedAt = DateTime.UtcNow,
            FromCache = false
        },
        SupplierStatuses = Array.Empty<SupplierStatus>()
    };
}