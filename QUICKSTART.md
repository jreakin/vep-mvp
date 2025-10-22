# VEP MVP - Quick Start Guide

## 🎯 What is This?

This is a **multi-agent developed** MVP for voter canvassing operations. The project is designed to be built by 5 AI agents working sequentially, each handling a specific part of the system.

**You** are the orchestrator - you invoke each agent, review their work, and merge it together.

---

## 📁 Project Structure

```
vep-mvp/
├── spec.md                    # 🔴 MOST IMPORTANT - Read this first!
├── AGENT_INSTRUCTIONS.md      # Detailed instructions for each agent
├── PROGRESS.md                # Track development progress
├── README.md                  # Project overview
├── setup.sh                   # Automated setup script
│
├── backend/                   # Python FastAPI backend
│   ├── app/                   # Application code
│   │   ├── main.py           # FastAPI entry point (skeleton)
│   │   ├── config.py         # Configuration (skeleton)
│   │   ├── routes/           # API routes (Agent 2 creates)
│   │   └── models/           # SQLModel models (Agent 2 creates)
│   ├── migrations/           # Database migrations (Agent 1 creates)
│   ├── tests/                # Backend tests (Agent 5 creates)
│   ├── pyproject.toml        # UV project configuration
│   └── .env.example          # Environment variables template
│
├── ios/                       # SwiftUI iOS app
│   └── VEP/
│       ├── Models/           # Swift data models (Agent 3 creates)
│       ├── Views/            # SwiftUI views (Agent 3 creates)
│       ├── ViewModels/       # View models (Agent 3 creates)
│       └── Services/         # API & offline services (Agent 4 creates)
│
└── .copilot/                  # Cursor/Copilot instructions
    └── instructions-agent-*.md
```

---

## 🚀 Getting Started (5 Minutes)

### Step 1: Initial Setup

```bash
# Clone/navigate to the project
cd ~/PyCharmProjects/vep-mvp

# Run automated setup
./setup.sh

# Or manually:
cd backend
uv venv
source .venv/bin/activate
uv pip install -e ".[dev]"
```

### Step 2: Read the Spec

**CRITICAL:** Read `spec.md` completely before starting. This document is the **source of truth** for all agents.

```bash
# Open and read these files in order:
1. spec.md              # Complete technical specification
2. AGENT_INSTRUCTIONS.md # Agent boundaries and tasks
3. PROGRESS.md          # Track what needs to be done
```

### Step 3: Set Up Supabase (Optional - can do later)

1. Go to https://supabase.com
2. Create a new project
3. Copy connection details
4. Update `backend/.env` with your credentials

---

## 👥 Multi-Agent Workflow

### How This Works

You don't write the code - **AI agents write it for you**. You orchestrate them.

**The Process:**
1. You invoke Agent 1 in Cursor: "Create the database schema"
2. Agent 1 reads `spec.md` and creates the SQL migration
3. You review, test, and commit
4. You invoke Agent 2: "Create the backend API"
5. Agent 2 reads Agent 1's work and creates FastAPI routes
6. Repeat for Agents 3-5

### Agent Order (MUST follow this sequence)

```
Agent 1 (Database) → Agent 2 (Backend) → Agent 3 (Frontend) → Agent 4 (Integration)
                                              ↓
                                         Agent 5 (Testing - parallel)
```

### Time Estimates

- **Agent 1:** 2-4 hours (Database schema)
- **Agent 2:** 1-2 weeks (Backend API)
- **Agent 3:** 1-2 weeks (iOS UI)
- **Agent 4:** 1 week (Integration)
- **Agent 5:** 1-2 weeks (Testing - parallel)

**Total:** 4-5 weeks with AI assistance vs. 7+ weeks solo

---

## 🎮 How to Invoke Agents (Cursor IDE)

### Agent 1: Database Schema

1. Open Cursor
2. Press `Cmd+I` (or `Ctrl+I`) to open Composer
3. Switch to "Agent" mode
4. Paste:

```
You are Agent 1: Database Engineer.

CRITICAL: Read these files first:
1. spec.md (Section 2: Database Schema)
2. AGENT_INSTRUCTIONS.md (Agent 1 section)

Your task:
Create backend/migrations/001_initial_schema.sql

Include:
- PostGIS extension
- All 5 tables from spec.md Section 2
- All indexes and constraints
- RLS policies
- Trigger for voter support updates

Generate the complete file now.
```

5. Wait 1-2 minutes
6. Review the generated SQL
7. Test: `psql -d your_db -f backend/migrations/001_initial_schema.sql`
8. Commit: `git add . && git commit -m "feat: Add database schema (Agent 1)"`

