using System;
using System.Threading;
using System.Threading.Tasks;

namespace CarPredictor.Api.Services.PartsFinder.Interfaces;

public interface IRateLimiterService
{
    Task<RateLimitPermit?> TryAcquireAsync(string supplierId, CancellationToken ct = default);
    Task<RateLimitPermit> WaitForPermitAsync(string supplierId, TimeSpan timeout, CancellationToken ct = default);
    RateLimitStatus GetStatus(string supplierId);
    void ReportRateLimited(string supplierId, TimeSpan? retryAfter = null);
    void ReportSuccess(string supplierId);
    void ReportFailure(string supplierId);
    void Reset(string supplierId);
}

public sealed class RateLimitPermit : IDisposable
{
    private readonly Action _onDispose;
    private bool _disposed;

    public RateLimitPermit(Action onDispose) => _onDispose = onDispose;

    public void Dispose()
    {
        if (!_disposed)
        {
            _disposed = true;
            _onDispose();
        }
    }
}

public sealed record RateLimitStatus
{
    public required string SupplierId { get; init; }
    public required int RequestsPerMinute { get; init; }
    public required int RequestsThisMinute { get; init; }
    public required int RemainingRequests { get; init; }
    public required DateTime WindowResetAt { get; init; }
    public required bool IsLimited { get; init; }
    public required bool InBackoff { get; init; }
    public DateTime? BackoffUntil { get; init; }
    public required CircuitBreakerState CircuitState { get; init; }
}

public enum CircuitBreakerState { Closed, HalfOpen, Open }
