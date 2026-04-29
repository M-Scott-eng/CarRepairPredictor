namespace CarPredictor.Api.DTOs.Responses;

/// <summary>
/// Stripe configuration for client-side integration.
/// </summary>
public sealed class StripeConfigResponse
{
    public required string PublishableKey { get; init; }
    public required StripePricesDto Prices { get; init; }
}

public sealed class StripePricesDto
{
    public required string BasicMonthly { get; init; }
    public required string BasicAnnual { get; init; }
    public required string PremiumMonthly { get; init; }
    public required string PremiumAnnual { get; init; }
}

/// <summary>
/// Response from creating a Checkout session.
/// </summary>
public sealed class CheckoutSessionResponse
{
    public required string SessionId { get; init; }
    public required string Url { get; init; }
}

/// <summary>
/// Response from creating a Portal session.
/// </summary>
public sealed class PortalSessionResponse
{
    public required string Url { get; init; }
}

/// <summary>
/// Subscription status information.
/// </summary>
public sealed class SubscriptionStatusResponse
{
    public bool IsActive { get; init; }
    public required string Plan { get; init; }
    public required string Status { get; init; }
    public string? SubscriptionId { get; init; }
    public string? CustomerId { get; init; }
    public DateTime? CurrentPeriodEnd { get; init; }
    public bool CancelAtPeriodEnd { get; init; }
}

/// <summary>
/// Response from cancelling a subscription.
/// </summary>
public sealed class SubscriptionCancelResponse
{
    public required string SubscriptionId { get; init; }
    public required string Status { get; init; }
    public bool CancelAtPeriodEnd { get; init; }
    public DateTime CurrentPeriodEnd { get; init; }
}
