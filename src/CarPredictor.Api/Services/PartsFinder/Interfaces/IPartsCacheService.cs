using System;
using System.Threading;
using System.Threading.Tasks;

namespace CarPredictor.Api.Services.PartsFinder.Interfaces;

public interface IPartsCacheService
{
    string GenerateCacheKey(string supplierId, SupplierSearchRequest request);
    Task<CachedSearchResult?> GetSearchResultsAsync(string cacheKey, CancellationToken ct = default);
    Task SetSearchResultsAsync(string cacheKey, SupplierSearchResult result, TimeSpan ttl, CancellationToken ct = default);
    Task<SupplierPartDetail?> GetPartDetailAsync(string supplierId, string externalPartId, CancellationToken ct = default);
    Task SetPartDetailAsync(string supplierId, string externalPartId, SupplierPartDetail detail, TimeSpan ttl, CancellationToken ct = default);
    CacheStatistics GetStatistics();
    void Clear();
}

public record CachedSearchResult
{
    public SupplierSearchResult Result { get; init; } = new();
    public DateTime CachedAt { get; init; }
    public DateTime ExpiresAt { get; init; }
}

public record CacheStatistics
{
    public int TotalEntries { get; init; }
    public int HitCount { get; init; }
    public int MissCount { get; init; }
    public double HitRate => HitCount + MissCount > 0 ? (double)HitCount / (HitCount + MissCount) : 0;
}