using CarPredictor.External.Models;
using CarPredictor.External.Services;
using Microsoft.AspNetCore.Mvc;

namespace CarPredictor.Api.Controllers;

[ApiController]
[Route("api/v1/vehicle")]
public class VehicleLookupController : ControllerBase
{
    private readonly IVehicleLookupService _vehicleLookupService;
    private readonly ILogger<VehicleLookupController> _logger;

    public VehicleLookupController(
        IVehicleLookupService vehicleLookupService,
        ILogger<VehicleLookupController> logger)
    {
        _vehicleLookupService = vehicleLookupService;
        _logger = logger;
    }

    /// <summary>
    /// Look up a vehicle by UK registration number.
    /// Returns vehicle details, MOT history, and recent defects.
    /// </summary>
    /// <param name="registration">UK vehicle registration number (e.g., AB12CDE)</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Vehicle lookup result with MOT history</returns>
    [HttpGet("lookup/{registration}")]
    [ProducesResponseType(typeof(VehicleLookupResult), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<VehicleLookupResult>> LookupByRegistration(
        string registration,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(registration))
        {
            return BadRequest("Registration number is required");
        }

        _logger.LogInformation("Vehicle lookup requested for: {Registration}", registration);

        var result = await _vehicleLookupService.LookupByRegistrationAsync(registration, cancellationToken);

        if (!result.IsValid)
        {
            return NotFound(new { error = result.ErrorMessage ?? "Vehicle not found" });
        }

        return Ok(result);
    }

    /// <summary>
    /// Check if the vehicle lookup service is configured with API keys.
    /// </summary>
    [HttpGet("status")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    public ActionResult GetServiceStatus()
    {
        return Ok(new 
        { 
            configured = _vehicleLookupService.IsConfigured,
            mode = _vehicleLookupService.IsConfigured ? "live" : "demo"
        });
    }
}