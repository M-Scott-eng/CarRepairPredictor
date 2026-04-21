namespace CarPredictor.Rules.Models;

/// <summary>
/// Vehicle context for prediction evaluation.
/// </summary>
public sealed class VehicleContext
{
    /// <summary>Vehicle make (e.g., "BMW").</summary>
    public required string Make { get; init; }
    
    /// <summary>Vehicle model (e.g., "3 Series").</summary>
    public required string Model { get; init; }
    
    /// <summary>Model generation/variant (e.g., "E90").</summary>
    public string? Generation { get; init; }
    
    /// <summary>Registration/model year.</summary>
    public int Year { get; init; }
    
    /// <summary>Current mileage in miles.</summary>
    public int Mileage { get; init; }
    
    /// <summary>Engine code if known.</summary>
    public string? EngineCode { get; init; }
    
    /// <summary>Fuel type (Petrol, Diesel, Hybrid, Electric).</summary>
    public string? FuelType { get; init; }
    
    /// <summary>Transmission type (Manual, Automatic).</summary>
    public string? Transmission { get; init; }
    
    /// <summary>UK registration number for MOT lookup.</summary>
    public string? RegistrationNumber { get; init; }
    
    /// <summary>MOT test history if available.</summary>
    public List<MotTestResult>? MotHistory { get; init; }
}

/// <summary>
/// MOT test result for history-based predictions.
/// </summary>
public sealed class MotTestResult
{
    /// <summary>Test date.</summary>
    public DateTime TestDate { get; init; }
    
    /// <summary>Pass/Fail result.</summary>
    public bool Passed { get; init; }
    
    /// <summary>Mileage at test.</summary>
    public int? Mileage { get; init; }
    
    /// <summary>Defect codes found.</summary>
    public List<string>? DefectCodes { get; init; }
    
    /// <summary>Advisory items.</summary>
    public List<string>? Advisories { get; init; }
}

/// <summary>
/// Vehicle summary for result output.
/// </summary>
public sealed class VehicleSummary
{
    public required string Make { get; init; }
    public required string Model { get; init; }
    public string? Generation { get; init; }
    public int Year { get; init; }
    public int Mileage { get; init; }
    public string? FuelType { get; init; }
    public string? Transmission { get; init; }
    
    public string DisplayName => Generation is not null 
        ? $"{Year} {Make} {Model} ({Generation})"
        : $"{Year} {Make} {Model}";
}