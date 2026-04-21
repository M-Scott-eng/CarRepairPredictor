namespace CarPredictor.Api.DTOs.Responses;

public sealed class SubscriptionCreateResponse
{
    public required string SubscriptionId { get; init; }
    public required string Email { get; init; }
    public required string Plan { get; init; }
    public required string Status { get; init; }
    public required string ApiKey { get; init; }
    public decimal MonthlyCost { get; init; }
    public int PredictionsPerMonth { get; init; }
    public DateTime StartDate { get; init; }
    public DateTime CurrentPeriodEnd { get; init; }
    public required IReadOnlyList<string> Features { get; init; }
}
