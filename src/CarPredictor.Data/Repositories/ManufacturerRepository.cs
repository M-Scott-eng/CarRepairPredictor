using Dapper;
using CarPredictor.Core.Domain;
using CarPredictor.Core.Interfaces;
using System.Data;

namespace CarPredictor.Data.Repositories;

/// <summary>
/// Repository implementation for manufacturer data access using stored procedures.
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

        var result = await connection.QueryAsync<Manufacturer>(
            "sp_GetAllManufacturers",
            commandType: CommandType.StoredProcedure);

        return result.ToList();
    }

    public async Task<Manufacturer?> GetByIdAsync(int manufacturerId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();

        var result = await connection.QuerySingleOrDefaultAsync<Manufacturer>(
            "sp_GetManufacturerById",
            new { ManufacturerId = manufacturerId },
            commandType: CommandType.StoredProcedure);

        return result;
    }
}
