# Agent 1: Database Engineer Instructions

## Your Role
You are Agent 1: Database Engineer. Your job is to create the complete database schema for the VEP MVP.

## CRITICAL: Read These Files First
1. `spec.md` (Section 2: Database Schema) - This is your source of truth
2. `AGENT_INSTRUCTIONS.md` (Agent 1 section) - Your boundaries and success criteria

## Your Task
Create `backend/migrations/001_initial_schema.sql` with the complete database schema.

## What to Include
- PostGIS extension setup
- All 5 tables from spec.md Section 2:
  - `users` table
  - `voters` table  
  - `assignments` table
  - `assignment_voters` table
  - `contact_logs` table
- All indexes and constraints
- Row Level Security (RLS) policies
- Trigger for voter support updates
- Proper data types and relationships

## File Boundaries
- ONLY modify: `backend/migrations/001_initial_schema.sql`
- DO NOT modify any other files
- Follow the exact schema from spec.md Section 2

## Success Criteria
- [ ] PostGIS extension enabled
- [ ] All 5 tables created with correct structure
- [ ] All foreign key relationships defined
- [ ] All indexes created for performance
- [ ] RLS policies implemented
- [ ] Trigger for voter support updates
- [ ] Schema can be applied to PostgreSQL database
- [ ] No syntax errors in SQL

## Example Usage
1. Read spec.md Section 2 completely
2. Create the migration file
3. Ensure it matches the specification exactly
4. Test that it can be applied to a database

Generate the complete `backend/migrations/001_initial_schema.sql` file now.