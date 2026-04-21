using System.Data;

namespace CarPredictor.Core.Interfaces;

/// <summary>
/// Factory for creating database connections.
/// </summary>
public interface IDbConnectionFactory
{
    /// <summary>
    /// Creates a new database connection.
    /// </summary>
    IDbConnection CreateConnection();
}