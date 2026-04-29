using CarPredictor.Api.Configuration;
using CarPredictor.Api.DTOs.Requests;
using CarPredictor.Api.DTOs.Responses;
using CarPredictor.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

namespace CarPredictor.Api.Controllers;

/// <summary>
/// Endpoints for subscription management with Stripe integration.
/// </summary>
[ApiController]
[Route("api/v1/subscription")]
[Produces("application/json")]
public class SubscriptionController : ControllerBase
{
    private readonly IStripeService _stripeService;
    private readonly StripeSettings _stripeSettings;
    private readonly ILogger<SubscriptionController> _logger;
    
    public SubscriptionController(
        IStripeService stripeService,
        IOptions<StripeSettings> stripeSettings,
        ILogger<SubscriptionController> logger)
    {
        _stripeService = stripeService;
        _stripeSettings = stripeSettings.Value;
        _logger = logger;
    }
    
    /// <summary>
    /// Gets the Stripe publishable key for client-side integration.
    /// </summary>
    [HttpGet("config")]
    [ProducesResponseType(typeof(StripeConfigResponse), StatusCodes.Status200OK)]
    public ActionResult<StripeConfigResponse> GetConfig()
    {
        return Ok(new StripeConfigResponse
        {
            PublishableKey = _stripeSettings.PublishableKey,
            Prices = new StripePricesDto
            {
                BasicMonthly = _stripeSettings.PriceIds.BasicMonthly,
                BasicAnnual = _stripeSettings.PriceIds.BasicAnnual,
                PremiumMonthly = _stripeSettings.PriceIds.PremiumMonthly,
                PremiumAnnual = _stripeSettings.PriceIds.PremiumAnnual
            }
        });
    }
    
    /// <summary>
    /// Creates a Stripe Checkout session for subscription.
    /// </summary>
    [HttpPost("checkout")]
    [ProducesResponseType(typeof(CheckoutSessionResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponseDto), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<CheckoutSessionResponse>> CreateCheckoutSession(
        [FromBody] CheckoutRequest request,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Creating checkout session for {Email} with plan {Plan}", request.Email, request.Plan);
        
        var priceId = _stripeSettings.PriceIds.GetPriceId(request.Plan, request.Annual);
        if (priceId is null)
        {
            return BadRequest(new ErrorResponseDto
            {
                Error = "InvalidPlan",
                Message = $"Plan '{request.Plan}' is not valid. Choose from: Basic, Premium"
            });
        }
        
        var baseUrl = $"{Request.Scheme}://{Request.Host}";
        var successUrl = request.SuccessUrl ?? $"{baseUrl}/subscription/success?session_id={{CHECKOUT_SESSION_ID}}";
        var cancelUrl = request.CancelUrl ?? $"{baseUrl}/pricing";
        
        var session = await _stripeService.CreateCheckoutSessionAsync(
            request.Email,
            priceId,
            successUrl,
            cancelUrl,
            cancellationToken);
        
        return Ok(new CheckoutSessionResponse
        {
            SessionId = session.Id,
            Url = session.Url
        });
    }
    
    /// <summary>
    /// Creates a Stripe Customer Portal session for subscription management.
    /// </summary>
    [HttpPost("portal")]
    [ProducesResponseType(typeof(PortalSessionResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponseDto), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<PortalSessionResponse>> CreatePortalSession(
        [FromBody] PortalRequest request,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Creating portal session for {Email}", request.Email);
        
        var customer = await _stripeService.GetCustomerByEmailAsync(request.Email, cancellationToken);
        if (customer is null)
        {
            return NotFound(new ErrorResponseDto
            {
                Error = "CustomerNotFound",
                Message = "No subscription found for this email address"
            });
        }
        
        var returnUrl = request.ReturnUrl ?? $"{Request.Scheme}://{Request.Host}/account";
        var session = await _stripeService.CreatePortalSessionAsync(customer.Id, returnUrl, cancellationToken);
        
        return Ok(new PortalSessionResponse
        {
            Url = session.Url
        });
    }
    
    /// <summary>
    /// Gets subscription status for an email address.
    /// </summary>
    [HttpGet("status")]
    [ProducesResponseType(typeof(SubscriptionStatusResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<SubscriptionStatusResponse>> GetSubscriptionStatus(
        [FromQuery] string email,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Checking subscription status for {Email}", email);
        
        var customer = await _stripeService.GetCustomerByEmailAsync(email, cancellationToken);
        if (customer is null)
        {
            return Ok(new SubscriptionStatusResponse
            {
                IsActive = false,
                Plan = "Free",
                Status = "none"
            });
        }
        
        // Get active subscriptions from Stripe
        var subscriptionService = new Stripe.SubscriptionService();
        var subscriptions = await subscriptionService.ListAsync(new Stripe.SubscriptionListOptions
        {
            Customer = customer.Id,
            Status = "active",
            Limit = 1
        }, cancellationToken: cancellationToken);
        
        var subscription = subscriptions.Data.FirstOrDefault();
        if (subscription is null)
        {
            return Ok(new SubscriptionStatusResponse
            {
                IsActive = false,
                Plan = "Free",
                Status = "none",
                CustomerId = customer.Id
            });
        }
        
        var priceId = subscription.Items.Data.FirstOrDefault()?.Price.Id;
        var plan = GetPlanFromPriceId(priceId);
        
        return Ok(new SubscriptionStatusResponse
        {
            IsActive = true,
            Plan = plan,
            Status = subscription.Status,
            SubscriptionId = subscription.Id,
            CustomerId = customer.Id,
            CurrentPeriodEnd = null, // Period end available through Stripe dashboard
            CancelAtPeriodEnd = subscription.CancelAtPeriodEnd
        });
    }
    
    /// <summary>
    /// Cancels a subscription at period end.
    /// </summary>
    [HttpPost("cancel")]
    [ProducesResponseType(typeof(SubscriptionCancelResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponseDto), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<SubscriptionCancelResponse>> CancelSubscription(
        [FromBody] CancelSubscriptionRequest request,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Cancelling subscription {SubscriptionId}", request.SubscriptionId);
        
        var subscription = await _stripeService.GetSubscriptionAsync(request.SubscriptionId, cancellationToken);
        if (subscription is null)
        {
            return NotFound(new ErrorResponseDto
            {
                Error = "SubscriptionNotFound",
                Message = "Subscription not found"
            });
        }
        
        var updated = await _stripeService.CancelSubscriptionAsync(request.SubscriptionId, cancellationToken);
        
        return Ok(new SubscriptionCancelResponse
        {
            SubscriptionId = updated.Id,
            Status = updated.Status,
            CancelAtPeriodEnd = updated.CancelAtPeriodEnd,
            CurrentPeriodEnd = DateTime.UtcNow.AddMonths(1) // Approximate - actual date in Stripe dashboard
        });
    }
    
    private string GetPlanFromPriceId(string? priceId)
    {
        if (priceId == _stripeSettings.PriceIds.BasicMonthly || 
            priceId == _stripeSettings.PriceIds.BasicAnnual)
            return "Basic";
        
        if (priceId == _stripeSettings.PriceIds.PremiumMonthly || 
            priceId == _stripeSettings.PriceIds.PremiumAnnual)
            return "Premium";
        
        return "Unknown";
    }
}
