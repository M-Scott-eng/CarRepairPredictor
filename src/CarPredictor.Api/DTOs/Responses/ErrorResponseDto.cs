namespace CarPredictor.Api.DTOs.Responses;

/// <summary>
/// Standard error response.
/// </summary>
public sealed class ErrorResponseDto
{
    public required string Message { get; init; }
    
    public string? Detail { get; init; }
    
    public string? TraceId { get; init; }
}
