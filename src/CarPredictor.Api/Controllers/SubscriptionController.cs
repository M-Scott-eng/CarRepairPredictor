using CarPredictor.Api.DTOs.Requests;
using CarPredictor.Api.DTOs.Responses;
using Microsoft.AspNetCore.Mvc;

namespace CarPredictor.Api.Controllers;

[ApiController]
[Route("api/v1/subscription")]
[Produces("application/json")]
public class SubscriptionController : ControllerBase
{
    private readonly ILogger<SubscriptionController> _logger;
    
    public SubscriptionController(ILogger<SubscriptionController> logger)
    {
        _logger = logger;
    }
    
    [HttpPost("create")]
    [ProducesResponseType(typeof(SubscriptionCreateResponse), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ErrorResponseDto), StatusCodes.Status400BadRequest)]
    public ActionResult<SubscriptionCreateResponse> CreateSubscription([FromBody] SubscriptionCreateRequest request)
    {
        _logger.LogInformation("Creating subscription for {Email} with plan {Plan}", request.Email, request.Plan);
        
        var validPlans = new[] { "Free", "Basic", "Premium" };
        if (!validPlans.Contains(request.Plan, StringComparer.OrdinalIgnoreCase))
        {
            return BadRequest(new ErrorResponseDto
            {
                Error = "InvalidPlan",
                Message = $"Plan '{request.Plan}' is not valid. Choose from: Free, Basic, Premium"
            });
        }
        
        var (monthlyCost, predictions, features) = request.Plan.ToLowerInvariant() switch
        {
            "free" => (0m, 5, new[] { "Basic predictions", "Email support" }),
            "basic" => (4.99m, 100, new[] { "Full predictions", "MOT history", "Save reports", "Email support" }),
            "premium" => (9.99m, -1, new[] { "Unlimited predictions", "MOT history", "Save reports", "API access", "Priority support" }),
            _ => (0m, 5, new[] { "Basic predictions" })
        };
        
        var subscriptionId = $"sub_{Guid.NewGuid():N}"[..16];
        var apiKey = $"sk_live_{Guid.NewGuid():N}";
        
        var response = new SubscriptionCreateResponse
        {
            SubscriptionId = subscriptionId,
            Email = request.Email,
            Plan = request.Plan,
            Status = "Active",
            ApiKey = apiKey,
            MonthlyCost = monthlyCost,
            PredictionsPerMonth = predictions,
            StartDate = DateTime.UtcNow,
            CurrentPeriodEnd = DateTime.UtcNow.AddMonths(1),
            Features = features.ToList()
        };
        
        return CreatedAtAction(nameof(ValidateSubscription), response);
    }
    
    [HttpPost("validate")]
    [ProducesResponseType(typeof(SubscriptionValidateResponse), StatusCodes.Status200OK)]
    public ActionResult<SubscriptionValidateResponse> ValidateSubscription([FromBody] SubscriptionValidateRequest request)
    {
        _logger.LogInformation("Validating subscription for {Identifier}", request.Identifier);
        
        if (request.Identifier.Contains("@"))
        {
            return Ok(new SubscriptionValidateResponse
            {
                IsValid = true,
                SubscriptionId = "sub_demo123",
                Plan = "Basic",
                Status = "Active",
                RemainingPredictions = 45,
                CurrentPeriodEnd = DateTime.UtcNow.AddDays(15)
            });
        }
        
        if (request.Identifier.StartsWith("sub_"))
        {
            return Ok(new SubscriptionValidateResponse
            {
                IsValid = true,
                SubscriptionId = request.Identifier,
                Plan = "Premium",
                Status = "Active",
                RemainingPredictions = -1,
                CurrentPeriodEnd = DateTime.UtcNow.AddDays(20)
            });
        }
        
        return Ok(new SubscriptionValidateResponse
        {
            IsValid = false,
            ErrorMessage = "No subscription found for the provided identifier"
        });
    }
}
