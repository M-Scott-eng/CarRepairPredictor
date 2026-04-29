using CarPredictor.External.Models;

namespace CarPredictor.External.Services;

/// <summary>
/// Service for looking up vehicle information via UK Government APIs.
/// </summary>
public interface IVehicleLookupService
{
    /// <summary>
    /// Checks if the service is properly configured with API keys.
    /// </summary>
    bool IsConfigured { get; }
    
    /// <summary>
    /// Lookup vehicle by registration number, combining MOT and DVLA data.
    /// </summary>
    /// <param name="registration">UK vehicle registration number.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Combined vehicle lookup result.</returns>
    Task<VehicleLookupResult> LookupByRegistrationAsync(
        string registration, 
        CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Get MOT history for a vehicle.
    /// </summary>
    /// <param name="registration">UK vehicle registration number.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>MOT history response or null if not found.</returns>
    Task<MotHistoryResponse?> GetMotHistoryAsync(
        string registration, 
        CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Get DVLA vehicle details.
    /// </summary>
    /// <param name="registration">UK vehicle registration number.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>DVLA vehicle response or null if not found.</returns>
    Task<DvlaVehicleResponse?> GetDvlaVehicleAsync(
        string registration, 
        CancellationToken cancellationToken = default);
}