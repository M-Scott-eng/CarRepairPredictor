using Dapper;
using CarPredictor.Core.Domain;
using CarPredictor.Core.Interfaces;

namespace CarPredictor.Data.Repositories;

/// <summary>
/// Repository implementation for manufacturer data access.
/// </summary>
public sealed class ManufacturerRepository : IManufacturerRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public ManufacturerRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IReadOnlyList<Manufacturer>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();

        const string sql = """
            SELECT manufacturer_id AS ManufacturerId,
                   manufacturer_name AS ManufacturerName,
                   country_of_origin AS CountryOfOrigin
            FROM manufacturer
            ORDER BY manufacturer_name
            """;

        var result = await connection.QueryAsync<Manufacturer>(sql);
        return result.ToList();
    }

    public async Task<Manufacturer?> GetByIdAsync(int manufacturerId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();

        const string sql = """
            SELECT manufacturer_id AS ManufacturerId,
                   manufacturer_name AS ManufacturerName,
                   country_of_origin AS CountryOfOrigin
            FROM manufacturer
            WHERE manufacturer_id = @ManufacturerId
            """;

        return await connection.QuerySingleOrDefaultAsync<Manufacturer>(sql, new { ManufacturerId = manufacturerId });
    }
}
