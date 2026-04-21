# Car Repair Cost Predictor

A web application that predicts repair costs for used vehicles in the UK market, leveraging MOT history data, statistical failure patterns, and cost estimation models.

## Prerequisites

- .NET 8.0 SDK
- SQL Server 2019+ or SQL Server LocalDB
- Visual Studio 2022 or VS Code with C# extension

## Getting Started

### Database Setup

1. Create a new SQL Server database named `CarRepairPredictor`
2. Run the SQL scripts in order from `src/CarPredictor.Data/Scripts/`:
   - `001_CreateTables.sql` - Creates all database tables and indexes
   - `002_CreateStoredProcedures.sql` - Creates stored procedures
   - `003_SeedReferenceData.sql` - Populates reference data (manufacturers, models, categories)

### Configuration

Update the connection string in `src/CarPredictor.Api/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SERVER;Database=CarRepairPredictor;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

### Running the Application

```bash
cd src/CarPredictor.Api
dotnet run
```

The API will be available at:
- HTTP: `http://localhost:5000`
- HTTPS: `https://localhost:5001`
- Swagger UI: `https://localhost:5001/swagger`

## Project Structure

```
src/
├── CarPredictor.Api/        # ASP.NET Core Web API
│   ├── Controllers/                  # API controllers
│   ├── DTOs/                         # Request/Response DTOs
│   └── Middleware/                   # Custom middleware
│
├── CarPredictor.Core/       # Domain models & interfaces
│   ├── Domain/                       # Entity classes
│   ├── Enums/                        # Enumeration types
│   └── Interfaces/                   # Repository interfaces
│
├── CarPredictor.Data/       # Data access layer
│   ├── Repositories/                 # Dapper repository implementations
│   └── Scripts/                      # SQL migration scripts
│
├── CarPredictor.Services/   # Business logic (Phase 2)
├── CarPredictor.Rules/      # Rule engine (Phase 2)
└── CarPredictor.External/   # External API integrations (Phase 2)
```

## API Endpoints (Phase 1)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/reference/manufacturers` | List all manufacturers |
| `GET` | `/api/v1/reference/manufacturers/{id}/models` | Get models for a manufacturer |
| `GET` | `/api/v1/reference/models/{id}/years` | Get available years for a model |
| `GET` | `/api/v1/health` | Health check |

## Development Phases

- **Phase 1** ✅ - Project structure, reference data endpoints
- **Phase 2** - Prediction engine with rule system
- **Phase 3** - UK MOT API integration
- **Phase 4** - React frontend
- **Phase 5** - Failure pattern database population
- **Phase 6** - US region support

## Technology Stack

- **Backend**: .NET 8, ASP.NET Core Web API
- **Data Access**: Dapper + SQL Server Stored Procedures
- **Database**: SQL Server 2019+
- **Documentation**: Swagger/OpenAPI

## Coding Standards

This project follows the Esteiro coding standards including:
- Stored procedures for all database access (prefixed with `sp`)
- Interface-based dependency injection
- Repository pattern with Dapper
- DTOs for API contracts (never expose domain entities)
- Nullable reference types enabled
