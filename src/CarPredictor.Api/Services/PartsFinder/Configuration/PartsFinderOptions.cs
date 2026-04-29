using System.Collections.Generic;

namespace CarPredictor.Api.Services.PartsFinder.Configuration;

public sealed class PartsFinderOptions
{
    public const string SectionName = "PartsFinder";

    public int DefaultCacheTtlMinutes { get; set; } = 30;
    public int MaxConcurrentRequests { get; set; } = 4;
    public int SupplierTimeoutSeconds { get; set; } = 10;
    public int MaxResultsPerSupplier { get; set; } = 25;
    public Dictionary<string, SupplierOptions> Suppliers { get; set; } = new();
}

public sealed class SupplierOptions
{
    public bool Enabled { get; set; } = true;
    public int Priority { get; set; } = 100;
    public string? ApiKey { get; set; }
    public string? ApiSecret { get; set; }
    public string? AffiliateId { get; set; }
    public int RequestsPerMinute { get; set; } = 60;
    public int CacheTtlMinutes { get; set; } = 30;
}

public static class SupplierIds
{
    public const string EBay = "ebay";
    public const string Amazon = "amazon";
    public const string Autodoc = "autodoc";
    public const string RockAuto = "rockauto";
    public const string EuroCarParts = "eurocarparts";
    public const string GsfCarParts = "gsfcarparts";
    public const string Demo = "demo";
}