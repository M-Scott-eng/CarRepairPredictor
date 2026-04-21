using CarPredictor.Rules.Models;

namespace CarPredictor.Rules.Interfaces;

public interface IRuleProvider
{
    Task<IReadOnlyList<RuleDefinition>> GetActiveRulesAsync();
    Task<IReadOnlyList<RuleDefinition>> GetRulesForVehicleAsync(string make, string? model = null);
    Task<RuleDefinition?> GetRuleByIdAsync(string ruleId);
}
