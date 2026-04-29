namespace CarPredictor.Api.DTOs.Responses;

/// <summary>
/// Represents a vehicle manufacturer in API responses.
/// </summary>
public sealed class ManufacturerDto
{
    /// <summary>Unique manufacturer ID.</summary>
    public int ManufacturerId { get; init; }
    
    /// <summary>Manufacturer name.</summary>
    public required string ManufacturerName { get; init; }
    
    /// <summary>Country of origin.</summary>
    public string? CountryOfOrigin { get; init; }
    
    /// <summary>Number of models available.</summary>
    public int ModelCount { get; init; }
}