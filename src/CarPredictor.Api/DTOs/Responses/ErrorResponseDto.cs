namespace CarPredictor.Api.DTOs.Responses;

/// <summary>
/// Standard error response.
/// </summary>
public sealed class ErrorResponseDto
{
    /// <summary>Error code.</summary>
    /// <example>NotFound</example>
    public string? Error { get; init; }
    
    /// <summary>Error message.</summary>
    /// <example>Resource not found</example>
    public required string Message { get; init; }
    
    /// <summary>Additional detail.</summary>
    public string? Detail { get; init; }
    
    /// <summary>Trace ID for debugging.</summary>
    public string? TraceId { get; init; }
}
