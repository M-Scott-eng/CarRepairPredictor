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
    
    // Static demo data matching rule files
    // Database IDs: BMW=1, Mercedes=2, Audi=3, VW=4, Ford=5, Vauxhall=6, Toyota=7, Honda=8, Nissan=9, etc.
    private static readonly List<MakeDto> DemoMakes = new()
    {
        new() { Id = 1, Name = "BMW", Country = "Germany", ModelCount = 2 },
        new() { Id = 2, Name = "Mercedes-Benz", Country = "Germany", ModelCount = 2 },
        new() { Id = 3, Name = "Audi", Country = "Germany", ModelCount = 2 },
        new() { Id = 4, Name = "Volkswagen", Country = "Germany", ModelCount = 2 },
        new() { Id = 5, Name = "Ford", Country = "USA", ModelCount = 2 },
        new() { Id = 6, Name = "Vauxhall", Country = "UK", ModelCount = 2 },
        new() { Id = 7, Name = "Toyota", Country = "Japan", ModelCount = 2 },
        new() { Id = 8, Name = "Honda", Country = "Japan", ModelCount = 2 },
        new() { Id = 9, Name = "Nissan", Country = "Japan", ModelCount = 2 },
        new() { Id = 10, Name = "Peugeot", Country = "France", ModelCount = 2 },
        new() { Id = 11, Name = "Renault", Country = "France", ModelCount = 2 },
        new() { Id = 12, Name = "Fiat", Country = "Italy", ModelCount = 2 },
        new() { Id = 15, Name = "Mini", Country = "UK", ModelCount = 2 },
        new() { Id = 16, Name = "Kia", Country = "South Korea", ModelCount = 2 },
        new() { Id = 17, Name = "Hyundai", Country = "South Korea", ModelCount = 2 },
        new() { Id = 18, Name = "Mazda", Country = "Japan", ModelCount = 2 },
        new() { Id = 20, Name = "Skoda", Country = "Czech Republic", ModelCount = 2 },
    };
    
    private static readonly Dictionary<int, List<ModelDto>> DemoModels = new()
    {
        // Database IDs: BMW=1, Mercedes=2, Audi=3, VW=4, Ford=5, Vauxhall=6, Toyota=7, Honda=8, Nissan=9, etc.
        [1] = new() // BMW
        {
            new() { Id = 101, Name = "3 Series", Generations = new List<GenerationDto> { new() { Code = "E90", Name = "E90 (2005-2012)", StartYear = 2005, EndYear = 2012 } }, YearRange = "2005-2012" },
            new() { Id = 102, Name = "1 Series", Generations = new List<GenerationDto> { new() { Code = "E87", Name = "E87 (2004-2011)", StartYear = 2004, EndYear = 2011 } }, YearRange = "2004-2011" },
        },
        [2] = new() // Mercedes-Benz
        {
            new() { Id = 201, Name = "C-Class", Generations = new List<GenerationDto> { new() { Code = "W204", Name = "W204 (2007-2014)", StartYear = 2007, EndYear = 2014 } }, YearRange = "2007-2014" },
            new() { Id = 202, Name = "E-Class", Generations = new List<GenerationDto> { new() { Code = "W212", Name = "W212 (2009-2016)", StartYear = 2009, EndYear = 2016 } }, YearRange = "2009-2016" },
        },
        [3] = new() // Audi
        {
            new() { Id = 301, Name = "A4", Generations = new List<GenerationDto> { new() { Code = "B8", Name = "B8 (2008-2015)", StartYear = 2008, EndYear = 2015 } }, YearRange = "2008-2015" },
            new() { Id = 302, Name = "A3", Generations = new List<GenerationDto> { new() { Code = "8P", Name = "8P (2003-2012)", StartYear = 2003, EndYear = 2012 } }, YearRange = "2003-2012" },
        },
        [4] = new() // Volkswagen
        {
            new() { Id = 401, Name = "Golf", Generations = new List<GenerationDto> { new() { Code = "Mk6", Name = "Mk6 (2008-2012)", StartYear = 2008, EndYear = 2012 }, new() { Code = "Mk7", Name = "Mk7 (2012-2019)", StartYear = 2012, EndYear = 2019 } }, YearRange = "2008-2019" },
            new() { Id = 402, Name = "Polo", Generations = new List<GenerationDto> { new() { Code = "6R", Name = "6R (2009-2017)", StartYear = 2009, EndYear = 2017 } }, YearRange = "2009-2017" },
        },
        [5] = new() // Ford
        {
            new() { Id = 501, Name = "Fiesta", Generations = new List<GenerationDto> { new() { Code = "Mk7", Name = "Mk7 (2008-2017)", StartYear = 2008, EndYear = 2017 } }, YearRange = "2008-2017" },
            new() { Id = 502, Name = "Focus", Generations = new List<GenerationDto> { new() { Code = "Mk3", Name = "Mk3 (2011-2018)", StartYear = 2011, EndYear = 2018 } }, YearRange = "2011-2018" },
        },
        [6] = new() // Vauxhall
        {
            new() { Id = 601, Name = "Corsa", Generations = new List<GenerationDto> { new() { Code = "D", Name = "Corsa D (2006-2014)", StartYear = 2006, EndYear = 2014 } }, YearRange = "2006-2014" },
            new() { Id = 602, Name = "Astra", Generations = new List<GenerationDto> { new() { Code = "J", Name = "Astra J (2009-2015)", StartYear = 2009, EndYear = 2015 } }, YearRange = "2009-2015" },
        },
        [7] = new() // Toyota
        {
            new() { Id = 701, Name = "Yaris", Generations = new List<GenerationDto> { new() { Code = "Mk2", Name = "Mk2 (2005-2011)", StartYear = 2005, EndYear = 2011 } }, YearRange = "2005-2011" },
            new() { Id = 702, Name = "Corolla", Generations = new List<GenerationDto> { new() { Code = "E150", Name = "E150 (2006-2012)", StartYear = 2006, EndYear = 2012 } }, YearRange = "2006-2012" },
        },
        [8] = new() // Honda
        {
            new() { Id = 801, Name = "Civic", Generations = new List<GenerationDto> { new() { Code = "Mk8", Name = "Mk8 (2006-2011)", StartYear = 2006, EndYear = 2011 } }, YearRange = "2006-2011" },
            new() { Id = 802, Name = "Jazz", Generations = new List<GenerationDto> { new() { Code = "GE8", Name = "GE8 (2008-2015)", StartYear = 2008, EndYear = 2015 } }, YearRange = "2008-2015" },
        },
        [9] = new() // Nissan
        {
            new() { Id = 901, Name = "Qashqai", Generations = new List<GenerationDto> { new() { Code = "J10", Name = "J10 (2007-2013)", StartYear = 2007, EndYear = 2013 } }, YearRange = "2007-2013" },
            new() { Id = 902, Name = "Juke", Generations = new List<GenerationDto> { new() { Code = "F15", Name = "F15 (2010-2019)", StartYear = 2010, EndYear = 2019 } }, YearRange = "2010-2019" },
        },
        [10] = new() // Peugeot
        {
            new() { Id = 1001, Name = "208", Generations = new List<GenerationDto> { new() { Code = "Mk1", Name = "Mk1 (2012-2019)", StartYear = 2012, EndYear = 2019 } }, YearRange = "2012-2019" },
            new() { Id = 1002, Name = "308", Generations = new List<GenerationDto> { new() { Code = "T7", Name = "T7 (2007-2013)", StartYear = 2007, EndYear = 2013 } }, YearRange = "2007-2013" },
        },
        [11] = new() // Renault
        {
            new() { Id = 1101, Name = "Clio", Generations = new List<GenerationDto> { new() { Code = "Mk4", Name = "Mk4 (2012-2019)", StartYear = 2012, EndYear = 2019 } }, YearRange = "2012-2019" },
            new() { Id = 1102, Name = "Megane", Generations = new List<GenerationDto> { new() { Code = "Mk3", Name = "Mk3 (2008-2016)", StartYear = 2008, EndYear = 2016 } }, YearRange = "2008-2016" },
        },
        [12] = new() // Fiat
        {
            new() { Id = 1201, Name = "500", Generations = new List<GenerationDto> { new() { Code = "312", Name = "312 (2007-present)", StartYear = 2007, EndYear = 2024 } }, YearRange = "2007-2024" },
            new() { Id = 1202, Name = "Punto", Generations = new List<GenerationDto> { new() { Code = "Mk3", Name = "Mk3 (2005-2018)", StartYear = 2005, EndYear = 2018 } }, YearRange = "2005-2018" },
        },
        [15] = new() // Mini
        {
            new() { Id = 1501, Name = "Cooper", Generations = new List<GenerationDto> { new() { Code = "R56", Name = "R56 (2006-2013)", StartYear = 2006, EndYear = 2013 } }, YearRange = "2006-2013" },
            new() { Id = 1502, Name = "Countryman", Generations = new List<GenerationDto> { new() { Code = "R60", Name = "R60 (2010-2016)", StartYear = 2010, EndYear = 2016 } }, YearRange = "2010-2016" },
        },
        [16] = new() // Kia
        {
            new() { Id = 1601, Name = "Sportage", Generations = new List<GenerationDto> { new() { Code = "SL", Name = "SL (2010-2015)", StartYear = 2010, EndYear = 2015 } }, YearRange = "2010-2015" },
            new() { Id = 1602, Name = "Ceed", Generations = new List<GenerationDto> { new() { Code = "JD", Name = "JD (2012-2018)", StartYear = 2012, EndYear = 2018 } }, YearRange = "2012-2018" },
        },
        [17] = new() // Hyundai
        {
            new() { Id = 1701, Name = "i30", Generations = new List<GenerationDto> { new() { Code = "GD", Name = "GD (2012-2017)", StartYear = 2012, EndYear = 2017 } }, YearRange = "2012-2017" },
            new() { Id = 1702, Name = "Tucson", Generations = new List<GenerationDto> { new() { Code = "TL", Name = "TL (2015-2020)", StartYear = 2015, EndYear = 2020 } }, YearRange = "2015-2020" },
        },
        [18] = new() // Mazda
        {
            new() { Id = 1801, Name = "3", Generations = new List<GenerationDto> { new() { Code = "BL", Name = "BL (2009-2013)", StartYear = 2009, EndYear = 2013 } }, YearRange = "2009-2013" },
            new() { Id = 1802, Name = "CX-5", Generations = new List<GenerationDto> { new() { Code = "KE", Name = "KE (2012-2017)", StartYear = 2012, EndYear = 2017 } }, YearRange = "2012-2017" },
        },
        [20] = new() // Skoda
        {
            new() { Id = 2001, Name = "Octavia", Generations = new List<GenerationDto> { new() { Code = "Mk2", Name = "Mk2 (2004-2013)", StartYear = 2004, EndYear = 2013 } }, YearRange = "2004-2013" },
            new() { Id = 2002, Name = "Fabia", Generations = new List<GenerationDto> { new() { Code = "Mk2", Name = "Mk2 (2007-2014)", StartYear = 2007, EndYear = 2014 } }, YearRange = "2007-2014" },
        },
    };
    
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
        
        try
        {
            var manufacturers = await _manufacturerRepo.GetAllAsync();
            
            if (manufacturers.Any())
            {
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
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Database unavailable, using demo data");
        }
        
        // Return demo data when database is unavailable or empty
        return Ok(new MakesResponse
        {
            Makes = DemoMakes,
            TotalCount = DemoMakes.Count
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
        
        try
        {
            var manufacturer = await _manufacturerRepo.GetByIdAsync(makeId);
            if (manufacturer is not null)
            {
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
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Database unavailable, using demo data");
        }
        
        // Return demo data when database is unavailable
        if (DemoModels.TryGetValue(makeId, out var demoModels))
        {
            var makeName = DemoMakes.FirstOrDefault(m => m.Id == makeId)?.Name ?? "Unknown";
            return Ok(new ModelsResponse
            {
                MakeId = makeId,
                MakeName = makeName,
                Models = demoModels,
                TotalCount = demoModels.Count
            });
        }
        
        return NotFound(new ErrorResponseDto 
        { 
            Error = "NotFound",
            Message = $"Make with ID {makeId} not found" 
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
        
        try
        {
            var model = await _modelRepo.GetByIdAsync(modelId);
            if (model is not null)
            {
                var years = await _modelRepo.GetAvailableYearsAsync(modelId);
                
                return Ok(new YearsResponseDto
                {
                    ModelId = modelId,
                    ModelName = model.ModelName,
                    Years = years.OrderByDescending(y => y).ToList()
                });
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Database unavailable, using demo data");
        }
        
        // Find model in demo data and generate years from generations
        foreach (var models in DemoModels.Values)
        {
            var demoModel = models.FirstOrDefault(m => m.Id == modelId);
            if (demoModel is not null)
            {
                var generation = demoModel.Generations.FirstOrDefault();
                if (generation is not null)
                {
                    var years = Enumerable.Range(generation.StartYear, generation.EndYear - generation.StartYear + 1)
                        .OrderByDescending(y => y)
                        .ToList();
                    
                    return Ok(new YearsResponseDto
                    {
                        ModelId = modelId,
                        ModelName = demoModel.Name,
                        Years = years
                    });
                }
            }
        }
        
        return NotFound(new ErrorResponseDto 
        { 
            Error = "NotFound",
            Message = $"Model with ID {modelId} not found" 
        });
    }
}