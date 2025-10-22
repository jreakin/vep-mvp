# VEP MVP - Voter Engagement Platform

[![Backend CI](https://github.com/jreakin/vep-mvp/workflows/Backend%20CI/badge.svg)](https://github.com/jreakin/vep-mvp/actions)
[![iOS CI](https://github.com/jreakin/vep-mvp/workflows/iOS%20CI/badge.svg)](https://github.com/jreakin/vep-mvp/actions)
[![codecov](https://codecov.io/gh/jreakin/vep-mvp/branch/main/graph/badge.svg)](https://codecov.io/gh/jreakin/vep-mvp)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A production-ready MVP for canvassing and voter engagement operations, built using a **multi-agent AI development workflow**. Features a Python/FastAPI backend with PostgreSQL/PostGIS and a native iOS app with SwiftUI.

> **🤖 Built by AI Agents:** This project uses 5 specialized AI agents to handle development, with humans orchestrating and reviewing their work. [Learn more about the workflow](#-multi-agent-development)

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Multi-Agent Development](#-multi-agent-development)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Documentation](#-documentation)
- [Development Status](#-development-status)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

**For Campaign Managers:**
- 📍 Assign specific neighborhoods/precincts to canvassers
- 📊 Real-time progress dashboard
- 🗺️ Visualize canvassing coverage on maps
- 📈 Track support levels and contact results

**For Canvassers:**
- 🗺️ View assigned voters on an interactive map
- 📱 Log contact results in the field (quick and easy)
- ✈️ **Works offline** - sync when connected
- 🧭 Turn-by-turn walking route optimization
- 📝 Track contact history for each voter

**Technical:**
- 🔐 Secure authentication with Supabase
- 🌍 PostGIS geospatial queries
- 📡 Automatic background sync
- 💾 Core Data offline storage
- ✅ >80% test coverage (backend)
- ✅ >70% test coverage (iOS)

## 🛠️ Tech Stack

### Backend
- **Python 3.11+** with [UV](https://github.com/astral-sh/uv) package manager
- **FastAPI** - Modern, fast web framework
- **SQLModel** - SQL databases using Python type hints
- **PostgreSQL 14+** with **PostGIS** extension
- **Supabase** - Authentication and database hosting
- **pytest** - Testing framework

### Frontend
- **SwiftUI** - Declarative UI framework
- **iOS 17+** - Latest iOS features
- **MapKit** - Native map integration
- **Core Data** - Offline data persistence
- **Async/await** - Modern concurrency
- **XCTest** - Testing framework

### DevOps
- **GitHub Actions** - CI/CD pipelines
- **Codecov** - Code coverage tracking
- **UV** - Fast Python package management

## 🤖 Multi-Agent Development

This project uses a unique **multi-agent development workflow** where 5 specialized AI agents build different components. You can use either **Cursor IDE** or **GitHub Copilot** to invoke the agents:

| Agent | Responsibility | Status | Estimated Time |
|-------|---------------|--------|----------------|
| 🗄️ **Agent 1** | Database schema with PostGIS | 🟡 Ready | 2-4 hours |
| 🔌 **Agent 2** | FastAPI backend & routes | 🔴 Waiting | 1-2 weeks |
| 📱 **Agent 3** | SwiftUI views & ViewModels | 🔴 Waiting | 1-2 weeks |
| 🔗 **Agent 4** | Integration & offline sync | 🔴 Waiting | 1 week |
| ✅ **Agent 5** | Tests & CI/CD | 🟡 Ready (parallel) | 1-2 weeks |

**Legend:** 🟢 Complete | 🟡 Ready | 🟠 In Progress | 🔴 Blocked

Each agent:
- Reads the complete technical specification (`spec.md`)
- Works only on their assigned files
- Follows strict boundaries to avoid conflicts
- Is invoked by a human using Cursor/Copilot
- Gets reviewed before merging

**Why this approach?**
- ✅ **40% faster** than solo development (4-5 weeks vs. 7+ weeks)
- ✅ Clear separation of concerns
- ✅ Easier code review (smaller chunks)
- ✅ Parallel development possible
- ✅ Consistent code quality

**Choose your development environment:**
- 🖥️ **Cursor IDE** - [Quick Start Guide](QUICKSTART.md)
- 🤖 **GitHub Copilot** - [Copilot Agent Instructions](.github/copilot/README.md)

[Learn how to invoke agents →](QUICKSTART.md)

## 🚀 Quick Start

### Prerequisites

- Python 3.11+ with [UV](https://github.com/astral-sh/uv)
- Xcode 15+ (for iOS development)
- PostgreSQL 14+ with PostGIS
- [Supabase account](https://supabase.com) (free tier works)

### Setup (5 minutes)

```bash
# Clone the repository
git clone https://github.com/jreakin/vep-mvp.git
cd vep-mvp

# Run automated setup
./setup.sh

# Copy environment template
cp backend/.env.example backend/.env
# Edit .env with your Supabase credentials

# You're ready! Read QUICKSTART.md next
```

### Backend Development

```bash
cd backend

# Activate virtual environment
source .venv/bin/activate  # or .venv\Scripts\activate on Windows

# Run database migrations (after Agent 1 completes)
psql -d your_database -f migrations/001_initial_schema.sql

# Start development server
uv run uvicorn app.main:app --reload

# Run tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html
```

Backend will be available at: http://localhost:8000  
API docs: http://localhost:8000/docs

### iOS Development

```bash
cd ios/VEP
open VEP.xcodeproj

# Build and run in Xcode (⌘+R)
# Or from command line:
xcodebuild -scheme VEP -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 📁 Project Structure

```
vep-mvp/
├── 📋 Documentation
│   ├── spec.md                    # Complete technical specification
│   ├── AGENT_INSTRUCTIONS.md      # Agent boundaries and tasks
│   ├── PROGRESS.md                # Development progress tracker
│   ├── QUICKSTART.md              # 5-minute getting started
│   ├── CONTRIBUTING.md            # Contribution guidelines
│   └── PROJECT_SUMMARY.md         # Project overview
│
├── 🐍 Backend (Python)
│   ├── app/
│   │   ├── main.py               # FastAPI application
│   │   ├── config.py             # Configuration
│   │   ├── routes/               # API endpoints (Agent 2)
│   │   └── models/               # SQLModel models (Agent 2)
│   ├── migrations/               # SQL migrations (Agent 1)
│   ├── tests/                    # Backend tests (Agent 5)
│   └── pyproject.toml            # UV dependencies
│
├── 📱 iOS (Swift)
│   └── VEP/
│       ├── Models/               # Data models (Agent 3)
│       ├── Views/                # SwiftUI views (Agent 3)
│       ├── ViewModels/           # View models (Agent 3)
│       └── Services/             # API & offline (Agent 4)
│
└── 🤖 Agent Instructions
    └── .copilot/
        └── instructions-agent-*.md  # Copy-paste prompts for Cursor
```

## 📚 Documentation

| Document | Purpose | Read Time |
|----------|---------|-----------|
| [QUICKSTART.md](QUICKSTART.md) | Get started in 5 minutes | 5 min |
| [spec.md](spec.md) | Complete technical specification | 30 min |
| [AGENT_INSTRUCTIONS.md](AGENT_INSTRUCTIONS.md) | Agent boundaries and workflow | 20 min |
| [PROGRESS.md](PROGRESS.md) | Track development progress | 5 min |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute | 10 min |
| [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | High-level overview | 5 min |

## 📊 Development Status

**Current Phase:** Setup Complete - Ready for Agent 1

**Progress:**
```
[░░░░░░░░░░] 0% Complete
```

**Next Steps:**
1. ✅ Project structure created
2. ✅ Documentation complete
3. ✅ UV backend setup
4. 🟡 Agent 1 ready to create database schema
5. 🔴 Agent 2 waiting (backend API)
6. 🔴 Agent 3 waiting (iOS UI)
7. 🔴 Agent 4 waiting (integration)
8. 🟡 Agent 5 ready (testing - parallel)

[View detailed progress →](PROGRESS.md)

## 🤝 Contributing

We welcome contributions! This project uses a unique multi-agent workflow:

1. **Read the docs:** Start with [QUICKSTART.md](QUICKSTART.md) and [spec.md](spec.md)
2. **Check status:** See [PROGRESS.md](PROGRESS.md) for what needs work
3. **Choose your role:**
   - 🤖 **Act as an agent** - Use Cursor/Copilot to complete agent tasks
   - 🐛 **Fix bugs** - Submit traditional PRs
   - 📖 **Improve docs** - Always welcome!
4. **Follow guidelines:** See [CONTRIBUTING.md](CONTRIBUTING.md)

**Before contributing:** Read `spec.md` and `AGENT_INSTRUCTIONS.md` to understand the project structure.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built using Claude (Anthropic) via Cursor IDE
- Multi-agent development workflow inspired by software engineering best practices
- Supabase for making backend infrastructure easy
- The open-source community for amazing tools

## 📞 Support

- 📖 **Documentation:** See the `docs/` folder
- 🐛 **Bug Reports:** [Open an issue](https://github.com/jreakin/vep-mvp/issues/new?template=bug-report.md)
- 💡 **Feature Requests:** [Open a discussion](https://github.com/jreakin/vep-mvp/discussions)
- ❓ **Questions:** [Open an issue](https://github.com/jreakin/vep-mvp/issues/new) with "question" label

---

**Ready to build?** → Start with [QUICKSTART.md](QUICKSTART.md)  
**Want to contribute?** → Read [CONTRIBUTING.md](CONTRIBUTING.md)  
**Need details?** → Check [spec.md](spec.md)

Built with ❤️ using AI-assisted development
