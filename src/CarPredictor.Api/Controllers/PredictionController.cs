using CarPredictor.Api.DTOs.Requests;
using CarPredictor.Api.DTOs.Responses;
using CarPredictor.Rules.Interfaces;
using CarPredictor.Rules.Models;
using Microsoft.AspNetCore.Mvc;

namespace CarPredictor.Api.Controllers;

/// <summary>
/// Endpoint for vehicle repair cost predictions.
/// </summary>
[ApiController]
[Route("api/v1/[controller]")]
[Produces("application/json")]
public class PredictionController : ControllerBase
{
    private readonly IRuleEngine _ruleEngine;
    private readonly ILogger<PredictionController> _logger;
    
    public PredictionController(IRuleEngine ruleEngine, ILogger<PredictionController> logger)
    {
        _ruleEngine = ruleEngine;
        _logger = logger;
    }
    
    /// <summary>
    /// Predicts repair costs for a used vehicle.
    /// </summary>
    /// <param name="request">Vehicle details for prediction.</param>
    /// <returns>Predicted failures and cost estimates.</returns>
    /// <response code="200">Prediction generated successfully.</response>
    /// <response code="400">Invalid request parameters.</response>
    /// <response code="500">Internal server error.</response>
    [HttpPost]
    [ProducesResponseType(typeof(PredictResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponseDto), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponseDto), StatusCodes.Status500InternalServerError)]
    public async Task<ActionResult<PredictResponse>> Predict([FromBody] PredictRequest request)
    {
        _logger.LogInformation(
            "Prediction requested for {Year} {Make} {Model} with {Mileage} miles",
            request.Year, request.Make, request.Model, request.Mileage);
        
        var context = new VehicleContext
        {
            Make = request.Make,
            Model = request.Model,
            Generation = request.Generation,
            Year = request.Year,
            Mileage = request.Mileage,
            EngineCode = request.EngineCode,
            FuelType = request.FuelType,
            Transmission = request.Transmission,
            RegistrationNumber = request.RegistrationNumber
        };
        
        var result = await _ruleEngine.PredictAsync(context, request.RegionCode);
        
        var response = new PredictResponse
        {
            PredictionId = $"pred_{Guid.NewGuid():N}"[..16],
            Vehicle = new VehicleDto
            {
                Make = result.Vehicle.Make,
                Model = result.Vehicle.Model,
                Generation = result.Vehicle.Generation,
                Year = result.Vehicle.Year,
                Mileage = result.Vehicle.Mileage,
                FuelType = result.Vehicle.FuelType,
                Transmission = result.Vehicle.Transmission,
                DisplayName = result.Vehicle.DisplayName
            },
            ReliabilityScore = result.ReliabilityScore,
            ReliabilityGrade = result.ReliabilityGrade,
            PredictedFailures = result.Failures.Select(f => new FailurePredictionDto
            {
                FailureName = f.FailureName,
                Category = f.Category,
                Description = f.Description,
                Probability = f.Probability,
                ProbabilityLevel = f.ProbabilityLevel,
                Severity = f.Severity,
                SeverityText = f.SeverityText,
                MinCost = f.MinCost,
                MaxCost = f.MaxCost,
                CostRange = f.CostRange
            }).ToList(),
            EstimatedTwelveMonthCost = result.TwelveMonthCost,
            EstimatedThreeYearCost = result.ThreeYearCost,
            AnnualRepairCost = result.AnnualRepairCost,
            CommonIssueCount = result.CommonIssueCount,
            GeneratedAt = DateTime.UtcNow
        };
        
        _logger.LogInformation(
            "Prediction {PredictionId} generated with {FailureCount} failures, reliability score {Score}",
            response.PredictionId, response.PredictedFailures.Count, response.ReliabilityScore);
        
        return Ok(response);
    }
}
