using System.Text.Json.Serialization;

namespace CarPredictor.External.Models;

/// <summary>
/// Response from the MOT History API containing vehicle and test history.
/// </summary>
public sealed class MotHistoryResponse
{
    [JsonPropertyName("registration")]
    public string Registration { get; init; } = string.Empty;
    
    [JsonPropertyName("make")]
    public string Make { get; init; } = string.Empty;
    
    [JsonPropertyName("model")]
    public string Model { get; init; } = string.Empty;
    
    [JsonPropertyName("firstUsedDate")]
    public string? FirstUsedDate { get; init; }
    
    [JsonPropertyName("fuelType")]
    public string? FuelType { get; init; }
    
    [JsonPropertyName("primaryColour")]
    public string? PrimaryColour { get; init; }
    
    [JsonPropertyName("registrationDate")]
    public string? RegistrationDate { get; init; }
    
    [JsonPropertyName("manufactureDate")]
    public string? ManufactureDate { get; init; }
    
    [JsonPropertyName("engineSize")]
    public string? EngineSize { get; init; }
    
    [JsonPropertyName("motTests")]
    public List<MotTest> MotTests { get; init; } = [];
}

/// <summary>
/// Individual MOT test record.
/// </summary>
public sealed class MotTest
{
    [JsonPropertyName("completedDate")]
    public string CompletedDate { get; init; } = string.Empty;
    
    [JsonPropertyName("testResult")]
    public string TestResult { get; init; } = string.Empty;
    
    [JsonPropertyName("expiryDate")]
    public string? ExpiryDate { get; init; }
    
    [JsonPropertyName("odometerValue")]
    public string? OdometerValue { get; init; }
    
    [JsonPropertyName("odometerUnit")]
    public string? OdometerUnit { get; init; }
    
    [JsonPropertyName("motTestNumber")]
    public string? MotTestNumber { get; init; }
    
    [JsonPropertyName("defects")]
    public List<MotDefect> Defects { get; init; } = [];
    
    [JsonPropertyName("rfrAndComments")]
    public List<MotDefect>? RfrAndComments { get; init; }
}

/// <summary>
/// MOT test defect or advisory.
/// </summary>
public sealed class MotDefect
{
    [JsonPropertyName("text")]
    public string Text { get; init; } = string.Empty;
    
    [JsonPropertyName("type")]
    public string Type { get; init; } = string.Empty;
    
    [JsonPropertyName("dangerous")]
    public bool? Dangerous { get; init; }
}

/// <summary>
/// Response from DVLA Vehicle Enquiry Service.
/// </summary>
public sealed class DvlaVehicleResponse
{
    [JsonPropertyName("registrationNumber")]
    public string RegistrationNumber { get; init; } = string.Empty;
    
    [JsonPropertyName("taxStatus")]
    public string? TaxStatus { get; init; }
    
    [JsonPropertyName("taxDueDate")]
    public string? TaxDueDate { get; init; }
    
    [JsonPropertyName("motStatus")]
    public string? MotStatus { get; init; }
    
    [JsonPropertyName("motExpiryDate")]
    public string? MotExpiryDate { get; init; }
    
    [JsonPropertyName("make")]
    public string Make { get; init; } = string.Empty;
    
    [JsonPropertyName("yearOfManufacture")]
    public int? YearOfManufacture { get; init; }
    
    [JsonPropertyName("engineCapacity")]
    public int? EngineCapacity { get; init; }
    
    [JsonPropertyName("co2Emissions")]
    public int? Co2Emissions { get; init; }
    
    [JsonPropertyName("fuelType")]
    public string? FuelType { get; init; }
    
    [JsonPropertyName("markedForExport")]
    public bool? MarkedForExport { get; init; }
    
    [JsonPropertyName("colour")]
    public string? Colour { get; init; }
    
    [JsonPropertyName("typeApproval")]
    public string? TypeApproval { get; init; }
    
    [JsonPropertyName("dateOfLastV5CIssued")]
    public string? DateOfLastV5CIssued { get; init; }
    
    [JsonPropertyName("wheelplan")]
    public string? Wheelplan { get; init; }
    
    [JsonPropertyName("monthOfFirstRegistration")]
    public string? MonthOfFirstRegistration { get; init; }
}

/// <summary>
/// Combined vehicle lookup result for frontend consumption.
/// </summary>
public sealed class VehicleLookupResult
{
    public string Registration { get; init; } = string.Empty;
    public string Make { get; init; } = string.Empty;
    public string Model { get; init; } = string.Empty;
    public int? Year { get; init; }
    public string? FuelType { get; init; }
    public string? Colour { get; init; }
    public int? EngineSize { get; init; }
    public string? TaxStatus { get; init; }
    public string? MotStatus { get; init; }
    public string? MotExpiryDate { get; init; }
    public int? CurrentMileage { get; init; }
    public List<MotTestSummary> MotHistory { get; init; } = [];
    public List<string> RecentDefects { get; init; } = [];
    public bool IsValid { get; init; }
    public bool IsDemo { get; init; }
    public string? ErrorMessage { get; init; }
}

/// <summary>
/// Simplified MOT test summary for frontend display.
/// </summary>
public sealed class MotTestSummary
{
    public DateTime TestDate { get; init; }
    public bool Passed { get; init; }
    public int? Mileage { get; init; }
    public int DefectCount { get; init; }
    public int AdvisoryCount { get; init; }
    public List<string> Defects { get; init; } = [];
    public List<string> Advisories { get; init; } = [];
}

/// <summary>
/// OAuth2 token response from the Microsoft identity platform.
/// </summary>
public sealed class OAuth2TokenResponse
{
    [JsonPropertyName("access_token")]
    public string AccessToken { get; init; } = string.Empty;
    
    [JsonPropertyName("token_type")]
    public string TokenType { get; init; } = string.Empty;
    
    [JsonPropertyName("expires_in")]
    public int ExpiresIn { get; init; }
    
    [JsonPropertyName("ext_expires_in")]
    public int? ExtExpiresIn { get; init; }
}