### Agent 2: Backend API

After Agent 1 is done:

```
You are Agent 2: Backend Engineer.

CRITICAL: Read these files first:
1. spec.md (Section 3: Backend API)
2. backend/migrations/001_initial_schema.sql
3. AGENT_INSTRUCTIONS.md (Agent 2 section)

Your task:
Create complete FastAPI backend in backend/app/

Start with:
1. Complete config.py and dependencies.py
2. Create SQLModel models matching the database
3. Create all routes from spec.md Section 3

Follow spec.md API exactly.
Generate the files now.
```

### Continue for Agents 3, 4, 5...

See `.copilot/instructions-agent-*.md` for exact prompts.

---

## 📋 Development Checklist

### Pre-Development (You - 2-3 hours)
- [x] Create spec.md
- [x] Create AGENT_INSTRUCTIONS.md
- [x] Set up directory structure
- [x] Create skeleton files
- [x] Set up UV for Python
- [ ] Push to GitHub
- [ ] Create Supabase project

### Agent 1 (Database - 2-4 hours)
- [ ] Create SQL migration file
- [ ] Test migration runs successfully
- [ ] Commit and push

### Agent 2 (Backend - 1-2 weeks)
- [ ] Create all FastAPI routes
- [ ] Create SQLModel models
- [ ] Implement authentication
- [ ] Test with Postman/curl
- [ ] Commit and push

### Agent 3 (Frontend - 1-2 weeks)
- [ ] Create Swift models
- [ ] Create ViewModels (with mocks)
- [ ] Create all SwiftUI views
- [ ] Test in simulator
- [ ] Commit and push

### Agent 4 (Integration - 1 week)
- [ ] Create APIClient
- [ ] Create OfflineStorageService
- [ ] Create SyncService
- [ ] Replace Agent 3's mocks with real services
- [ ] Test end-to-end
- [ ] Commit and push

### Agent 5 (Testing - 1-2 weeks, parallel)
- [ ] Write backend tests (pytest)
- [ ] Write iOS tests (XCTest)
- [ ] Set up CI/CD (GitHub Actions)
- [ ] Achieve >80% backend coverage
- [ ] Achieve >70% iOS coverage
- [ ] Commit and push

### Deployment
- [ ] Deploy backend to Supabase
- [ ] Deploy iOS to TestFlight
- [ ] Test with real users
- [ ] 🎉 MVP Complete!

---

## 🆘 Common Issues

### "UV not found"
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
```

### "Agent is deviating from spec.md"
Stop immediately. Re-paste the agent instructions with emphasis:
```
STOP. Read spec.md Section X again.
You must follow it EXACTLY. No changes.
```

### "Agent modified files outside its boundaries"
Revert the changes:
```bash
git checkout -- [files-to-revert]
```
Then re-invoke with clearer boundaries.

### "I don't understand the multi-agent workflow"
Think of it like this:
- You're the project manager
- AI agents are specialized developers
- You assign tasks, they code, you review
- Each agent only touches their assigned files

---

## 📚 Key Files to Know

| File | Purpose | When to Read |
|------|---------|-------------|
| `spec.md` | **Source of truth** - Complete technical spec | Before everything |
| `AGENT_INSTRUCTIONS.md` | Agent boundaries and tasks | Before invoking agents |
| `PROGRESS.md` | Track development progress | After each agent |
| `.copilot/instructions-agent-*.md` | Copy-paste agent prompts | When invoking each agent |

---

## 🎯 Success Criteria

**Your MVP is done when:**
1. ✅ Manager can create assignments with voter lists
2. ✅ Canvasser can see assigned voters on a map
3. ✅ Canvasser can log contacts while offline
4. ✅ Contacts sync when connection restored
5. ✅ Manager can view progress dashboard
6. ✅ All tests pass (>75% coverage)
7. ✅ App deployed to TestFlight
8. ✅ Backend deployed to Supabase

---

## 🚦 Next Steps

1. **Read spec.md completely** (30 minutes)
2. **Set up Supabase project** (10 minutes)
3. **Push to GitHub** (5 minutes)
4. **Open Cursor and invoke Agent 1** (copy from `.copilot/instructions-agent-1.md`)
5. **Review Agent 1's work** (30 minutes)
6. **Commit and move to Agent 2**

---

## 📞 Need Help?

- **Spec Questions:** Re-read `spec.md` Section X
- **Agent Questions:** Re-read `AGENT_INSTRUCTIONS.md` Agent X section
- **Workflow Questions:** Re-read this file

---

**Remember:** The spec is law. Agents must follow it exactly. If something is unclear, update the spec first, then re-run the agent.

**Good luck! 🚀**
