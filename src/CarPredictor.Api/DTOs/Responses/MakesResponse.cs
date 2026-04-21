namespace CarPredictor.Api.DTOs.Responses;

/// <summary>
/// Response model for list of vehicle makes.
/// </summary>
public sealed class MakesResponse
{
    /// <summary>List of vehicle makes.</summary>
    public required IReadOnlyList<MakeDto> Makes { get; init; }
    
    /// <summary>Total count of makes.</summary>
    /// <example>25</example>
    public int TotalCount { get; init; }
}

/// <summary>
/// Vehicle make information.
/// </summary>
public sealed class MakeDto
{
    /// <summary>Unique make ID.</summary>
    /// <example>1</example>
    public int Id { get; init; }
    
    /// <summary>Make name.</summary>
    /// <example>BMW</example>
    public required string Name { get; init; }
    
    /// <summary>Country of origin.</summary>
    /// <example>Germany</example>
    public string? Country { get; init; }
    
    /// <summary>Logo URL.</summary>
    public string? LogoUrl { get; init; }
    
    /// <summary>Number of models available.</summary>
    /// <example>12</example>
    public int ModelCount { get; init; }
}
