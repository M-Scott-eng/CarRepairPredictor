namespace CarPredictor.Api.DTOs.Responses;

public sealed class PredictResponse
{
    public required string PredictionId { get; init; }
    public required VehicleDto Vehicle { get; init; }
    public decimal ReliabilityScore { get; init; }
    public required string ReliabilityGrade { get; init; }
    public required IReadOnlyList<FailurePredictionDto> PredictedFailures { get; init; }
    public decimal EstimatedTwelveMonthCost { get; init; }
    public decimal EstimatedThreeYearCost { get; init; }
    public decimal AnnualRepairCost { get; init; }
    public string Currency { get; init; } = "GBP";
    public string CurrencySymbol { get; init; } = "£";
    public int CommonIssueCount { get; init; }
    public DateTime GeneratedAt { get; init; }
}

public sealed class VehicleDto
{
    public required string Make { get; init; }
    public required string Model { get; init; }
    public string? Generation { get; init; }
    public int Year { get; init; }
    public int Mileage { get; init; }
    public string? FuelType { get; init; }
    public string? Transmission { get; init; }
    public required string DisplayName { get; init; }
}

public sealed class FailurePredictionDto
{
    public required string FailureName { get; init; }
    public required string Category { get; init; }
    public string? Description { get; init; }
    public decimal Probability { get; init; }
    public required string ProbabilityLevel { get; init; }
    public int Severity { get; init; }
    public required string SeverityText { get; init; }
    public decimal MinCost { get; init; }
    public decimal MaxCost { get; init; }
    public required string CostRange { get; init; }
}
