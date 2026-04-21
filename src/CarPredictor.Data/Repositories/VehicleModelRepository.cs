using Dapper;
using CarPredictor.Core.Domain;
using CarPredictor.Core.Interfaces;
using System.Data;

namespace CarPredictor.Data.Repositories;

/// <summary>
/// Repository implementation for vehicle model data access using stored procedures.
/// </summary>
public sealed class VehicleModelRepository : IVehicleModelRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public VehicleModelRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IReadOnlyList<VehicleModel>> GetByManufacturerIdAsync(
        int manufacturerId,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();

        var result = await connection.QueryAsync<VehicleModel>(
            "sp_GetVehicleModelsByManufacturer",
            new { ManufacturerId = manufacturerId },
            commandType: CommandType.StoredProcedure);

        return result.ToList();
    }

    public async Task<VehicleModel?> GetByIdAsync(int vehicleModelId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();

        var result = await connection.QuerySingleOrDefaultAsync<VehicleModel>(
            "sp_GetVehicleModelById",
            new { VehicleModelId = vehicleModelId },
            commandType: CommandType.StoredProcedure);

        return result;
    }

    public async Task<IReadOnlyList<int>> GetAvailableYearsAsync(
        int vehicleModelId,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();

        var result = await connection.QueryAsync<int>(
            "sp_GetAvailableYearsForModel",
            new { VehicleModelId = vehicleModelId },
            commandType: CommandType.StoredProcedure);

        return result.ToList();
    }
}
