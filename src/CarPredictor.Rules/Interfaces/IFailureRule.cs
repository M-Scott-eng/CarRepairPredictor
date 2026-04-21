using CarPredictor.Rules.Models;

namespace CarPredictor.Rules.Interfaces;

public interface IFailureRule
{
    string RuleId { get; }
    int Priority { get; }
    bool AppliesTo(VehicleContext context);
    FailurePrediction? Evaluate(VehicleContext context, string regionCode);
}
