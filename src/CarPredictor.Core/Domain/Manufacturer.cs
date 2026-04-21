namespace CarPredictor.Core.Domain;

/// <summary>
/// Represents a vehicle manufacturer.
/// </summary>
public sealed class Manufacturer
{
    public int ManufacturerId { get; init; }
    
    public required string ManufacturerName { get; init; }
    
    public string? CountryOfOrigin { get; init; }
}