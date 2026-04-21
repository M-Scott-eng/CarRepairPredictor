using CarPredictor.Rules.Models;

namespace CarPredictor.Rules.Interfaces;

public interface IRuleEngine
{
    Task<PredictionResult> PredictAsync(VehicleContext context, string regionCode);
    Task RefreshRulesAsync();
    IReadOnlyList<string> GetLoadedRuleIds();
}
