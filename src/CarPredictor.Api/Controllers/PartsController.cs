using System.ComponentModel.DataAnnotations;
using System.Threading;
using System.Threading.Tasks;
using CarPredictor.Api.Services.PartsFinder.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace CarPredictor.Api.Controllers;

[ApiController]
[Route("api/v1/parts")]
public class PartsController : ControllerBase
{
    private readonly IPartsFinderService _partsFinder;
    private readonly ILogger<PartsController> _logger;

    public PartsController(IPartsFinderService partsFinder, ILogger<PartsController> logger)
    {
        _partsFinder = partsFinder;
        _logger = logger;
    }

    [HttpPost("search")]
    [ProducesResponseType(typeof(PartsSearchResponse), 200)]
    [ProducesResponseType(400)]
    public async Task<IActionResult> SearchParts([FromBody] PartsSearchRequestDto request, CancellationToken ct)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        if (string.IsNullOrWhiteSpace(request.Make))
            return BadRequest(new { error = "Make is required" });
        if (string.IsNullOrWhiteSpace(request.Model))
            return BadRequest(new { error = "Model is required" });

        var searchReq = new PartsSearchRequest
        {
            Make = request.Make.Trim(),
            Model = request.Model.Trim(),
            Year = request.Year,
            EngineCode = request.EngineCode?.Trim(),
            PartCategory = request.PartCategory?.Trim(),
            SearchQuery = request.SearchQuery?.Trim(),
            OemPartNumber = request.OemPartNumber?.Trim(),
            MaxResults = request.MaxResults ?? 20,
            MaxPrice = request.MaxPrice,
            NewOnly = request.NewOnly,
            SortBy = request.SortBy,
            Ascending = request.Ascending
        };

        var results = await _partsFinder.SearchPartsAsync(searchReq, ct);
        return Ok(results);
    }

    [HttpGet("search")]
    [ProducesResponseType(typeof(PartsSearchResponse), 200)]
    [ProducesResponseType(400)]
    public Task<IActionResult> SearchPartsGet(
        [FromQuery, Required] string make,
        [FromQuery, Required] string model,
        [FromQuery] int? year,
        [FromQuery] string? engineCode,
        [FromQuery] string? category,
        [FromQuery] string? query,
        [FromQuery] string? oemPartNumber,
        [FromQuery] int maxResults = 20,
        [FromQuery] decimal? maxPrice = null,
        [FromQuery] bool newOnly = false,
        [FromQuery] string? sortBy = null,
        [FromQuery] bool ascending = true,
        CancellationToken ct = default)
    {
        var request = new PartsSearchRequestDto
        {
            Make = make,
            Model = model,
            Year = year,
            EngineCode = engineCode,
            PartCategory = category,
            SearchQuery = query,
            OemPartNumber = oemPartNumber,
            MaxResults = maxResults,
            MaxPrice = maxPrice,
            NewOnly = newOnly,
            SortBy = sortBy,
            Ascending = ascending
        };
        return SearchParts(request, ct);
    }

    [HttpGet("{supplierId}/{externalPartId}")]
    [ProducesResponseType(typeof(PartDetailResponse), 200)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> GetPartDetail(string supplierId, string externalPartId, CancellationToken ct)
    {
        var detail = await _partsFinder.GetPartDetailAsync(supplierId, externalPartId, ct);
        return detail != null ? Ok(detail) : NotFound(new { error = "Part not found" });
    }

    [HttpGet("health")]
    [ProducesResponseType(typeof(object), 200)]
    public async Task<IActionResult> GetSupplierHealth(CancellationToken ct)
    {
        var statuses = await _partsFinder.GetSupplierHealthAsync(ct);
        var summary = new
        {
            TotalSuppliers = statuses.Count,
            HealthySuppliers = statuses.Count(s => s.IsHealthy),
            Suppliers = statuses
        };
        return Ok(summary);
    }
}

public class PartsSearchRequestDto
{
    [Required]
    public string Make { get; set; } = string.Empty;
    [Required]
    public string Model { get; set; } = string.Empty;
    public int? Year { get; set; }
    public string? EngineCode { get; set; }
    public string? PartCategory { get; set; }
    public string? SearchQuery { get; set; }
    public string? OemPartNumber { get; set; }
    public int? MaxResults { get; set; } = 20;
    public decimal? MaxPrice { get; set; }
    public bool NewOnly { get; set; }
    public string? SortBy { get; set; }
    public bool Ascending { get; set; } = true;
}