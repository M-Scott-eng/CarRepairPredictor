using Dapper;
using CarPredictor.Core.Domain;
using CarPredictor.Core.Interfaces;

namespace CarPredictor.Data.Repositories;

/// <summary>
/// Repository implementation for vehicle model data access.
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

        const string sql = """
            SELECT vm.vehicle_model_id AS VehicleModelId,
                   vm.manufacturer_id AS ManufacturerId,
                   vm.model_name AS ModelName,
                   vm.year_start AS YearStart,
                   vm.year_end AS YearEnd,
                   vm.engine_types AS EngineTypes,
                   m.manufacturer_name AS ManufacturerName
            FROM vehicle_model vm
            INNER JOIN manufacturer m ON vm.manufacturer_id = m.manufacturer_id
            WHERE vm.manufacturer_id = @ManufacturerId
            ORDER BY vm.model_name
            """;

        var result = await connection.QueryAsync<VehicleModel>(sql, new { ManufacturerId = manufacturerId });
        return result.ToList();
    }

    public async Task<VehicleModel?> GetByIdAsync(int vehicleModelId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();

        const string sql = """
            SELECT vm.vehicle_model_id AS VehicleModelId,
                   vm.manufacturer_id AS ManufacturerId,
                   vm.model_name AS ModelName,
                   vm.year_start AS YearStart,
                   vm.year_end AS YearEnd,
                   vm.engine_types AS EngineTypes,
                   m.manufacturer_name AS ManufacturerName
            FROM vehicle_model vm
            INNER JOIN manufacturer m ON vm.manufacturer_id = m.manufacturer_id
            WHERE vm.vehicle_model_id = @VehicleModelId
            """;

        return await connection.QuerySingleOrDefaultAsync<VehicleModel>(sql, new { VehicleModelId = vehicleModelId });
    }

    public async Task<IReadOnlyList<int>> GetAvailableYearsAsync(
        int vehicleModelId,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();

        const string sql = """
            SELECT generate_series(
                (SELECT year_start FROM vehicle_model WHERE vehicle_model_id = @VehicleModelId),
                COALESCE(
                    (SELECT year_end FROM vehicle_model WHERE vehicle_model_id = @VehicleModelId),
                    EXTRACT(YEAR FROM CURRENT_DATE)::INT
                )
            ) AS year
            ORDER BY year DESC
            """;

        var result = await connection.QueryAsync<int>(sql, new { VehicleModelId = vehicleModelId });
        return result.ToList();
    }
}
