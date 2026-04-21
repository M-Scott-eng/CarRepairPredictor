namespace CarPredictor.Core.Domain;

/// <summary>
/// Represents repair cost information for a failure pattern in a specific region.
/// </summary>
public sealed class RepairCost
{
    public int RepairCostId { get; init; }
    
    public int FailurePatternId { get; init; }
    
    public int RegionId { get; init; }
    
    public decimal MinCost { get; init; }
    
    public decimal MaxCost { get; init; }
    
    public decimal AverageCost { get; init; }
    
    public decimal? LabourHours { get; init; }
    
    public decimal? PartsOnlyCost { get; init; }
    
    public DateOnly EffectiveFrom { get; init; }
    
    public DateOnly? EffectiveTo { get; init; }
}
