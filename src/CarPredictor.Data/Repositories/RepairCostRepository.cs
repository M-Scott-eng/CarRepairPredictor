using Dapper;
using CarPredictor.Core.Domain;
using CarPredictor.Core.Interfaces;

namespace CarPredictor.Data.Repositories;

/// <summary>
/// Repository implementation for repair cost data access.
/// </summary>
public sealed class RepairCostRepository : IRepairCostRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public RepairCostRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IReadOnlyList<RepairCost>> GetByFailurePatternIdsAsync(
        IEnumerable<int> failurePatternIds,
        int regionId,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();

        var idsList = failurePatternIds.ToList();
        if (idsList.Count == 0)
        {
            return Array.Empty<RepairCost>();
        }

        const string sql = """
            SELECT rc.repair_cost_id AS RepairCostId,
                   rc.failure_pattern_id AS FailurePatternId,
                   rc.region_id AS RegionId,
                   rc.min_cost AS MinCost,
                   rc.max_cost AS MaxCost,
                   rc.average_cost AS AverageCost,
                   rc.labour_hours AS LabourHours,
                   rc.parts_only_cost AS PartsOnlyCost,
                   rc.effective_from AS EffectiveFrom,
                   rc.effective_to AS EffectiveTo
            FROM repair_cost rc
            WHERE rc.failure_pattern_id = ANY(@FailurePatternIds)
              AND rc.region_id = @RegionId
              AND rc.effective_from <= CURRENT_DATE
              AND (rc.effective_to IS NULL OR rc.effective_to >= CURRENT_DATE)
            """;

        var result = await connection.QueryAsync<RepairCost>(sql, new { FailurePatternIds = idsList.ToArray(), RegionId = regionId });
        return result.ToList();
    }
}
