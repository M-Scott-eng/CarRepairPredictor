using CarPredictor.Core.Interfaces;
using CarPredictor.Rules.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CarPredictor.Api.Controllers;

/// <summary>
/// Health check endpoints for monitoring.
/// </summary>
[ApiController]
[Route("api/v1/[controller]")]
[Produces("application/json")]
public class HealthController : ControllerBase
{
    private readonly IDbConnectionFactory _connectionFactory;
    private readonly IRuleEngine _ruleEngine;
    private readonly ILogger<HealthController> _logger;

    public HealthController(
        IDbConnectionFactory connectionFactory,
        IRuleEngine ruleEngine,
        ILogger<HealthController> logger)
    {
        _connectionFactory = connectionFactory;
        _ruleEngine = ruleEngine;
        _logger = logger;
    }

    /// <summary>
    /// Basic health check - returns application status.
    /// </summary>
    /// <response code="200">Application is healthy.</response>
    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public ActionResult<HealthResponse> GetHealth()
    {
        return Ok(new HealthResponse
        {
            Status = "Healthy",
            Timestamp = DateTime.UtcNow,
            Version = "1.0.0"
        });
    }

    /// <summary>
    /// Detailed health check including dependencies.
    /// </summary>
    /// <response code="200">All dependencies healthy.</response>
    /// <response code="503">One or more dependencies unhealthy.</response>
    [HttpGet("detailed")]
    [ProducesResponseType(typeof(DetailedHealthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(DetailedHealthResponse), StatusCodes.Status503ServiceUnavailable)]
    public async Task<ActionResult<DetailedHealthResponse>> GetDetailedHealth()
    {
        var checks = new List<HealthCheck>();
        var overallHealthy = true;

        // Check database connectivity
        var dbCheck = await CheckDatabaseAsync();
        checks.Add(dbCheck);
        if (!dbCheck.IsHealthy) overallHealthy = false;

        // Check rule engine
        var ruleCheck = CheckRuleEngine();
        checks.Add(ruleCheck);
        if (!ruleCheck.IsHealthy) overallHealthy = false;

        var response = new DetailedHealthResponse
        {
            Status = overallHealthy ? "Healthy" : "Unhealthy",
            Timestamp = DateTime.UtcNow,
            Version = "1.0.0",
            Checks = checks
        };

        return overallHealthy ? Ok(response) : StatusCode(503, response);
    }

    private async Task<HealthCheck> CheckDatabaseAsync()
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            connection.Open();
            
            return new HealthCheck
            {
                Name = "Database",
                IsHealthy = true,
                Message = "SQL Server connection successful"
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Database health check failed");
            return new HealthCheck
            {
                Name = "Database",
                IsHealthy = false,
                Message = $"Database connection failed: {ex.Message}"
            };
        }
    }

    private HealthCheck CheckRuleEngine()
    {
        try
        {
            var ruleCount = _ruleEngine.GetLoadedRuleIds().Count;
            return new HealthCheck
            {
                Name = "RuleEngine",
                IsHealthy = true,
                Message = $"Rule engine operational with {ruleCount} rules loaded"
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Rule engine health check failed");
            return new HealthCheck
            {
                Name = "RuleEngine",
                IsHealthy = false,
                Message = $"Rule engine error: {ex.Message}"
            };
        }
    }
}

public sealed class HealthResponse
{
    public required string Status { get; init; }
    public DateTime Timestamp { get; init; }
    public required string Version { get; init; }
}

public sealed class DetailedHealthResponse
{
    public required string Status { get; init; }
    public DateTime Timestamp { get; init; }
    public required string Version { get; init; }
    public required IReadOnlyList<HealthCheck> Checks { get; init; }
}

public sealed class HealthCheck
{
    public required string Name { get; init; }
    public bool IsHealthy { get; init; }
    public required string Message { get; init; }
}