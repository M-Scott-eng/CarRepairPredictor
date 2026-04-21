using CarPredictor.Core.Enums;

namespace CarPredictor.Core.Domain;

/// <summary>
/// Represents a known failure pattern for a specific vehicle model.
/// </summary>
public sealed class FailurePattern
{
    public int FailurePatternId { get; init; }
    
    public int VehicleModelId { get; init; }
    
    public int FailureCategoryId { get; init; }
    
    public required string FailureName { get; init; }
    
    public string? Description { get; init; }
    
    public int? MinMileage { get; init; }
    
    public int? MaxMileage { get; init; }
    
    public int? MinAge { get; init; }
    
    public int? MaxAge { get; init; }
    
    public decimal BaseProbability { get; init; }
    
    public SeverityLevel SeverityLevel { get; init; }
    
    public bool IsCommon { get; init; }
    
    public string? DataSource { get; init; }
    
    public string? CategoryName { get; init; }
}
