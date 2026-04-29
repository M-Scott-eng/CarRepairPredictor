namespace CarPredictor.Api.DTOs.Responses;

/// <summary>
/// Response model for a saved prediction report.
/// </summary>
public sealed class ReportResponse
{
    /// <summary>Unique report ID.</summary>
    /// <example>rpt_abc123xyz</example>
    public required string ReportId { get; init; }
    
    /// <summary>User ID who created the report.</summary>
    public string? UserId { get; init; }
    
    /// <summary>Report title.</summary>
    /// <example>2010 BMW 3 Series E90 Assessment</example>
    public required string Title { get; init; }
    
    /// <summary>The prediction data.</summary>
    public required PredictResponse Prediction { get; init; }
    
    /// <summary>User notes on the report.</summary>
    public string? Notes { get; init; }
    
    /// <summary>When the report was created.</summary>
    public DateTime CreatedAt { get; init; }
    
    /// <summary>When the report expires (for free users).</summary>
    public DateTime? ExpiresAt { get; init; }
    
    /// <summary>Whether the report can be shared publicly.</summary>
    public bool IsPublic { get; init; }
    
    /// <summary>Public share URL if shared.</summary>
    public string? ShareUrl { get; init; }
}
