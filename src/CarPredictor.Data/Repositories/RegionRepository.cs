using Dapper;
using CarPredictor.Core.Domain;
using CarPredictor.Core.Interfaces;
using System.Data;

namespace CarPredictor.Data.Repositories;

/// <summary>
/// Repository implementation for region data access using stored procedures.
/// </summary>
public sealed class RegionRepository : IRegionRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public RegionRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IReadOnlyList<Region>> GetActiveRegionsAsync(CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();

        var result = await connection.QueryAsync<Region>(
            "sp_GetActiveRegions",
            commandType: CommandType.StoredProcedure);

        return result.ToList();
    }

    public async Task<Region?> GetByCodeAsync(string regionCode, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();

        var result = await connection.QuerySingleOrDefaultAsync<Region>(
            "sp_GetRegionByCode",
            new { RegionCode = regionCode },
            commandType: CommandType.StoredProcedure);

        return result;
    }
}
