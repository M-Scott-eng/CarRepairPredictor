namespace CarPredictor.Api.DTOs.Responses;

public sealed class SubscriptionValidateResponse
{
    public bool IsValid { get; init; }
    public string? SubscriptionId { get; init; }
    public string? Plan { get; init; }
    public string? Status { get; init; }
    public int? RemainingPredictions { get; init; }
    public DateTime? CurrentPeriodEnd { get; init; }
    public string? ErrorMessage { get; init; }
}
