namespace CarPredictor.Core.Domain;

/// <summary>
/// Represents a region with associated settings.
/// </summary>
public sealed class Region
{
    public int RegionId { get; init; }
    
    public required string RegionCode { get; init; }
    
    public required string RegionName { get; init; }
    
    public required string CurrencyCode { get; init; }
    
    public bool IsActive { get; init; }
}
