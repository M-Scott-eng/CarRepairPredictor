# Car Repair Cost Predictor

A web application that predicts repair costs for used vehicles in the UK market, leveraging MOT history data, statistical failure patterns, and cost estimation models.

## Prerequisites

- .NET 8.0 SDK
- PostgreSQL 14+ (or [Supabase](https://supabase.com) - recommended)
- Node.js 18+ (for frontend)
- Visual Studio 2022 or VS Code with C# extension

## Getting Started

### Quick Start with Supabase (Recommended)

See [docs/SETUP_SUPABASE.md](docs/SETUP_SUPABASE.md) for detailed instructions.

1. Create a free account at [supabase.com](https://supabase.com)
2. Create a new project
3. Run the SQL scripts from `src/CarPredictor.Data/Scripts/PostgreSQL/` in the SQL Editor
4. Copy your connection string to `appsettings.Development.json`

### Local PostgreSQL Setup

1. Install PostgreSQL or run via Docker:
   ```bash
   docker run --name carpredictor-db -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=carrepairpredictor_dev -p 5432:5432 -d postgres:16
   ```

2. Run the schema scripts:
   ```bash
   psql -U postgres -d carrepairpredictor_dev -f src/CarPredictor.Data/Scripts/PostgreSQL/001_CreateSchema.sql
   psql -U postgres -d carrepairpredictor_dev -f src/CarPredictor.Data/Scripts/PostgreSQL/002_SeedData.sql
   ```

### Configuration

Update the connection string in `src/CarPredictor.Api/appsettings.Development.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=carrepairpredictor_dev;Username=postgres;Password=postgres"
  }
}
```

### Running the Application

**Backend:**
```bash
cd src/CarPredictor.Api
dotnet run
```

**Frontend:**
```bash
cd frontend
npm install
npm run dev
```

The application will be available at:
- Frontend: `http://localhost:3000`
- API: `http://localhost:5235`
- Swagger UI: `http://localhost:5235/swagger`

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
- **Frontend**: React 18, TypeScript, Vite, TailwindCSS
- **Data Access**: Dapper with PostgreSQL
- **Database**: PostgreSQL 14+ (Supabase recommended)
- **Payments**: Stripe
- **Documentation**: Swagger/OpenAPI

## Coding Standards

This project follows the Esteiro coding standards including:
- Interface-based dependency injection
- Repository pattern with Dapper
- DTOs for API contracts (never expose domain entities)
- Nullable reference types enabled
