using CarPredictor.Core.Domain;

namespace CarPredictor.Core.Interfaces;

/// <summary>
/// Repository interface for region data access.
/// </summary>
public interface IRegionRepository
{
    /// <summary>
    /// Gets all active regions.
    /// </summary>
    Task<IReadOnlyList<Region>> GetActiveRegionsAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Gets a region by code.
    /// </summary>
    Task<Region?> GetByCodeAsync(string regionCode, CancellationToken cancellationToken = default);
}
