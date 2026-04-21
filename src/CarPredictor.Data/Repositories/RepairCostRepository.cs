using Dapper;
using CarPredictor.Core.Domain;
using CarPredictor.Core.Interfaces;
using System.Data;

namespace CarPredictor.Data.Repositories;

/// <summary>
/// Repository implementation for repair cost data access using stored procedures.
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

        // Create DataTable for TVP
        var idsTable = new DataTable();
        idsTable.Columns.Add("Id", typeof(int));
        
        foreach (var id in failurePatternIds)
        {
            idsTable.Rows.Add(id);
        }

        var result = await connection.QueryAsync<RepairCost>(
            "sp_GetRepairCostsByFailurePatterns",
            new
            {
                FailurePatternIds = idsTable.AsTableValuedParameter("dbo.IntIdList"),
                RegionId = regionId
            },
            commandType: CommandType.StoredProcedure);

        return result.ToList();
    }
}
