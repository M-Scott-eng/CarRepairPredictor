using Dapper;
using CarPredictor.Core.Domain;
using CarPredictor.Core.Interfaces;

namespace CarPredictor.Data.Repositories;

/// <summary>
/// Repository implementation for failure pattern data access.
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

        const string sql = """
            SELECT fp.failure_pattern_id AS FailurePatternId,
                   fp.vehicle_model_id AS VehicleModelId,
                   fp.failure_category_id AS FailureCategoryId,
                   fp.failure_name AS FailureName,
                   fp.description AS Description,
                   fp.min_mileage AS MinMileage,
                   fp.max_mileage AS MaxMileage,
                   fp.min_age AS MinAge,
                   fp.max_age AS MaxAge,
                   fp.base_probability AS BaseProbability,
                   fp.severity_level AS SeverityLevel,
                   fp.is_common AS IsCommon,
                   fp.data_source AS DataSource,
                   fc.category_code AS CategoryCode,
                   fc.category_name AS CategoryName
            FROM failure_pattern fp
            INNER JOIN failure_category fc ON fp.failure_category_id = fc.failure_category_id
            WHERE fp.vehicle_model_id = @VehicleModelId
            ORDER BY fp.severity_level DESC, fp.base_probability DESC
            """;

        var result = await connection.QueryAsync<FailurePattern>(sql, new { VehicleModelId = vehicleModelId });
        return result.ToList();
    }

    public async Task<IReadOnlyList<FailurePattern>> GetApplicablePatternsAsync(
        int vehicleModelId,
        int mileage,
        int vehicleAge,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();

        const string sql = """
            SELECT fp.failure_pattern_id AS FailurePatternId,
                   fp.vehicle_model_id AS VehicleModelId,
                   fp.failure_category_id AS FailureCategoryId,
                   fp.failure_name AS FailureName,
                   fp.description AS Description,
                   fp.min_mileage AS MinMileage,
                   fp.max_mileage AS MaxMileage,
                   fp.min_age AS MinAge,
                   fp.max_age AS MaxAge,
                   fp.base_probability AS BaseProbability,
                   fp.severity_level AS SeverityLevel,
                   fp.is_common AS IsCommon,
                   fp.data_source AS DataSource,
                   fc.category_code AS CategoryCode,
                   fc.category_name AS CategoryName
            FROM failure_pattern fp
            INNER JOIN failure_category fc ON fp.failure_category_id = fc.failure_category_id
            WHERE fp.vehicle_model_id = @VehicleModelId
              AND (fp.min_mileage IS NULL OR @Mileage >= fp.min_mileage)
              AND (fp.max_mileage IS NULL OR @Mileage <= fp.max_mileage)
              AND (fp.min_age IS NULL OR @VehicleAge >= fp.min_age)
              AND (fp.max_age IS NULL OR @VehicleAge <= fp.max_age)
            ORDER BY fp.severity_level DESC, fp.base_probability DESC
            """;

        var result = await connection.QueryAsync<FailurePattern>(sql, new { VehicleModelId = vehicleModelId, Mileage = mileage, VehicleAge = vehicleAge });
        return result.ToList();
    }
}
