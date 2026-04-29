using CarPredictor.Core.Interfaces;
using Npgsql;
using System.Data;

namespace CarPredictor.Data;

/// <summary>
/// PostgreSQL connection factory implementation.
/// </summary>
public sealed class NpgsqlConnectionFactory : IDbConnectionFactory
{
    private readonly string _connectionString;

    public NpgsqlConnectionFactory(string connectionString)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(connectionString);
        _connectionString = connectionString;
    }

    public IDbConnection CreateConnection()
    {
        return new NpgsqlConnection(_connectionString);
    }
}

/// <summary>
/// SQL Server connection factory implementation (legacy - kept for migration).
/// </summary>
[Obsolete("Use NpgsqlConnectionFactory for PostgreSQL. This class is kept for backwards compatibility.")]
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
        throw new NotSupportedException("SQL Server is no longer supported. Please migrate to PostgreSQL using NpgsqlConnectionFactory.");
    }
}