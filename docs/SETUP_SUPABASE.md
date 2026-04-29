# Supabase Setup Guide

This guide walks you through setting up Supabase as the database backend for Car Repair Predictor.

## Why Supabase?

- **Free tier**: Generous free tier perfect for development and small production apps
- **PostgreSQL**: Full PostgreSQL database with all features
- **Real-time**: Built-in real-time subscriptions (useful for future mobile apps)
- **Auth**: Built-in authentication (can replace custom auth later)
- **Hosting**: No database hosting to manage

---

## Quick Start (5 minutes)

### 1. Create a Supabase Account

1. Go to [supabase.com](https://supabase.com)
2. Sign up with GitHub (recommended) or email
3. Create a new project:
   - **Name**: `carrepairpredictor`
   - **Database Password**: Create a strong password (save it!)
   - **Region**: Choose closest to your users (e.g., `London` for UK)

### 2. Get Your Connection String

1. In your Supabase dashboard, go to **Settings** → **Database**
2. Scroll to **Connection string** → **URI**
3. Copy the connection string (it looks like):
   ```
   postgresql://postgres.[project-ref]:[password]@aws-0-eu-west-2.pooler.supabase.com:6543/postgres
   ```

### 3. Configure the Application

Update `src/CarPredictor.Api/appsettings.Development.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=aws-0-eu-west-2.pooler.supabase.com;Port=6543;Database=postgres;Username=postgres.[your-project-ref];Password=[your-password];SSL Mode=Require;Trust Server Certificate=true"
  }
}
```

Or use User Secrets (recommended for security):

```bash
cd src/CarPredictor.Api
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=aws-0-eu-west-2.pooler.supabase.com;Port=6543;Database=postgres;Username=postgres.[your-project-ref];Password=[your-password];SSL Mode=Require;Trust Server Certificate=true"
```

### 4. Create the Database Schema

1. In Supabase dashboard, go to **SQL Editor**
2. Click **New query**
3. Copy and paste the contents of:
   - `src/CarPredictor.Data/Scripts/PostgreSQL/001_CreateSchema.sql`
   - Click **Run**
4. Create another query and paste:
   - `src/CarPredictor.Data/Scripts/PostgreSQL/002_SeedData.sql`
   - Click **Run**

### 5. Test the Connection

```bash
cd src/CarPredictor.Api
dotnet run
```

Visit `http://localhost:5235/swagger` and try the `/api/v1/reference/manufacturers` endpoint.

---

## Local Development Option

If you prefer local PostgreSQL for development:

### Using Docker (Recommended)

```bash
# Start PostgreSQL container
docker run --name carpredictor-db -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=carrepairpredictor_dev -p 5432:5432 -d postgres:16

# Run the schema scripts
docker exec -i carpredictor-db psql -U postgres -d carrepairpredictor_dev < src/CarPredictor.Data/Scripts/PostgreSQL/001_CreateSchema.sql
docker exec -i carpredictor-db psql -U postgres -d carrepairpredictor_dev < src/CarPredictor.Data/Scripts/PostgreSQL/002_SeedData.sql
```

Connection string for local Docker:
```
Host=localhost;Port=5432;Database=carrepairpredictor_dev;Username=postgres;Password=postgres
```

### Using PostgreSQL Installer

1. Download from [postgresql.org/download](https://www.postgresql.org/download/)
2. Install with default settings
3. Create database: `createdb carrepairpredictor_dev`
4. Run scripts via pgAdmin or psql

---

## Production Deployment

For production, use the **Supabase connection pooler** for better performance:

1. In Supabase, go to **Settings** → **Database** → **Connection pooling**
2. Enable **Transaction pooling** mode
3. Use the pooler connection string (port 6543)

### Environment Variables for Production

Set these in your hosting environment (Azure, AWS, etc.):

```bash
ConnectionStrings__DefaultConnection="Host=...;Port=6543;Database=postgres;Username=...;Password=...;SSL Mode=Require"
```

---

## Troubleshooting

### "Connection refused" error
- Ensure your IP is allowed in Supabase: **Settings** → **Database** → **Network restrictions**
- For development, you can allow all IPs: `0.0.0.0/0`

### "SSL certificate error"
Add to connection string: `Trust Server Certificate=true`

### "Too many connections"
Use the connection pooler (port 6543) instead of direct connection (port 5432)

---

## Next Steps

1. ✅ Database configured
2. [ ] Configure Stripe keys for payments
3. [ ] Set up authentication (Supabase Auth or custom)
4. [ ] Deploy frontend to Vercel/Netlify
5. [ ] Deploy API to Azure/Railway
