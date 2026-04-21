using System.ComponentModel.DataAnnotations;

namespace CarPredictor.Api.DTOs.Requests;

public sealed class PredictRequest
{
    [Required]
    [StringLength(50, MinimumLength = 2)]
    public required string Make { get; init; }
    
    [Required]
    [StringLength(100, MinimumLength = 1)]
    public required string Model { get; init; }
    
    [StringLength(20)]
    public string? Generation { get; init; }
    
    [Required]
    [Range(1990, 2030)]
    public int Year { get; init; }
    
    [Required]
    [Range(0, 500000)]
    public int Mileage { get; init; }
    
    [StringLength(20)]
    public string? EngineCode { get; init; }
    
    [StringLength(20)]
    public string? FuelType { get; init; }
    
    [StringLength(20)]
    public string? Transmission { get; init; }
    
    [StringLength(10)]
    public string? RegistrationNumber { get; init; }
    
    [StringLength(10)]
    public string RegionCode { get; init; } = "UK";
    
    public bool IncludeMotHistory { get; init; }
}
