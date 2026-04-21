namespace CarPredictor.Rules.Models;

public sealed class FailurePrediction
{
    public required string FailureName { get; init; }
    public required string Category { get; init; }
    public string? Description { get; init; }
    public decimal Probability { get; init; }
    public string ProbabilityText => $"{Math.Round(Probability, 1)}%";
    public string ProbabilityLevel => Probability switch
    {
        < 10 => "Low",
        < 25 => "Medium",
        < 50 => "High",
        _ => "Very High"
    };
    public int Severity { get; init; }
    public string SeverityText => Severity switch
    {
        1 => "Low",
        2 => "Medium",
        3 => "High",
        4 => "Critical",
        _ => "Unknown"
    };
    public decimal MinCost { get; init; }
    public decimal MaxCost { get; init; }
    public decimal AvgCost { get; init; }
    public string Currency { get; init; } = "GBP";
    private string CurrencySymbol => Currency switch
    {
        "GBP" => "£",
        "USD" => "$",
        "EUR" => "€",
        _ => Currency
    };
    public string CostRange => MinCost == MaxCost 
        ? $"{CurrencySymbol}{MinCost:N0}" 
        : $"{CurrencySymbol}{MinCost:N0} - {CurrencySymbol}{MaxCost:N0}";
}
