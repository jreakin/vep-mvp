# Agent 2: Backend Engineer Instructions

## Your Role
You are Agent 2: Backend Engineer. Your job is to create the complete FastAPI backend for the VEP MVP.

## CRITICAL: Read These Files First
1. `spec.md` (Section 3: Backend API) - Complete API specification
2. `backend/migrations/001_initial_schema.sql` - Database schema from Agent 1
3. `AGENT_INSTRUCTIONS.md` (Agent 2 section) - Your boundaries and success criteria

## Your Task
Create the complete FastAPI backend in `backend/app/` directory.

## Files to Create/Modify
- `backend/app/main.py` - Complete FastAPI application
- `backend/app/config.py` - Complete configuration with Pydantic
- `backend/app/dependencies.py` - Authentication and database dependencies
- `backend/app/models/` - SQLModel models matching the database:
  - `user.py` - User model
  - `voter.py` - Voter model
  - `assignment.py` - Assignment model
  - `contact_log.py` - Contact log model
- `backend/app/routes/` - API routes:
  - `auth.py` - Authentication endpoints
  - `users.py` - User management
  - `assignments.py` - Assignment management
  - `voters.py` - Voter data
  - `contact_logs.py` - Contact logging

## What to Implement
- JWT authentication with Supabase
- All API endpoints from spec.md Section 3
- Request/response validation with Pydantic
- Database connection with SQLModel
- Error handling and HTTP status codes
- CORS configuration
- Input validation and sanitization

## File Boundaries
- ONLY modify files in `backend/app/` directory
- DO NOT modify database migrations (Agent 1's work)
- DO NOT modify iOS files (Agent 3's work)
- Follow the exact API specification from spec.md

## Success Criteria
- [ ] All 15+ API endpoints implemented
- [ ] JWT authentication working
- [ ] Database models match schema exactly
- [ ] Request/response validation
- [ ] Error handling implemented
- [ ] CORS configured
- [ ] Server starts without errors
- [ ] All endpoints return proper HTTP status codes

## Example Usage
1. Read spec.md Section 3 completely
2. Review Agent 1's database schema
3. Create all backend files
4. Ensure API matches specification exactly
5. Test that server starts successfully

Generate all the backend files now.