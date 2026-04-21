namespace CarPredictor.Rules.Models;

public sealed class PredictionResult
{
    public required VehicleSummary Vehicle { get; init; }
    public decimal ReliabilityScore { get; init; }
    public string ReliabilityGrade => ReliabilityScore switch
    {
        >= 90 => "A",
        >= 75 => "B",
        >= 60 => "C",
        >= 45 => "D",
        _ => "F"
    };
    public required IReadOnlyList<FailurePrediction> Failures { get; init; }
    public decimal TwelveMonthCost { get; init; }
    public decimal ThreeYearCost { get; init; }
    public decimal AnnualRepairCost => ThreeYearCost / 3;
    public string Currency { get; init; } = "GBP";
    public int CommonIssueCount => Failures.Count(f => f.Probability >= 15);
}
