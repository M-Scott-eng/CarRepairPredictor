namespace CarPredictor.Api.DTOs.Responses;

/// <summary>
/// Represents a vehicle model in API responses.
/// </summary>
public sealed class VehicleModelDto
{
    public int VehicleModelId { get; init; }
    
    public int ManufacturerId { get; init; }
    
    public required string ModelName { get; init; }
    
    public int YearStart { get; init; }
    
    public int? YearEnd { get; init; }
    
    public string? ManufacturerName { get; init; }
}
