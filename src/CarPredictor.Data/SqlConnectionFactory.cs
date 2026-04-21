using CarPredictor.Core.Interfaces;
using Microsoft.Data.SqlClient;
using System.Data;

namespace CarPredictor.Data;

/// <summary>
/// SQL Server connection factory implementation.
/// </summary>
public sealed class SqlConnectionFactory : IDbConnectionFactory
{
    private readonly string _connectionString;

    public SqlConnectionFactory(string connectionString)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(connectionString);
        _connectionString = connectionString;
    }

    public IDbConnection CreateConnection()
    {
        return new SqlConnection(_connectionString);
    }
}