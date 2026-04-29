using System;
using System.Collections.Concurrent;
using System.Threading;
using System.Threading.Tasks;
using CarPredictor.Api.Services.PartsFinder.Configuration;
using CarPredictor.Api.Services.PartsFinder.Interfaces;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace CarPredictor.Api.Services.PartsFinder;

public sealed class RateLimiterService : IRateLimiterService
{
    private readonly ConcurrentDictionary<string, SupplierState> _states = new();
    private readonly PartsFinderOptions _options;
    private readonly ILogger<RateLimiterService> _logger;

    public RateLimiterService(IOptions<PartsFinderOptions> options, ILogger<RateLimiterService> logger)
    {
        _options = options.Value;
        _logger = logger;
    }

    public Task<RateLimitPermit?> TryAcquireAsync(string supplierId, CancellationToken ct = default)
    {
        var state = _states.GetOrAdd(supplierId, _ => new SupplierState());

        if (state.CircuitState == CircuitBreakerState.Open && DateTime.UtcNow < state.CircuitOpenUntil)
            return Task.FromResult<RateLimitPermit?>(null);

        if (state.InBackoff && DateTime.UtcNow < state.BackoffUntil)
            return Task.FromResult<RateLimitPermit?>(null);

        var windowStart = DateTime.UtcNow.AddMinutes(-1);
        while (state.Timestamps.TryPeek(out var ts) && ts < windowStart)
            state.Timestamps.TryDequeue(out _);

        var limit = GetRateLimit(supplierId);
        if (state.Timestamps.Count >= limit)
            return Task.FromResult<RateLimitPermit?>(null);

        state.Timestamps.Enqueue(DateTime.UtcNow);
        return Task.FromResult<RateLimitPermit?>(new RateLimitPermit(() => { }));
    }

    public async Task<RateLimitPermit> WaitForPermitAsync(string supplierId, TimeSpan timeout, CancellationToken ct = default)
    {
        var deadline = DateTime.UtcNow.Add(timeout);
        while (DateTime.UtcNow < deadline)
        {
            var permit = await TryAcquireAsync(supplierId, ct);
            if (permit != null) return permit;
            await Task.Delay(100, ct);
        }
        throw new TimeoutException($"Rate limit timeout for {supplierId}");
    }

    public RateLimitStatus GetStatus(string supplierId)
    {
        var state = _states.GetOrAdd(supplierId, _ => new SupplierState());
        var limit = GetRateLimit(supplierId);
        var windowStart = DateTime.UtcNow.AddMinutes(-1);
        while (state.Timestamps.TryPeek(out var ts) && ts < windowStart) state.Timestamps.TryDequeue(out _);
        var count = state.Timestamps.Count;
        return new RateLimitStatus
        {
            SupplierId = supplierId,
            RequestsPerMinute = limit,
            RequestsThisMinute = count,
            RemainingRequests = Math.Max(0, limit - count),
            WindowResetAt = DateTime.UtcNow.AddMinutes(1),
            IsLimited = count >= limit,
            InBackoff = state.InBackoff && DateTime.UtcNow < state.BackoffUntil,
            BackoffUntil = state.InBackoff ? state.BackoffUntil : null,
            CircuitState = state.CircuitState
        };
    }

    public void ReportRateLimited(string supplierId, TimeSpan? retryAfter = null)
    {
        var state = _states.GetOrAdd(supplierId, _ => new SupplierState());
        lock (state)
        {
            state.InBackoff = true;
            state.BackoffUntil = DateTime.UtcNow.Add(retryAfter ?? TimeSpan.FromSeconds(30));
            state.Failures++;
            if (state.Failures >= 5)
            {
                state.CircuitState = CircuitBreakerState.Open;
                state.CircuitOpenUntil = DateTime.UtcNow.AddMinutes(1);
            }
        }
        _logger.LogWarning("Rate limited for {Supplier}, backoff until {Until}", supplierId, state.BackoffUntil);
    }

    public void ReportSuccess(string supplierId)
    {
        var state = _states.GetOrAdd(supplierId, _ => new SupplierState());
        lock (state) { state.Failures = 0; state.InBackoff = false; }
    }

    public void ReportFailure(string supplierId)
    {
        var state = _states.GetOrAdd(supplierId, _ => new SupplierState());
        lock (state)
        {
            state.Failures++;
            if (state.Failures >= 5)
            {
                state.CircuitState = CircuitBreakerState.Open;
                state.CircuitOpenUntil = DateTime.UtcNow.AddMinutes(1);
            }
        }
    }

    public void Reset(string supplierId) => _states.TryRemove(supplierId, out _);

    private int GetRateLimit(string supplierId)
    {
        if (_options.Suppliers.TryGetValue(supplierId, out var opts)) return opts.RequestsPerMinute;
        return supplierId switch { SupplierIds.EBay => 100, SupplierIds.Amazon => 10, _ => 60 };
    }

    private sealed class SupplierState
    {
        public ConcurrentQueue<DateTime> Timestamps { get; } = new();
        public int Failures { get; set; }
        public bool InBackoff { get; set; }
        public DateTime BackoffUntil { get; set; }
        public CircuitBreakerState CircuitState { get; set; } = CircuitBreakerState.Closed;
        public DateTime CircuitOpenUntil { get; set; }
    }
}
