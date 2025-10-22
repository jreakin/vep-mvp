-- =============================================================================
-- VEP MVP Database Schema - Initial Migration
-- =============================================================================
-- Version: 1.0
-- Created: 2025-10-22
-- Description: Complete PostgreSQL database schema with PostGIS support for
--              the Voter Engagement Platform MVP
-- =============================================================================

-- Enable PostGIS extension for spatial data support
CREATE EXTENSION IF NOT EXISTS postgis;

-- =============================================================================
-- TABLE: users
-- =============================================================================
-- Stores user metadata for authentication and role-based access control
-- Supabase Auth handles authentication; this table stores additional metadata
-- Roles: admin > manager > canvasser (hierarchical permissions)
-- =============================================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('admin', 'manager', 'canvasser')),
    phone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for users table
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- =============================================================================
-- TABLE: voters
-- =============================================================================
-- Stores voter information with PostGIS location data for spatial queries
-- External voter_id links to VAN/PDI voter databases
-- Location uses SRID 4326 (WGS 84) for GPS coordinates
-- Support level: 1=Strong Opponent, 2=Lean Opponent, 3=Undecided, 
--                4=Lean Support, 5=Strong Support
-- =============================================================================

CREATE TABLE voters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    voter_id TEXT UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL DEFAULT 'TX',
    zip TEXT NOT NULL,
    location GEOMETRY(POINT, 4326),
    party_affiliation TEXT,
    support_level INTEGER CHECK (support_level BETWEEN 1 AND 5),
    phone TEXT,
    email TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for voters table
CREATE INDEX idx_voters_voter_id ON voters(voter_id);
CREATE INDEX idx_voters_location ON voters USING GIST(location);
CREATE INDEX idx_voters_zip ON voters(zip);
CREATE INDEX idx_voters_support_level ON voters(support_level);

-- =============================================================================
-- TABLE: assignments
-- =============================================================================
-- Stores canvassing assignments linking managers to canvassers
-- Status lifecycle: pending → in_progress → completed (or cancelled)
-- Each assignment is owned by a user (canvasser) and may have multiple voters
-- =============================================================================

CREATE TABLE assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    assigned_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for assignments table
CREATE INDEX idx_assignments_user_id ON assignments(user_id);
CREATE INDEX idx_assignments_status ON assignments(status);
CREATE INDEX idx_assignments_assigned_date ON assignments(assigned_date);

-- =============================================================================
-- TABLE: assignment_voters
-- =============================================================================
-- Junction table linking assignments to voters (many-to-many relationship)
-- Allows pre-planned route optimization via sequence_order
-- Each voter can only appear once per assignment (enforced by unique constraint)
-- =============================================================================

CREATE TABLE assignment_voters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    voter_id UUID NOT NULL REFERENCES voters(id) ON DELETE CASCADE,
    sequence_order INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(assignment_id, voter_id)
);

-- Indexes for assignment_voters table
CREATE INDEX idx_assignment_voters_assignment ON assignment_voters(assignment_id);
CREATE INDEX idx_assignment_voters_voter ON assignment_voters(voter_id);
CREATE INDEX idx_assignment_voters_sequence ON assignment_voters(assignment_id, sequence_order);

-- =============================================================================
-- TABLE: contact_logs
-- =============================================================================
-- Records every voter contact interaction made by canvassers
-- Tracks contact type, result, support level changes, and GPS location
-- Location field records where the canvasser was when logging (for verification)
-- Support level updates trigger automatic voter record updates
-- =============================================================================

CREATE TABLE contact_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    voter_id UUID NOT NULL REFERENCES voters(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    contact_type TEXT NOT NULL CHECK (contact_type IN ('knocked', 'phone', 'text', 'email', 'not_home', 'refused', 'moved', 'deceased')),
    result TEXT,
    support_level INTEGER CHECK (support_level BETWEEN 1 AND 5),
    location GEOMETRY(POINT, 4326),
    contacted_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for contact_logs table
CREATE INDEX idx_contact_logs_assignment ON contact_logs(assignment_id);
CREATE INDEX idx_contact_logs_voter ON contact_logs(voter_id);
CREATE INDEX idx_contact_logs_user ON contact_logs(user_id);
CREATE INDEX idx_contact_logs_contacted_at ON contact_logs(contacted_at);

-- =============================================================================
-- DATABASE FUNCTIONS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- FUNCTION: update_voter_support_level()
-- -----------------------------------------------------------------------------
-- Automatically updates the voter's support_level when a contact log is created
-- This keeps the voter record synchronized with the latest contact information
-- Triggered after INSERT on contact_logs table
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION update_voter_support_level()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.support_level IS NOT NULL THEN
        UPDATE voters 
        SET support_level = NEW.support_level, 
            updated_at = NOW()
        WHERE id = NEW.voter_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update voter support level
CREATE TRIGGER trigger_update_voter_support
    AFTER INSERT ON contact_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_voter_support_level();

-- =============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================================================
-- Implements fine-grained access control at the database level
-- Users can only access data they're authorized to see based on their role
-- =============================================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE voters ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_voters ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_logs ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- Users table RLS policies
-- -----------------------------------------------------------------------------

-- Policy: Users can read their own data
CREATE POLICY users_select_own ON users
    FOR SELECT USING (auth.uid() = id);

-- Policy: Managers and admins can read all users
CREATE POLICY users_select_managers ON users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role IN ('admin', 'manager')
        )
    );

-- -----------------------------------------------------------------------------
-- Voters table RLS policies
-- -----------------------------------------------------------------------------

-- Policy: All authenticated users can read voters
CREATE POLICY voters_select_authenticated ON voters
    FOR SELECT USING (auth.role() = 'authenticated');

-- -----------------------------------------------------------------------------
-- Assignments table RLS policies
-- -----------------------------------------------------------------------------

-- Policy: Users can only see their own assignments
CREATE POLICY assignments_select_own ON assignments
    FOR SELECT USING (user_id = auth.uid());

-- Policy: Managers can see all assignments
CREATE POLICY assignments_select_managers ON assignments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role IN ('admin', 'manager')
        )
    );

-- -----------------------------------------------------------------------------
-- Assignment_voters table RLS policies
-- -----------------------------------------------------------------------------

-- Policy: Users can see assignment_voters for their own assignments
CREATE POLICY assignment_voters_select_own ON assignment_voters
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM assignments 
            WHERE id = assignment_id 
            AND user_id = auth.uid()
        )
    );

-- Policy: Managers can see all assignment_voters
CREATE POLICY assignment_voters_select_managers ON assignment_voters
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role IN ('admin', 'manager')
        )
    );

-- -----------------------------------------------------------------------------
-- Contact_logs table RLS policies
-- -----------------------------------------------------------------------------

-- Policy: Users can only log contacts for their assignments
CREATE POLICY contact_logs_insert_own ON contact_logs
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM assignments 
            WHERE id = assignment_id 
            AND user_id = auth.uid()
        )
    );

-- Policy: Users can view their own contact logs
CREATE POLICY contact_logs_select_own ON contact_logs
    FOR SELECT USING (user_id = auth.uid());

-- Policy: Managers can view all contact logs
CREATE POLICY contact_logs_select_managers ON contact_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role IN ('admin', 'manager')
        )
    );

-- =============================================================================
-- SCHEMA CREATION COMPLETE
-- =============================================================================
-- All tables, indexes, triggers, and RLS policies have been created
-- The database is now ready for the FastAPI backend to connect
-- =============================================================================
