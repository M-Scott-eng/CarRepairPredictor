using CarPredictor.Rules.Interfaces;
using CarPredictor.Rules.Models;

namespace CarPredictor.Rules.Rules;

/// <summary>
/// Rule implementation based on JSON rule definition.
/// </summary>
public sealed class JsonBasedRule : IFailureRule
{
    private readonly RuleDefinition _definition;
    
    public JsonBasedRule(RuleDefinition definition)
    {
        _definition = definition ?? throw new ArgumentNullException(nameof(definition));
    }
    
    public string RuleId => _definition.RuleId;
    public int Priority => _definition.Severity;
    
    public bool AppliesTo(VehicleContext context)
    {
        ArgumentNullException.ThrowIfNull(context);
        
        var match = _definition.VehicleMatch;
        
        if (!string.IsNullOrEmpty(match.Make) && 
            !string.Equals(context.Make, match.Make, StringComparison.OrdinalIgnoreCase))
            return false;
        
        if (!string.IsNullOrEmpty(match.Model) && 
            !string.Equals(context.Model, match.Model, StringComparison.OrdinalIgnoreCase))
            return false;
        
        if (!string.IsNullOrEmpty(match.Generation) && 
            !string.Equals(context.Generation, match.Generation, StringComparison.OrdinalIgnoreCase))
            return false;
        
        if (match.YearMin.HasValue && context.Year < match.YearMin.Value)
            return false;
        
        if (match.YearMax.HasValue && context.Year > match.YearMax.Value)
            return false;
        
        if (match.EngineCodes is { Count: > 0 } && !string.IsNullOrEmpty(context.EngineCode))
        {
            if (!match.EngineCodes.Any(ec => 
                string.Equals(ec, context.EngineCode, StringComparison.OrdinalIgnoreCase)))
                return false;
        }
        
        if (match.FuelTypes is { Count: > 0 } && !string.IsNullOrEmpty(context.FuelType))
        {
            if (!match.FuelTypes.Any(ft => 
                string.Equals(ft, context.FuelType, StringComparison.OrdinalIgnoreCase)))
                return false;
        }
        
        var cond = _definition.Conditions;
        if (cond.MileageMin.HasValue && context.Mileage < cond.MileageMin.Value)
            return false;
        
        if (cond.MileageMax.HasValue && context.Mileage > cond.MileageMax.Value)
            return false;
        
        var age = DateTime.Today.Year - context.Year;
        if (cond.AgeMin.HasValue && age < cond.AgeMin.Value)
            return false;
        
        if (cond.AgeMax.HasValue && age > cond.AgeMax.Value)
            return false;
        
        return true;
    }
    
    public FailurePrediction? Evaluate(VehicleContext context, string regionCode)
    {
        if (!AppliesTo(context))
            return null;
        
        var probability = CalculateProbability(context);
        if (probability < 0.05m)
            return null;
        
        var (minCost, maxCost) = CalculateCost(regionCode);
        
        return new FailurePrediction
        {
            FailureName = _definition.RuleName,
            Description = _definition.Description,
            Category = _definition.Category,
            Probability = Math.Round(probability * 100, 1),
            Severity = _definition.Severity,
            MinCost = minCost,
            MaxCost = maxCost,
            AvgCost = (minCost + maxCost) / 2
        };
    }
    
    private decimal CalculateProbability(VehicleContext context)
    {
        var prob = _definition.Probability;
        var probability = prob.Base;
        
        if (prob.MileageMultiplier.HasValue && context.Mileage > 0)
        {
            var mileage10k = context.Mileage / 10000m;
            probability += mileage10k * prob.MileageMultiplier.Value;
        }
        
        if (prob.AgeMultiplier.HasValue)
        {
            var age = DateTime.Today.Year - context.Year;
            probability += age * prob.AgeMultiplier.Value;
        }
        
        if (prob.MotBoost.HasValue && context.MotHistory is { Count: > 0 })
        {
            var triggerCodes = _definition.Conditions.MotTriggerCodes;
            if (triggerCodes is { Count: > 0 })
            {
                foreach (var mot in context.MotHistory)
                {
                    if (mot.DefectCodes?.Any(code => 
                        triggerCodes.Any(tc => code.StartsWith(tc, StringComparison.OrdinalIgnoreCase))) == true)
                    {
                        probability += prob.MotBoost.Value;
                        break;
                    }
                }
            }
        }
        
        return Math.Min(probability, prob.MaxProbability);
    }
    
    private (decimal min, decimal max) CalculateCost(string regionCode)
    {
        if (!_definition.Costs.TryGetValue(regionCode, out var cost))
        {
            if (!_definition.Costs.TryGetValue("UK", out cost))
                cost = _definition.Costs.Values.FirstOrDefault();
        }
        
        if (cost is null)
            return (0, 0);
        
        var labourRate = cost.LabourRate ?? 60m;
        var minTotal = cost.PartsMin + (cost.LabourHoursMin * labourRate);
        var maxTotal = cost.PartsMax + (cost.LabourHoursMax * labourRate);
        
        return (Math.Round(minTotal, 2), Math.Round(maxTotal, 2));
    }
}