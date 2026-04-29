using CarPredictor.External.Configuration;
using CarPredictor.External.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace CarPredictor.External;

/// <summary>
/// Extension methods for registering external API services.
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Adds the vehicle lookup services (MOT History API, DVLA API).
    /// </summary>
    public static IServiceCollection AddVehicleLookup(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // Bind configuration
        services.Configure<MotApiSettings>(
            configuration.GetSection(MotApiSettings.SectionName));

        var settings = configuration
            .GetSection(MotApiSettings.SectionName)
            .Get<MotApiSettings>() ?? new MotApiSettings();

        // Configure HTTP clients
        services.AddHttpClient("MotHistory", client =>
        {
            client.BaseAddress = new Uri(settings.MotHistoryBaseUrl);
            client.Timeout = TimeSpan.FromSeconds(settings.TimeoutSeconds);
            client.DefaultRequestHeaders.Add("Accept", "application/json+v6");
        });

        services.AddHttpClient("DvlaVes", client =>
        {
            client.BaseAddress = new Uri(settings.DvlaBaseUrl);
            client.Timeout = TimeSpan.FromSeconds(settings.TimeoutSeconds);
            client.DefaultRequestHeaders.Add("Accept", "application/json");
        });
        
        // HTTP client for OAuth2 token requests
        services.AddHttpClient("OAuth2Token", client =>
        {
            client.Timeout = TimeSpan.FromSeconds(30);
            client.DefaultRequestHeaders.Add("Accept", "application/json");
        });

        // Register services
        services.AddScoped<IVehicleLookupService, VehicleLookupService>();

        return services;
    }
}