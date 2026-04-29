namespace CarPredictor.Api.Configuration;

/// <summary>
/// Stripe configuration settings.
/// </summary>
public sealed class StripeSettings
{
    public const string SectionName = "Stripe";
    
    public required string SecretKey { get; init; }
    public required string PublishableKey { get; init; }
    public required string WebhookSecret { get; init; }
    public required StripePriceIds PriceIds { get; init; }
    public required StripeProducts Products { get; init; }
}

public sealed class StripePriceIds
{
    public required string BasicMonthly { get; init; }
    public required string BasicAnnual { get; init; }
    public required string PremiumMonthly { get; init; }
    public required string PremiumAnnual { get; init; }
    public required string BuyersReport { get; init; }
    
    public string? GetPriceId(string plan, bool annual)
    {
        return plan.ToLowerInvariant() switch
        {
            "basic" => annual ? BasicAnnual : BasicMonthly,
            "premium" => annual ? PremiumAnnual : PremiumMonthly,
            _ => null
        };
    }
    
    public string? GetSubscriptionPriceId(bool annual)
    {
        return annual ? PremiumAnnual : PremiumMonthly;
    }
}

public sealed class StripeProducts
{
    public decimal BuyersReportPrice { get; init; } = 1.99m;
    public decimal PremiumMonthlyPrice { get; init; } = 4.99m;
    public decimal PremiumAnnualPrice { get; init; } = 39.99m;
}

/// <summary>
/// Monetisation configuration settings.
/// </summary>
public sealed class MonetisationSettings
{
    public const string SectionName = "Monetisation";
    
    public int FreeSearchesPerMonth { get; init; } = 5;
    public int FreeReportsPerMonth { get; init; } = 0;
    public int PremiumReportsPerMonth { get; init; } = 3;
    public bool ShowAdsToFreeUsers { get; init; } = true;
    public required AffiliateNetworksSettings AffiliateNetworks { get; init; }
}

public sealed class AffiliateNetworksSettings
{
    public required AffiliateSettings Amazon { get; init; }
    public required AffiliateSettings eBay { get; init; }
    public required AffiliateSettings Autodoc { get; init; }
    public required AffiliateSettings RockAuto { get; init; }
}

public sealed class AffiliateSettings
{
    public string AssociateId { get; init; } = string.Empty;
    public string CampaignId { get; init; } = string.Empty;
    public string AwinId { get; init; } = string.Empty;
    public string AffiliateId { get; init; } = string.Empty;
    public required string TrackingId { get; init; }
}
