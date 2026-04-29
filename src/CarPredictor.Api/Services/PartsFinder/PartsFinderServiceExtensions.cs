using System.Net.Http;
using CarPredictor.Api.Services.PartsFinder.Adapters;
using CarPredictor.Api.Services.PartsFinder.Configuration;
using CarPredictor.Api.Services.PartsFinder.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace CarPredictor.Api.Services.PartsFinder;

public static class PartsFinderServiceExtensions
{
    public static IServiceCollection AddPartsFinder(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<PartsFinderOptions>(configuration.GetSection(PartsFinderOptions.SectionName));
        services.AddMemoryCache();
        services.AddSingleton<IPartsCacheService, PartsCacheService>();
        services.AddSingleton<IRateLimiterService, RateLimiterService>();
        services.AddScoped<IPartsFinderService, PartsFinderService>();

        services.AddHttpClient("PartsFinder");

        // Register demo supplier adapters for development
        services.AddScoped<ISupplierAdapter>(sp =>
        {
            var http = sp.GetRequiredService<IHttpClientFactory>().CreateClient("PartsFinder");
            var opts = sp.GetRequiredService<IOptions<PartsFinderOptions>>();
            var logger = sp.GetRequiredService<ILogger<DemoSupplierAdapter>>();
            return new DemoSupplierAdapter(http, opts, logger, SupplierIds.EBay, "eBay UK");
        });

        services.AddScoped<ISupplierAdapter>(sp =>
        {
            var http = sp.GetRequiredService<IHttpClientFactory>().CreateClient("PartsFinder");
            var opts = sp.GetRequiredService<IOptions<PartsFinderOptions>>();
            var logger = sp.GetRequiredService<ILogger<DemoSupplierAdapter>>();
            return new DemoSupplierAdapter(http, opts, logger, SupplierIds.Amazon, "Amazon UK");
        });

        services.AddScoped<ISupplierAdapter>(sp =>
        {
            var http = sp.GetRequiredService<IHttpClientFactory>().CreateClient("PartsFinder");
            var opts = sp.GetRequiredService<IOptions<PartsFinderOptions>>();
            var logger = sp.GetRequiredService<ILogger<DemoSupplierAdapter>>();
            return new DemoSupplierAdapter(http, opts, logger, SupplierIds.Autodoc, "Autodoc");
        });

        services.AddScoped<ISupplierAdapter>(sp =>
        {
            var http = sp.GetRequiredService<IHttpClientFactory>().CreateClient("PartsFinder");
            var opts = sp.GetRequiredService<IOptions<PartsFinderOptions>>();
            var logger = sp.GetRequiredService<ILogger<DemoSupplierAdapter>>();
            return new DemoSupplierAdapter(http, opts, logger, SupplierIds.RockAuto, "RockAuto");
        });

        return services;
    }
}