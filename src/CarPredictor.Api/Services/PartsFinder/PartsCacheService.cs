using System;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using CarPredictor.Api.Services.PartsFinder.Interfaces;
using Microsoft.Extensions.Caching.Memory;

namespace CarPredictor.Api.Services.PartsFinder;

public sealed class PartsCacheService : IPartsCacheService
{
    private readonly IMemoryCache _cache;
    private int _hits;
    private int _misses;

    public PartsCacheService(IMemoryCache cache) => _cache = cache;

    public string GenerateCacheKey(string supplierId, SupplierSearchRequest request)
    {
        var json = JsonSerializer.Serialize(new { supplierId, request.Make, request.Model, request.Year, request.EngineCode, request.PartCategory, request.SearchQuery });
        var hashBytes = SHA256.HashData(Encoding.UTF8.GetBytes(json));
        return $"parts:{Convert.ToHexString(hashBytes)[..16]}";
    }

    public Task<CachedSearchResult?> GetSearchResultsAsync(string cacheKey, CancellationToken ct = default)
    {
        if (_cache.TryGetValue<CachedSearchResult>(cacheKey, out var result))
        {
            Interlocked.Increment(ref _hits);
            return Task.FromResult<CachedSearchResult?>(result);
        }
        Interlocked.Increment(ref _misses);
        return Task.FromResult<CachedSearchResult?>(null);
    }

    public Task SetSearchResultsAsync(string cacheKey, SupplierSearchResult result, TimeSpan ttl, CancellationToken ct = default)
    {
        var cached = new CachedSearchResult { Result = result, CachedAt = DateTime.UtcNow, ExpiresAt = DateTime.UtcNow.Add(ttl) };
        _cache.Set(cacheKey, cached, ttl);
        return Task.CompletedTask;
    }

    public Task<SupplierPartDetail?> GetPartDetailAsync(string supplierId, string externalPartId, CancellationToken ct = default)
    {
        var key = $"detail:{supplierId}:{externalPartId}";
        if (_cache.TryGetValue<SupplierPartDetail>(key, out var detail))
        {
            Interlocked.Increment(ref _hits);
            return Task.FromResult<SupplierPartDetail?>(detail);
        }
        Interlocked.Increment(ref _misses);
        return Task.FromResult<SupplierPartDetail?>(null);
    }

    public Task SetPartDetailAsync(string supplierId, string externalPartId, SupplierPartDetail detail, TimeSpan ttl, CancellationToken ct = default)
    {
        var key = $"detail:{supplierId}:{externalPartId}";
        _cache.Set(key, detail, ttl);
        return Task.CompletedTask;
    }

    public CacheStatistics GetStatistics() => new() { TotalEntries = 0, HitCount = _hits, MissCount = _misses };

    public void Clear()
    {
        if (_cache is MemoryCache mc) mc.Compact(1.0);
    }
}