namespace CarPredictor.Api.DTOs.Responses;

/// <summary>
/// Response model for list of vehicle models.
/// </summary>
public sealed class ModelsResponse
{
    /// <summary>Make ID these models belong to.</summary>
    /// <example>1</example>
    public int MakeId { get; init; }
    
    /// <summary>Make name.</summary>
    /// <example>BMW</example>
    public required string MakeName { get; init; }
    
    /// <summary>List of models.</summary>
    public required IReadOnlyList<ModelDto> Models { get; init; }
    
    /// <summary>Total count of models.</summary>
    /// <example>12</example>
    public int TotalCount { get; init; }
}

/// <summary>
/// Vehicle model information.
/// </summary>
public sealed class ModelDto
{
    /// <summary>Unique model ID.</summary>
    /// <example>101</example>
    public int Id { get; init; }
    
    /// <summary>Model name.</summary>
    /// <example>3 Series</example>
    public required string Name { get; init; }
    
    /// <summary>Model generations available.</summary>
    public required IReadOnlyList<GenerationDto> Generations { get; init; }
    
    /// <summary>Year range available.</summary>
    /// <example>2005-2012</example>
    public string? YearRange { get; init; }
}

/// <summary>
/// Model generation/variant information.
/// </summary>
public sealed class GenerationDto
{
    /// <summary>Generation code.</summary>
    /// <example>E90</example>
    public required string Code { get; init; }
    
    /// <summary>Generation name.</summary>
    /// <example>E90/E91/E92/E93</example>
    public required string Name { get; init; }
    
    /// <summary>Start year.</summary>
    /// <example>2005</example>
    public int StartYear { get; init; }
    
    /// <summary>End year.</summary>
    /// <example>2012</example>
    public int EndYear { get; init; }
}
