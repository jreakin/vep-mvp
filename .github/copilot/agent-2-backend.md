# GitHub Copilot Agent 2: Backend Engineer

## 🎯 Your Mission
You are Agent 2: Backend Engineer. Create the complete FastAPI backend for the VEP MVP voter engagement platform.

## 📋 Instructions for GitHub Copilot

### Step 1: Read the Specification
1. Open `spec.md` and read Section 3: Backend API
2. Open `backend/migrations/001_initial_schema.sql` (from Agent 1)
3. Open `AGENT_INSTRUCTIONS.md` and read the Agent 2 section

### Step 2: Create Backend Files

**Files to Create/Update:**
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

### Step 3: Required API Endpoints

**Authentication:**
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `GET /auth/me` - Get current user

**Users:**
- `GET /users/` - List users (admin only)
- `GET /users/{user_id}` - Get user details
- `PUT /users/{user_id}` - Update user
- `POST /users/` - Create user (admin only)

**Assignments:**
- `GET /assignments/` - List assignments
- `POST /assignments/` - Create assignment
- `GET /assignments/{assignment_id}` - Get assignment details
- `PUT /assignments/{assignment_id}` - Update assignment
- `DELETE /assignments/{assignment_id}` - Delete assignment
- `GET /assignments/{assignment_id}/voters` - Get assignment voters

**Voters:**
- `GET /voters/` - List voters (with filters)
- `GET /voters/{voter_id}` - Get voter details
- `PUT /voters/{voter_id}` - Update voter
- `GET /voters/nearby` - Find voters near location

**Contact Logs:**
- `POST /contact-logs/` - Create contact log
- `GET /contact-logs/` - List contact logs
- `PUT /contact-logs/{log_id}` - Update contact log
- `DELETE /contact-logs/{log_id}` - Delete contact log

### Step 4: Technical Requirements

**Authentication:**
- JWT tokens with Supabase
- Role-based access control
- Secure password handling

**Database:**
- SQLModel for ORM
- Async database operations
- Connection pooling
- Transaction management

**Validation:**
- Pydantic request/response models
- Input validation and sanitization
- Error handling with proper HTTP status codes

**Security:**
- CORS configuration
- Rate limiting
- Input sanitization
- SQL injection prevention

### Step 5: Success Criteria
- [ ] All 15+ API endpoints implemented
- [ ] JWT authentication working
- [ ] Database models match schema exactly
- [ ] Request/response validation
- [ ] Error handling implemented
- [ ] CORS configured
- [ ] Server starts without errors
- [ ] All endpoints return proper HTTP status codes

### Step 6: Testing
After creating the backend:
1. Start server: `uv run uvicorn app.main:app --reload`
2. Test endpoints with Postman/curl
3. Verify authentication works
4. Check database connections

## 🚀 Ready to Start?

Open VS Code with GitHub Copilot and say:
"I need to create the FastAPI backend for the VEP MVP project. Please read spec.md Section 3 and create all the backend files with the complete API implementation."