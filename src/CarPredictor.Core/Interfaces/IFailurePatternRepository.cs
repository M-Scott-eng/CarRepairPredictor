using CarPredictor.Core.Domain;

namespace CarPredictor.Core.Interfaces;

/// <summary>
/// Repository interface for failure pattern data access.
/// </summary>
public interface IFailurePatternRepository
{
    /// <summary>
    /// Gets failure patterns for a vehicle model.
    /// </summary>
    Task<IReadOnlyList<FailurePattern>> GetByVehicleModelIdAsync(int vehicleModelId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Gets failure patterns for a vehicle model, filtered by mileage and age.
    /// </summary>
    Task<IReadOnlyList<FailurePattern>> GetApplicablePatternsAsync(
        int vehicleModelId,
        int mileage,
        int vehicleAge,
        CancellationToken cancellationToken = default);
}
