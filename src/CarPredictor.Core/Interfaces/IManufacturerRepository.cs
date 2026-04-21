using CarPredictor.Core.Domain;

namespace CarPredictor.Core.Interfaces;

/// <summary>
/// Repository interface for manufacturer data access.
/// </summary>
public interface IManufacturerRepository
{
    /// <summary>
    /// Gets all manufacturers.
    /// </summary>
    Task<IReadOnlyList<Manufacturer>> GetAllAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Gets a manufacturer by ID.
    /// </summary>
    Task<Manufacturer?> GetByIdAsync(int manufacturerId, CancellationToken cancellationToken = default);
}