using System.ComponentModel.DataAnnotations;

namespace CarPredictor.Api.DTOs.Requests;

public sealed class SubscriptionCreateRequest
{
    [Required]
    [EmailAddress]
    [StringLength(255)]
    public required string Email { get; init; }
    
    [Required]
    [StringLength(20)]
    public required string Plan { get; init; }
    
    public string? PaymentMethodToken { get; init; }
    
    [StringLength(20)]
    public string? PromoCode { get; init; }
}
