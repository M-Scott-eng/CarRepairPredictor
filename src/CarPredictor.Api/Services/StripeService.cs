using CarPredictor.Api.Configuration;
using Microsoft.Extensions.Options;
using Stripe;
using Stripe.Checkout;

namespace CarPredictor.Api.Services;

/// <summary>
/// Stripe service implementation for payment operations.
/// </summary>
public sealed class StripeService : IStripeService
{
    private readonly StripeSettings _settings;
    private readonly ILogger<StripeService> _logger;

    public StripeService(IOptions<StripeSettings> settings, ILogger<StripeService> logger)
    {
        _settings = settings.Value;
        _logger = logger;
        
        StripeConfiguration.ApiKey = _settings.SecretKey;
    }

    public async Task<Session> CreateCheckoutSessionAsync(
        string email,
        string priceId,
        string successUrl,
        string cancelUrl,
        CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Creating checkout session for {Email} with price {PriceId}", email, priceId);

        var options = new SessionCreateOptions
        {
            Mode = "subscription",
            CustomerEmail = email,
            SuccessUrl = successUrl,
            CancelUrl = cancelUrl,
            LineItems = new List<SessionLineItemOptions>
            {
                new()
                {
                    Price = priceId,
                    Quantity = 1
                }
            },
            SubscriptionData = new SessionSubscriptionDataOptions
            {
                Metadata = new Dictionary<string, string>
                {
                    { "email", email }
                }
            },
            AllowPromotionCodes = true
        };

        var service = new SessionService();
        var session = await service.CreateAsync(options, cancellationToken: cancellationToken);

        _logger.LogInformation("Created checkout session {SessionId} for {Email}", session.Id, email);
        return session;
    }

    public async Task<Stripe.BillingPortal.Session> CreatePortalSessionAsync(
        string customerId,
        string returnUrl,
        CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Creating portal session for customer {CustomerId}", customerId);

        var options = new Stripe.BillingPortal.SessionCreateOptions
        {
            Customer = customerId,
            ReturnUrl = returnUrl
        };

        var service = new Stripe.BillingPortal.SessionService();
        return await service.CreateAsync(options, cancellationToken: cancellationToken);
    }

    public async Task<Subscription?> GetSubscriptionAsync(
        string subscriptionId,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var service = new SubscriptionService();
            return await service.GetAsync(subscriptionId, cancellationToken: cancellationToken);
        }
        catch (StripeException ex) when (ex.StripeError?.Code == "resource_missing")
        {
            _logger.LogWarning("Subscription {SubscriptionId} not found", subscriptionId);
            return null;
        }
    }

    public async Task<Subscription> CancelSubscriptionAsync(
        string subscriptionId,
        CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Cancelling subscription {SubscriptionId} at period end", subscriptionId);

        var options = new SubscriptionUpdateOptions
        {
            CancelAtPeriodEnd = true
        };

        var service = new SubscriptionService();
        return await service.UpdateAsync(subscriptionId, options, cancellationToken: cancellationToken);
    }

    public async Task<Customer?> GetCustomerByEmailAsync(
        string email,
        CancellationToken cancellationToken = default)
    {
        var service = new CustomerService();
        var options = new CustomerListOptions
        {
            Email = email,
            Limit = 1
        };

        var customers = await service.ListAsync(options, cancellationToken: cancellationToken);
        return customers.Data.FirstOrDefault();
    }

    public Event ConstructWebhookEvent(string json, string signature)
    {
        return EventUtility.ConstructEvent(json, signature, _settings.WebhookSecret);
    }
}