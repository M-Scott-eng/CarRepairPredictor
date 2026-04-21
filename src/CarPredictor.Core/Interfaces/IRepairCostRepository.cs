using CarPredictor.Core.Domain;

namespace CarPredictor.Core.Interfaces;

/// <summary>
/// Repository interface for repair cost data access.
/// </summary>
public interface IRepairCostRepository
{
    /// <summary>
    /// Gets repair costs for failure patterns in a specific region.
    /// </summary>
    Task<IReadOnlyList<RepairCost>> GetByFailurePatternIdsAsync(
        IEnumerable<int> failurePatternIds,
        int regionId,
        CancellationToken cancellationToken = default);
}
