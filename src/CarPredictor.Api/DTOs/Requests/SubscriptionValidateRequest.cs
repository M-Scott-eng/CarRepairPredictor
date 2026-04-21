using System.ComponentModel.DataAnnotations;

namespace CarPredictor.Api.DTOs.Requests;

public sealed class SubscriptionValidateRequest
{
    [Required]
    [StringLength(255)]
    public required string Identifier { get; init; }
    
    [StringLength(64)]
    public string? ApiKey { get; init; }
}
