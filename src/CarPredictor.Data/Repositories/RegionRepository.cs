using Dapper;
using CarPredictor.Core.Domain;
using CarPredictor.Core.Interfaces;

namespace CarPredictor.Data.Repositories;

/// <summary>
/// Repository implementation for region data access.
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

        const string sql = """
            SELECT region_id AS RegionId,
                   region_code AS RegionCode,
                   region_name AS RegionName,
                   currency_code AS CurrencyCode,
                   is_active AS IsActive
            FROM region
            WHERE is_active = true
            ORDER BY region_name
            """;

        var result = await connection.QueryAsync<Region>(sql);
        return result.ToList();
    }

    public async Task<Region?> GetByCodeAsync(string regionCode, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();

        const string sql = """
            SELECT region_id AS RegionId,
                   region_code AS RegionCode,
                   region_name AS RegionName,
                   currency_code AS CurrencyCode,
                   is_active AS IsActive
            FROM region
            WHERE region_code = @RegionCode
            """;

        return await connection.QuerySingleOrDefaultAsync<Region>(sql, new { RegionCode = regionCode });
    }
}
