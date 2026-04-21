namespace CarPredictor.Core.Domain;

/// <summary>
/// Represents a vehicle model.
/// </summary>
public sealed class VehicleModel
{
    public int VehicleModelId { get; init; }
    
    public int ManufacturerId { get; init; }
    
    public required string ModelName { get; init; }
    
    public int YearStart { get; init; }
    
    public int? YearEnd { get; init; }
    
    public string? EngineTypes { get; init; }
    
    public string? ManufacturerName { get; init; }
}
