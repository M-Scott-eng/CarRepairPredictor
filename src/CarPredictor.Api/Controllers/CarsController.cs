using CarPredictor.Api.DTOs.Responses;
using CarPredictor.Core.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CarPredictor.Api.Controllers;

/// <summary>
/// Endpoints for vehicle reference data (makes, models, years).
/// </summary>
[ApiController]
[Route("api/v1/cars")]
[Produces("application/json")]
public class CarsController : ControllerBase
{
    private readonly IManufacturerRepository _manufacturerRepo;
    private readonly IVehicleModelRepository _modelRepo;
    private readonly ILogger<CarsController> _logger;
    
    public CarsController(
        IManufacturerRepository manufacturerRepo,
        IVehicleModelRepository modelRepo,
        ILogger<CarsController> logger)
    {
        _manufacturerRepo = manufacturerRepo;
        _modelRepo = modelRepo;
        _logger = logger;
    }
    
    /// <summary>
    /// Gets all available vehicle makes.
    /// </summary>
    /// <returns>List of vehicle makes.</returns>
    /// <response code="200">Makes retrieved successfully.</response>
    [HttpGet("makes")]
    [ProducesResponseType(typeof(MakesResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<MakesResponse>> GetMakes()
    {
        _logger.LogInformation("Fetching all vehicle makes");
        
        var manufacturers = await _manufacturerRepo.GetAllAsync();
        
        var makes = manufacturers.Select(m => new MakeDto
        {
            Id = m.ManufacturerId,
            Name = m.ManufacturerName,
            Country = m.CountryOfOrigin,
            LogoUrl = null,
            ModelCount = 0
        }).ToList();
        
        return Ok(new MakesResponse
        {
            Makes = makes,
            TotalCount = makes.Count
        });
    }
    
    /// <summary>
    /// Gets all models for a specific make.
    /// </summary>
    /// <param name="makeId">The make ID.</param>
    /// <returns>List of models for the make.</returns>
    /// <response code="200">Models retrieved successfully.</response>
    /// <response code="404">Make not found.</response>
    [HttpGet("models")]
    [ProducesResponseType(typeof(ModelsResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponseDto), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ModelsResponse>> GetModels([FromQuery] int makeId)
    {
        _logger.LogInformation("Fetching models for make {MakeId}", makeId);
        
        var manufacturer = await _manufacturerRepo.GetByIdAsync(makeId);
        if (manufacturer is null)
        {
            return NotFound(new ErrorResponseDto 
            { 
                Error = "NotFound",
                Message = $"Make with ID {makeId} not found" 
            });
        }
        
        var vehicleModels = await _modelRepo.GetByManufacturerIdAsync(makeId);
        
        var models = vehicleModels.Select(m => new ModelDto
        {
            Id = m.VehicleModelId,
            Name = m.ModelName,
            Generations = new List<GenerationDto>(),
            YearRange = $"{m.YearStart}-{m.YearEnd ?? DateTime.Now.Year}"
        }).ToList();
        
        return Ok(new ModelsResponse
        {
            MakeId = makeId,
            MakeName = manufacturer.ManufacturerName,
            Models = models,
            TotalCount = models.Count
        });
    }
    
    /// <summary>
    /// Gets available years for a specific model.
    /// </summary>
    /// <param name="modelId">The model ID.</param>
    /// <returns>List of available years.</returns>
    /// <response code="200">Years retrieved successfully.</response>
    /// <response code="404">Model not found.</response>
    [HttpGet("years")]
    [ProducesResponseType(typeof(YearsResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponseDto), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<YearsResponseDto>> GetYears([FromQuery] int modelId)
    {
        _logger.LogInformation("Fetching years for model {ModelId}", modelId);
        
        var model = await _modelRepo.GetByIdAsync(modelId);
        if (model is null)
        {
            return NotFound(new ErrorResponseDto 
            { 
                Error = "NotFound",
                Message = $"Model with ID {modelId} not found" 
            });
        }
        
        var years = await _modelRepo.GetAvailableYearsAsync(modelId);
        
        return Ok(new YearsResponseDto
        {
            ModelId = modelId,
            ModelName = model.ModelName,
            Years = years.OrderByDescending(y => y).ToList()
        });
    }
}