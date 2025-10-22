# GitHub Copilot Agent 1: Database Engineer

## 🎯 Your Mission
You are Agent 1: Database Engineer. Create the complete database schema for the VEP MVP voter engagement platform.

## 📋 Instructions for GitHub Copilot

### Step 1: Read the Specification
1. Open `spec.md` and read Section 2: Database Schema
2. Open `AGENT_INSTRUCTIONS.md` and read the Agent 1 section
3. Understand the complete database requirements

### Step 2: Create the Migration File
Create `backend/migrations/001_initial_schema.sql` with:

**Required Components:**
- PostGIS extension setup
- 5 tables: users, voters, assignments, assignment_voters, contact_logs
- All foreign key relationships
- Proper indexes for performance
- Row Level Security (RLS) policies
- Trigger for voter support updates
- Data types matching the specification exactly

**Database Tables:**
```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('admin', 'manager', 'canvasser')),
    phone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Voters table with PostGIS location
CREATE TABLE voters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip_code TEXT NOT NULL,
    location GEOMETRY(POINT, 4326),
    support_level TEXT CHECK (support_level IN ('strong_support', 'lean_support', 'undecided', 'lean_oppose', 'strong_oppose')),
    party_affiliation TEXT,
    phone TEXT,
    email TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Assignments table
CREATE TABLE assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    manager_id UUID REFERENCES users(id),
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Assignment-Voter junction table
CREATE TABLE assignment_voters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID REFERENCES assignments(id) ON DELETE CASCADE,
    voter_id UUID REFERENCES voters(id) ON DELETE CASCADE,
    canvasser_id UUID REFERENCES users(id),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'contacted', 'not_home', 'refused')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(assignment_id, voter_id)
);

-- Contact logs table
CREATE TABLE contact_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_voter_id UUID REFERENCES assignment_voters(id) ON DELETE CASCADE,
    contact_type TEXT NOT NULL CHECK (contact_type IN ('door_knock', 'phone_call', 'text_message', 'other')),
    result TEXT NOT NULL CHECK (result IN ('contacted', 'not_home', 'refused', 'wrong_address')),
    notes TEXT,
    support_level TEXT CHECK (support_level IN ('strong_support', 'lean_support', 'undecided', 'lean_oppose', 'strong_oppose')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Required Indexes:**
- Spatial index on voters.location
- Indexes on all foreign keys
- Indexes on commonly queried fields

**RLS Policies:**
- Users can only see their own data
- Managers can see assignments they created
- Canvassers can see their assigned voters

### Step 3: Success Criteria
- [ ] PostGIS extension enabled
- [ ] All 5 tables created with correct structure
- [ ] All foreign key relationships defined
- [ ] Spatial index on voter locations
- [ ] RLS policies implemented
- [ ] Trigger for voter support updates
- [ ] Schema can be applied to PostgreSQL database
- [ ] No syntax errors in SQL

### Step 4: Testing
After creating the schema:
1. Test with: `psql -d your_database -f backend/migrations/001_initial_schema.sql`
2. Verify all tables exist
3. Check indexes are created
4. Test RLS policies work

## 🚀 Ready to Start?

Open VS Code with GitHub Copilot and say:
"I need to create the database schema for the VEP MVP project. Please read spec.md Section 2 and create backend/migrations/001_initial_schema.sql with all the required tables, indexes, and RLS policies."