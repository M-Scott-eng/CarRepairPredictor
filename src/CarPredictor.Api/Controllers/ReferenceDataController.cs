using CarPredictor.Api.DTOs.Responses;
using CarPredictor.Core.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CarPredictor.Api.Controllers;

/// <summary>
/// Endpoints for reference data (regions, fuel types, failure categories).
/// </summary>
[ApiController]
[Route("api/v1/reference")]
[Produces("application/json")]
public class ReferenceDataController : ControllerBase
{
    private readonly IRegionRepository _regionRepository;
    private readonly ILogger<ReferenceDataController> _logger;

    public ReferenceDataController(
        IRegionRepository regionRepository,
        ILogger<ReferenceDataController> logger)
    {
        _regionRepository = regionRepository;
        _logger = logger;
    }

    /// <summary>
    /// Gets all active regions.
    /// </summary>
    /// <returns>List of active regions.</returns>
    /// <response code="200">Regions retrieved successfully.</response>
    [HttpGet("regions")]
    [ProducesResponseType(typeof(RegionsResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<RegionsResponse>> GetRegions()
    {
        _logger.LogInformation("Fetching active regions");
        
        var regions = await _regionRepository.GetActiveRegionsAsync();
        
        var response = new RegionsResponse
        {
            Regions = regions.Select(r => new RegionDto
            {
                Code = r.RegionCode,
                Name = r.RegionName,
                Currency = r.CurrencyCode
            }).ToList()
        };
        
        return Ok(response);
    }

    /// <summary>
    /// Gets available fuel types.
    /// </summary>
    /// <returns>List of supported fuel types.</returns>
    /// <response code="200">Fuel types retrieved successfully.</response>
    [HttpGet("fuel-types")]
    [ProducesResponseType(typeof(FuelTypesResponse), StatusCodes.Status200OK)]
    public ActionResult<FuelTypesResponse> GetFuelTypes()
    {
        var fuelTypes = new List<FuelTypeDto>
        {
            new() { Code = "Petrol", DisplayName = "Petrol" },
            new() { Code = "Diesel", DisplayName = "Diesel" },
            new() { Code = "Hybrid", DisplayName = "Hybrid (Petrol/Electric)" },
            new() { Code = "Electric", DisplayName = "Electric" },
            new() { Code = "PluginHybrid", DisplayName = "Plug-in Hybrid" },
            new() { Code = "LPG", DisplayName = "LPG" }
        };

        return Ok(new FuelTypesResponse { FuelTypes = fuelTypes });
    }

    /// <summary>
    /// Gets available transmission types.
    /// </summary>
    /// <returns>List of supported transmission types.</returns>
    /// <response code="200">Transmission types retrieved successfully.</response>
    [HttpGet("transmissions")]
    [ProducesResponseType(typeof(TransmissionsResponse), StatusCodes.Status200OK)]
    public ActionResult<TransmissionsResponse> GetTransmissions()
    {
        var transmissions = new List<TransmissionDto>
        {
            new() { Code = "Manual", DisplayName = "Manual" },
            new() { Code = "Automatic", DisplayName = "Automatic" },
            new() { Code = "SemiAuto", DisplayName = "Semi-Automatic" },
            new() { Code = "CVT", DisplayName = "CVT" },
            new() { Code = "DCT", DisplayName = "Dual-Clutch (DCT)" }
        };

        return Ok(new TransmissionsResponse { Transmissions = transmissions });
    }

    /// <summary>
    /// Gets failure categories.
    /// </summary>
    /// <returns>List of failure categories.</returns>
    /// <response code="200">Categories retrieved successfully.</response>
    [HttpGet("categories")]
    [ProducesResponseType(typeof(CategoriesResponse), StatusCodes.Status200OK)]
    public ActionResult<CategoriesResponse> GetCategories()
    {
        var categories = new List<CategoryDto>
        {
            new() { Code = "Engine", DisplayName = "Engine", Icon = "engine" },
            new() { Code = "Transmission", DisplayName = "Transmission", Icon = "gearbox" },
            new() { Code = "Brakes", DisplayName = "Brakes", Icon = "brake" },
            new() { Code = "Suspension", DisplayName = "Suspension", Icon = "suspension" },
            new() { Code = "Electrical", DisplayName = "Electrical", Icon = "bolt" },
            new() { Code = "Exhaust", DisplayName = "Exhaust", Icon = "exhaust" },
            new() { Code = "Cooling", DisplayName = "Cooling System", Icon = "coolant" },
            new() { Code = "Steering", DisplayName = "Steering", Icon = "steering" },
            new() { Code = "Fuel", DisplayName = "Fuel System", Icon = "fuel" },
            new() { Code = "Tyres", DisplayName = "Tyres & Wheels", Icon = "tyre" },
            new() { Code = "Lighting", DisplayName = "Lighting", Icon = "light" },
            new() { Code = "BodyCorrosion", DisplayName = "Body & Corrosion", Icon = "car" },
            new() { Code = "Interior", DisplayName = "Interior", Icon = "seat" }
        };

        return Ok(new CategoriesResponse { Categories = categories });
    }
}

public sealed class RegionsResponse
{
    public required IReadOnlyList<RegionDto> Regions { get; init; }
}

public sealed class RegionDto
{
    public required string Code { get; init; }
    public required string Name { get; init; }
    public required string Currency { get; init; }
}

public sealed class FuelTypesResponse
{
    public required IReadOnlyList<FuelTypeDto> FuelTypes { get; init; }
}

public sealed class FuelTypeDto
{
    public required string Code { get; init; }
    public required string DisplayName { get; init; }
}

public sealed class TransmissionsResponse
{
    public required IReadOnlyList<TransmissionDto> Transmissions { get; init; }
}

public sealed class TransmissionDto
{
    public required string Code { get; init; }
    public required string DisplayName { get; init; }
}

public sealed class CategoriesResponse
{
    public required IReadOnlyList<CategoryDto> Categories { get; init; }
}

public sealed class CategoryDto
{
    public required string Code { get; init; }
    public required string DisplayName { get; init; }
    public required string Icon { get; init; }
}