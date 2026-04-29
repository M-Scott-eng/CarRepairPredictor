using Stripe.Checkout;

namespace CarPredictor.Api.Services;

/// <summary>
/// Service interface for Stripe payment operations.
/// </summary>
public interface IStripeService
{
    /// <summary>
    /// Creates a Stripe Checkout session for subscription.
    /// </summary>
    Task<Session> CreateCheckoutSessionAsync(
        string email,
        string priceId,
        string successUrl,
        string cancelUrl,
        CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Creates a customer portal session for subscription management.
    /// </summary>
    Task<Stripe.BillingPortal.Session> CreatePortalSessionAsync(
        string customerId,
        string returnUrl,
        CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Retrieves subscription details by ID.
    /// </summary>
    Task<Stripe.Subscription?> GetSubscriptionAsync(
        string subscriptionId,
        CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Cancels a subscription at period end.
    /// </summary>
    Task<Stripe.Subscription> CancelSubscriptionAsync(
        string subscriptionId,
        CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gets customer by email.
    /// </summary>
    Task<Stripe.Customer?> GetCustomerByEmailAsync(
        string email,
        CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Validates and parses a Stripe webhook event.
    /// </summary>
    Stripe.Event ConstructWebhookEvent(string json, string signature);
}