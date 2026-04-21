namespace CarPredictor.Api.DTOs.Responses;

/// <summary>
/// Response model for available years for a vehicle model.
/// </summary>
public sealed class YearsResponseDto
{
    /// <summary>Model ID.</summary>
    /// <example>101</example>
    public int ModelId { get; init; }
    
    /// <summary>Model name.</summary>
    /// <example>3 Series</example>
    public required string ModelName { get; init; }
    
    /// <summary>Available years (descending order).</summary>
    public required IReadOnlyList<int> Years { get; init; }
}