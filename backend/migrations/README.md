# Database Migrations

This directory contains SQL migration files for the VEP MVP database schema.

## Files

- **001_initial_schema.sql** - Initial database schema with PostGIS support

## How to Apply Migrations

### Using Supabase (Production)

1. Navigate to your Supabase project dashboard
2. Go to the SQL Editor
3. Copy and paste the contents of `001_initial_schema.sql`
4. Execute the SQL

### Using Local PostgreSQL (Development/Testing)

Prerequisites:
- PostgreSQL 14+ installed
- PostGIS extension available

```bash
# Create a database
createdb vep_development

# Apply the migration
psql -d vep_development -f 001_initial_schema.sql
```

## Schema Overview

The schema includes:

- **5 Tables**: users, voters, assignments, assignment_voters, contact_logs
- **16 Indexes**: Including spatial indexes for location-based queries
- **10 RLS Policies**: Row-level security for Supabase authentication
- **1 Trigger**: Automatically updates voter support_level when contact logs are created
- **PostGIS Extension**: Enabled for spatial data support

## Testing the Schema

After applying the migration, verify it worked:

```sql
-- List all tables
\dt

-- Verify PostGIS is enabled
SELECT PostGIS_Version();

-- Check the voters table structure
\d voters

-- Verify the trigger exists
\d contact_logs
```

## Notes

- The RLS policies require Supabase's `auth` schema to function properly
- In local PostgreSQL testing, RLS policies may not enforce (this is expected)
- The schema uses UUID primary keys generated automatically
- All foreign keys include `ON DELETE CASCADE` for referential integrity
- The voters table uses PostGIS GEOMETRY(POINT, 4326) for GPS coordinates

## Next Steps

After applying this migration, the database is ready for:
- Agent 2 (Backend Engineer) to build the FastAPI application
- Agent 4 (Integration Engineer) to implement the API client
- Agent 5 (Testing Engineer) to write database tests
