using System.Text.Json;
using CarPredictor.Rules.Interfaces;
using CarPredictor.Rules.Models;
using Microsoft.Extensions.Logging;

namespace CarPredictor.Rules.Providers;

public sealed class JsonRuleProvider : IRuleProvider
{
    private readonly ILogger<JsonRuleProvider> _logger;
    private readonly List<RuleDefinition> _rules = new();
    private bool _isLoaded;
    
    public JsonRuleProvider(ILogger<JsonRuleProvider> logger)
    {
        _logger = logger;
    }
    
    public async Task<IReadOnlyList<RuleDefinition>> GetActiveRulesAsync()
    {
        await EnsureLoadedAsync();
        return _rules.Where(r => r.IsActive).ToList().AsReadOnly();
    }
    
    public async Task<IReadOnlyList<RuleDefinition>> GetRulesForVehicleAsync(string make, string? model = null)
    {
        await EnsureLoadedAsync();
        return _rules.Where(r => 
            r.IsActive &&
            (string.IsNullOrEmpty(r.VehicleMatch.Make) || 
             string.Equals(r.VehicleMatch.Make, make, StringComparison.OrdinalIgnoreCase)) &&
            (model is null || string.IsNullOrEmpty(r.VehicleMatch.Model) || 
             string.Equals(r.VehicleMatch.Model, model, StringComparison.OrdinalIgnoreCase))
        ).ToList().AsReadOnly();
    }
    
    public async Task<RuleDefinition?> GetRuleByIdAsync(string ruleId)
    {
        await EnsureLoadedAsync();
        return _rules.FirstOrDefault(r => r.RuleId == ruleId);
    }
    
    private async Task EnsureLoadedAsync()
    {
        if (_isLoaded) return;
        await LoadRulesFromEmbeddedResourcesAsync();
        _isLoaded = true;
    }
    
    private async Task LoadRulesFromEmbeddedResourcesAsync()
    {
        var assembly = typeof(JsonRuleProvider).Assembly;
        var resourceNames = assembly.GetManifestResourceNames()
            .Where(n => n.EndsWith(".json", StringComparison.OrdinalIgnoreCase) && 
                       n.Contains("RuleData", StringComparison.OrdinalIgnoreCase));
        
        var jsonOptions = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        
        foreach (var resourceName in resourceNames)
        {
            try
            {
                await using var stream = assembly.GetManifestResourceStream(resourceName);
                if (stream is null) continue;
                
                var ruleFile = await JsonSerializer.DeserializeAsync<RuleFile>(stream, jsonOptions);
                if (ruleFile?.Rules is { Count: > 0 })
                {
                    _rules.AddRange(ruleFile.Rules);
                    _logger.LogInformation("Loaded {Count} rules from {Resource}", ruleFile.Rules.Count, resourceName);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading rules from {Resource}", resourceName);
            }
        }
        _logger.LogInformation("Total rules loaded: {Count}", _rules.Count);
    }
    
    private sealed class RuleFile
    {
        public List<RuleDefinition>? Rules { get; init; }
    }
}
