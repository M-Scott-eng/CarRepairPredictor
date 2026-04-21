using CarPredictor.Rules.Interfaces;
using CarPredictor.Rules.Models;
using CarPredictor.Rules.Rules;

namespace CarPredictor.Rules.Engine;

/// <summary>
/// Main prediction engine that coordinates rule evaluation.
/// </summary>
public sealed class PredictionEngine : IRuleEngine
{
    private readonly IRuleProvider _ruleProvider;
    private readonly List<IFailureRule> _rules = new();
    private readonly SemaphoreSlim _refreshLock = new(1, 1);
    private bool _isLoaded;
    
    public PredictionEngine(IRuleProvider ruleProvider)
    {
        _ruleProvider = ruleProvider ?? throw new ArgumentNullException(nameof(ruleProvider));
    }
    
    public async Task<PredictionResult> PredictAsync(VehicleContext context, string regionCode)
    {
        ArgumentNullException.ThrowIfNull(context);
        ArgumentException.ThrowIfNullOrWhiteSpace(regionCode);
        
        if (!_isLoaded)
            await RefreshRulesAsync();
        
        var failures = new List<FailurePrediction>();
        
        foreach (var rule in _rules.OrderBy(r => r.Priority))
        {
            if (rule.AppliesTo(context))
            {
                var prediction = rule.Evaluate(context, regionCode);
                if (prediction is not null)
                    failures.Add(prediction);
            }
        }
        
        failures = failures.OrderByDescending(f => f.Probability).ToList();
        
        var twelveMoCost = CalculatePeriodCost(failures, 1);
        var threeYrCost = CalculatePeriodCost(failures, 3);
        
        return new PredictionResult
        {
            Vehicle = new VehicleSummary
            {
                Make = context.Make,
                Model = context.Model,
                Generation = context.Generation,
                Year = context.Year,
                Mileage = context.Mileage,
                FuelType = context.FuelType,
                Transmission = context.Transmission
            },
            Failures = failures,
            ReliabilityScore = CalculateReliabilityScore(failures),
            TwelveMonthCost = twelveMoCost,
            ThreeYearCost = threeYrCost
        };
    }
    
    public async Task RefreshRulesAsync()
    {
        await _refreshLock.WaitAsync();
        try
        {
            _rules.Clear();
            var definitions = await _ruleProvider.GetActiveRulesAsync();
            foreach (var definition in definitions)
                _rules.Add(new JsonBasedRule(definition));
            _isLoaded = true;
        }
        finally
        {
            _refreshLock.Release();
        }
    }
    
    public IReadOnlyList<string> GetLoadedRuleIds() => _rules.Select(r => r.RuleId).ToList().AsReadOnly();
    
    private static decimal CalculateReliabilityScore(List<FailurePrediction> failures)
    {
        if (failures.Count == 0)
            return 95m;
        
        var totalPenalty = 0m;
        foreach (var failure in failures)
        {
            var severityWeight = failure.Severity switch
            {
                4 => 5m,
                3 => 3m,
                2 => 1.5m,
                _ => 0.5m
            };
            totalPenalty += (failure.Probability / 100m) * severityWeight;
        }
        
        return Math.Max(0, Math.Round(100m - (totalPenalty * 5m), 1));
    }
    
    private static decimal CalculatePeriodCost(List<FailurePrediction> failures, int years)
    {
        var total = 0m;
        foreach (var failure in failures)
        {
            var avgCost = (failure.MinCost + failure.MaxCost) / 2m;
            var expectedValue = (failure.Probability / 100m) * avgCost;
            total += expectedValue * years;
        }
        return Math.Round(total, 2);
    }
}