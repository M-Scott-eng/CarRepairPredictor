namespace CarPredictor.Core.Domain;

/// <summary>
/// Represents a category of vehicle failures.
/// </summary>
public sealed class FailureCategory
{
    public int FailureCategoryId { get; init; }
    
    public required string CategoryCode { get; init; }
    
    public required string CategoryName { get; init; }
    
    public string? Description { get; init; }
}
