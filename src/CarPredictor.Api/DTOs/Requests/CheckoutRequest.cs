using System.ComponentModel.DataAnnotations;

namespace CarPredictor.Api.DTOs.Requests;

/// <summary>
/// Request to create a Stripe Checkout session.
/// </summary>
public sealed class CheckoutRequest
{
    [Required]
    [EmailAddress]
    public required string Email { get; init; }
    
    [Required]
    public required string Plan { get; init; }
    
    public bool Annual { get; init; }
    
    public string? SuccessUrl { get; init; }
    
    public string? CancelUrl { get; init; }
}

/// <summary>
/// Request to create a Customer Portal session.
/// </summary>
public sealed class PortalRequest
{
    [Required]
    [EmailAddress]
    public required string Email { get; init; }
    
    public string? ReturnUrl { get; init; }
}

/// <summary>
/// Request to cancel a subscription.
/// </summary>
public sealed class CancelSubscriptionRequest
{
    [Required]
    public required string SubscriptionId { get; init; }
}