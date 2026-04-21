using CarPredictor.Core.Domain;

namespace CarPredictor.Core.Interfaces;

/// <summary>
/// Repository interface for vehicle model data access.
/// </summary>
public interface IVehicleModelRepository
{
    /// <summary>
    /// Gets all vehicle models for a manufacturer.
    /// </summary>
    Task<IReadOnlyList<VehicleModel>> GetByManufacturerIdAsync(int manufacturerId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Gets a vehicle model by ID.
    /// </summary>
    Task<VehicleModel?> GetByIdAsync(int vehicleModelId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Gets available years for a vehicle model.
    /// </summary>
    Task<IReadOnlyList<int>> GetAvailableYearsAsync(int vehicleModelId, CancellationToken cancellationToken = default);
}