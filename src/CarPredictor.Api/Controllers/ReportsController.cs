
using CarPredictor.Api.DTOs.Responses;
using Microsoft.AspNetCore.Mvc;

namespace CarPredictor.Api.Controllers;

/// <summary>
/// Endpoints for viewing saved prediction reports.
/// </summary>
[ApiController]
[Route("api/v1/reports")]
[Produces("application/json")]
public class ReportsController : ControllerBase
{
    private readonly ILogger<ReportsController> _logger;
    
    public ReportsController(ILogger<ReportsController> logger)
    {
        _logger = logger;
    }
    
    /// <summary>
    /// Gets a saved prediction report by ID.
    /// </summary>
    /// <param name="id">The report ID.</param>
    /// <returns>The saved report with prediction data.</returns>
    /// <response code="200">Report retrieved successfully.</response>
    /// <response code="404">Report not found.</response>
    [HttpGet("{id}")]
    [ProducesResponseType(typeof(ReportResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponseDto), StatusCodes.Status404NotFound)]
    public ActionResult<ReportResponse> GetReport(string id)
    {
        _logger.LogInformation("Fetching report {ReportId}", id);
        
        // TODO: Implement report storage/retrieval
        // For now, return a demo response
        
        if (!id.StartsWith("rpt_"))
        {
            return NotFound(new ErrorResponseDto
            {
                Error = "NotFound",
                Message = $"Report with ID '{id}' not found"
            });
        }
        
        // Demo response - replace with actual data retrieval
        var response = new ReportResponse
        {
            ReportId = id,
            UserId = null,
            Title = "Demo Report - 2010 BMW 3 Series E90",
            Prediction = new PredictResponse
            {
                PredictionId = "pred_demo123",
                Vehicle = new VehicleDto
                {
                    Make = "BMW",
                    Model = "3 Series",
                    Generation = "E90",
                    Year = 2010,
                    Mileage = 85000,
                    FuelType = "Diesel",
                    Transmission = "Manual",
                    DisplayName = "2010 BMW 3 Series (E90)"
                },
                ReliabilityScore = 68.5m,
                ReliabilityGrade = "C",
                PredictedFailures = new List<FailurePredictionDto>
                {
                    new()
                    {
                        FailureName = "N47 Timing Chain Failure",
                        Category = "Engine",
                        Description = "Notorious timing chain wear on N47 diesel engines.",
                        Probability = 62.5m,
                        ProbabilityLevel = "High",
                        Severity = 4,
                        SeverityText = "Critical",
                        MinCost = 1280m,
                        MaxCost = 1920m,
                        CostRange = "£1,280 - £1,920"
                    }
                },
                EstimatedTwelveMonthCost = 850m,
                EstimatedThreeYearCost = 2500m,
                AnnualRepairCost = 833.33m,
                CommonIssueCount = 5,
                GeneratedAt = DateTime.UtcNow.AddDays(-7)
            },
            Notes = null,
            CreatedAt = DateTime.UtcNow.AddDays(-7),
            ExpiresAt = DateTime.UtcNow.AddDays(23),
            IsPublic = false,
            ShareUrl = null
        };
        
        return Ok(response);
    }
}
