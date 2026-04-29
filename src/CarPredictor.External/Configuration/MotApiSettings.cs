namespace CarPredictor.External.Configuration;

/// <summary>
/// Configuration settings for UK Government vehicle APIs.
/// </summary>
public sealed class MotApiSettings
{
    public const string SectionName = "MotApi";
    
    /// <summary>
    /// API key for MOT History API (from DVSA) - used in x-api-key header.
    /// </summary>
    public string MotHistoryApiKey { get; init; } = string.Empty;
    
    /// <summary>
    /// OAuth2 Client ID for MOT History API authentication.
    /// </summary>
    public string ClientId { get; init; } = string.Empty;
    
    /// <summary>
    /// OAuth2 Client Secret for MOT History API authentication.
    /// </summary>
    public string ClientSecret { get; init; } = string.Empty;
    
    /// <summary>
    /// OAuth2 Token URL for obtaining access tokens.
    /// </summary>
    public string TokenUrl { get; init; } = string.Empty;
    
    /// <summary>
    /// OAuth2 Scope for MOT History API.
    /// </summary>
    public string Scope { get; init; } = string.Empty;
    
    /// <summary>
    /// API key for DVLA Vehicle Enquiry Service.
    /// </summary>
    public string DvlaApiKey { get; init; } = string.Empty;
    
    /// <summary>
    /// Base URL for MOT History API (DVSA Trade API).
    /// </summary>
    public string MotHistoryBaseUrl { get; init; } = "https://tapi.dvsa.gov.uk";
    
    /// <summary>
    /// Base URL for DVLA VES API.
    /// </summary>
    public string DvlaBaseUrl { get; init; } = "https://driver-vehicle-licensing.api.gov.uk";
    
    /// <summary>
    /// Request timeout in seconds.
    /// </summary>
    public int TimeoutSeconds { get; init; } = 30;
    
    /// <summary>
    /// Enable caching of API responses.
    /// </summary>
    public bool EnableCaching { get; init; } = true;
    
    /// <summary>
    /// Cache TTL in minutes for vehicle lookups.
    /// </summary>
    public int CacheTtlMinutes { get; init; } = 60;
    
    /// <summary>
    /// Checks if OAuth2 credentials are configured for MOT History API.
    /// </summary>
    public bool HasMotOAuth2Credentials => 
        !string.IsNullOrWhiteSpace(ClientId) && 
        !string.IsNullOrWhiteSpace(ClientSecret) &&
        !string.IsNullOrWhiteSpace(TokenUrl);
}