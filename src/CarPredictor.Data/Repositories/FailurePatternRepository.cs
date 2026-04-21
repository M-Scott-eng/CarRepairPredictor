using Dapper;
using CarPredictor.Core.Domain;
using CarPredictor.Core.Interfaces;
using System.Data;

namespace CarPredictor.Data.Repositories;

/// <summary>
/// Repository implementation for failure pattern data access using stored procedures.
/// </summary>
public sealed class FailurePatternRepository : IFailurePatternRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public FailurePatternRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IReadOnlyList<FailurePattern>> GetByVehicleModelIdAsync(
        int vehicleModelId,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();

        var result = await connection.QueryAsync<FailurePattern>(
            "sp_GetFailurePatternsByVehicleModel",
            new { VehicleModelId = vehicleModelId },
            commandType: CommandType.StoredProcedure);

        return result.ToList();
    }

    public async Task<IReadOnlyList<FailurePattern>> GetApplicablePatternsAsync(
        int vehicleModelId,
        int mileage,
        int vehicleAge,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();

        var result = await connection.QueryAsync<FailurePattern>(
            "sp_GetApplicableFailurePatterns",
            new
            {
                VehicleModelId = vehicleModelId,
                Mileage = mileage,
                VehicleAge = vehicleAge
            },
            commandType: CommandType.StoredProcedure);

        return result.ToList();
    }
}
