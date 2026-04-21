using System.Text.Json.Serialization;

namespace CarPredictor.Rules.Models;

/// <summary>
/// JSON-serializable rule definition.
/// </summary>
public sealed class RuleDefinition
{
    [JsonPropertyName("ruleId")]
    public required string RuleId { get; init; }
    
    [JsonPropertyName("ruleName")]
    public required string RuleName { get; init; }
    
    [JsonPropertyName("description")]
    public string? Description { get; init; }
    
    [JsonPropertyName("category")]
    public required string Category { get; init; }
    
    [JsonPropertyName("vehicleMatch")]
    public required VehicleMatchCriteria VehicleMatch { get; init; }
    
    [JsonPropertyName("conditions")]
    public required RuleConditions Conditions { get; init; }
    
    [JsonPropertyName("probability")]
    public required ProbabilitySettings Probability { get; init; }
    
    [JsonPropertyName("costs")]
    public required Dictionary<string, CostEstimate> Costs { get; init; }
    
    [JsonPropertyName("severity")]
    public int Severity { get; init; }
    
    [JsonPropertyName("isRecall")]
    public bool IsRecall { get; init; }
    
    [JsonPropertyName("dataSource")]
    public string? DataSource { get; init; }
    
    [JsonPropertyName("confidence")]
    public decimal? Confidence { get; init; }
    
    [JsonPropertyName("isActive")]
    public bool IsActive { get; init; } = true;
    
    [JsonPropertyName("motDefectCodes")]
    public List<string>? MotDefectCodes { get; init; }
}

public sealed class VehicleMatchCriteria
{
    [JsonPropertyName("make")]
    public string? Make { get; init; }
    
    [JsonPropertyName("model")]
    public string? Model { get; init; }
    
    [JsonPropertyName("generation")]
    public string? Generation { get; init; }
    
    [JsonPropertyName("yearMin")]
    public int? YearMin { get; init; }
    
    [JsonPropertyName("yearMax")]
    public int? YearMax { get; init; }
    
    [JsonPropertyName("engineCodes")]
    public List<string>? EngineCodes { get; init; }
    
    [JsonPropertyName("fuelTypes")]
    public List<string>? FuelTypes { get; init; }
    
    [JsonPropertyName("transmissions")]
    public List<string>? Transmissions { get; init; }
}

public sealed class RuleConditions
{
    [JsonPropertyName("mileageMin")]
    public int? MileageMin { get; init; }
    
    [JsonPropertyName("mileageMax")]
    public int? MileageMax { get; init; }
    
    [JsonPropertyName("ageMin")]
    public int? AgeMin { get; init; }
    
    [JsonPropertyName("ageMax")]
    public int? AgeMax { get; init; }
    
    [JsonPropertyName("peakMileage")]
    public int? PeakMileage { get; init; }
    
    [JsonPropertyName("motTriggerCodes")]
    public List<string>? MotTriggerCodes { get; init; }
}

public sealed class ProbabilitySettings
{
    [JsonPropertyName("base")]
    public decimal Base { get; init; }
    
    [JsonPropertyName("mileageMultiplier")]
    public decimal? MileageMultiplier { get; init; }
    
    [JsonPropertyName("ageMultiplier")]
    public decimal? AgeMultiplier { get; init; }
    
    [JsonPropertyName("motBoost")]
    public decimal? MotBoost { get; init; }
    
    [JsonPropertyName("maxProbability")]
    public decimal MaxProbability { get; init; } = 0.95m;
}

public sealed class CostEstimate
{
    [JsonPropertyName("partsMin")]
    public decimal PartsMin { get; init; }
    
    [JsonPropertyName("partsMax")]
    public decimal PartsMax { get; init; }
    
    [JsonPropertyName("labourHoursMin")]
    public decimal LabourHoursMin { get; init; }
    
    [JsonPropertyName("labourHoursMax")]
    public decimal LabourHoursMax { get; init; }
    
    [JsonPropertyName("labourRate")]
    public decimal? LabourRate { get; init; }
}