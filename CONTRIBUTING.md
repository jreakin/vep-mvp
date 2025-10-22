# Contributing to VEP MVP

Thank you for your interest in contributing! This project uses a unique **multi-agent development workflow** where AI agents handle most of the coding.

## 🤖 Multi-Agent Workflow

This project is built by **5 specialized AI agents**, each responsible for a specific component:

1. **Agent 1 - Database:** PostgreSQL schema with PostGIS
2. **Agent 2 - Backend:** FastAPI routes and models
3. **Agent 3 - Frontend:** SwiftUI views and ViewModels
4. **Agent 4 - Integration:** Service layer and offline support
5. **Agent 5 - Testing:** Test suites and CI/CD

**You** are the orchestrator - you invoke agents, review their work, and merge it.

## 📚 Required Reading

Before contributing, read these files **in order**:

1. **`spec.md`** - Complete technical specification (30 min)
2. **`AGENT_INSTRUCTIONS.md`** - Agent boundaries and tasks (20 min)
3. **`PROGRESS.md`** - Current development status (5 min)
4. **`QUICKSTART.md`** - Getting started guide (5 min)

## 🚀 Getting Started

### Prerequisites

- **Python 3.11+** with UV package manager
- **Xcode 15+** for iOS development
- **PostgreSQL 14+** with PostGIS extension
- **Cursor IDE** or VS Code with GitHub Copilot (recommended)
- **Supabase account** (free tier works)

### Setup

```bash
# Clone the repository
git clone https://github.com/YOUR-USERNAME/vep-mvp.git
cd vep-mvp

# Run automated setup
./setup.sh

# Or manually:
cd backend
uv venv
source .venv/bin/activate
uv pip install -e ".[dev]"

# Copy environment template
cp backend/.env.example backend/.env
# Edit .env with your Supabase credentials
```

## 🎯 Contributing as a Human

### For Bug Fixes or Small Changes

1. **Create an issue** using the bug report template
2. **Fork the repository**
3. **Create a feature branch:** `git checkout -b fix/bug-description`
4. **Make your changes** (stay within file boundaries!)
5. **Test thoroughly**
6. **Commit:** `git commit -m "fix: description"`
7. **Push:** `git push origin fix/bug-description`
8. **Create Pull Request** using the PR template

### For Agent Work

If you're acting as an "agent" (using AI to complete a component):

1. **Check PROGRESS.md** to see which agent should work next
2. **Create an issue** using the Agent Task template
3. **Read the agent's section** in `AGENT_INSTRUCTIONS.md`
4. **Invoke the agent** in Cursor:
   - Open Cursor
   - Press `Cmd+I` (Composer)
   - Copy prompt from `.copilot/instructions-agent-X.md`
   - Paste and let the agent work
5. **Review the agent's output** carefully
6. **Test the code** before committing
7. **Create a PR** with the agent's work
8. **Update PROGRESS.md** after merge

## 🔒 Critical Rules

### DO NOT:
- ❌ Modify files outside your agent's boundaries
- ❌ Change the spec.md without discussion
- ❌ Deviate from spec.md requirements
- ❌ Skip error handling or tests
- ❌ Commit untested code
- ❌ Break other agents' work

### DO:
- ✅ Read spec.md and AGENT_INSTRUCTIONS.md first
- ✅ Stay within file boundaries
- ✅ Add helpful comments and docstrings
- ✅ Write tests for your code
- ✅ Follow code style guidelines
- ✅ Update PROGRESS.md after completing work

## 📐 Code Style

### Python (Backend)
- **Formatter:** Black (line length 100)
- **Linter:** Ruff
- **Type hints:** Required for all functions
- **Docstrings:** Google style
- **Imports:** Absolute imports, sorted with isort

```python
from typing import Optional
from fastapi import APIRouter, Depends
from app.models.user import User

def get_user(user_id: str) -> Optional[User]:
    """
    Get user by ID.
    
    Args:
        user_id: UUID of the user
        
    Returns:
        User object or None if not found
    """
    pass
```

### Swift (iOS)
- **Naming:** SwiftLint conventions
- **Access Control:** Use `private`, `fileprivate` when appropriate
- **Comments:** Document complex logic
- **MVVM:** Strict separation of concerns

```swift
/// ViewModel for the assignment list view.
final class AssignmentListViewModel: ObservableObject {
    @Published private(set) var assignments: [Assignment] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    /// Load all assignments for the current user.
    func loadAssignments() async {
        // Implementation
    }
}
```

## 🧪 Testing

### Backend Tests
- **Framework:** pytest with pytest-asyncio
- **Coverage:** Minimum 80%
- **Run tests:** `cd backend && pytest`
- **Run with coverage:** `pytest --cov=app --cov-report=html`

### iOS Tests
- **Framework:** XCTest
- **Coverage:** Minimum 70%
- **Run tests:** Build and test in Xcode
- **Unit tests:** Test ViewModels, Services
- **UI tests:** Test critical user flows

## 📝 Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature (Agent completing their task)
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(database): Add initial schema with PostGIS (Agent 1)
feat(backend): Implement assignments API endpoints (Agent 2)
feat(ios): Create assignment list view (Agent 3)
fix(backend): Handle 404 error in voter endpoint
docs: Update README with deployment instructions
```

## 🔄 Pull Request Process

1. **Create PR** using the template
2. **Fill out all sections** of the PR template
3. **Link related issues**
4. **Ensure CI passes** (all tests green)
5. **Request review** from maintainers
6. **Address feedback** promptly
7. **Squash commits** if requested
8. **Celebrate** when merged! 🎉

### PR Review Checklist

Reviewers will check:
- [ ] Code follows spec.md exactly
- [ ] Agent stayed within file boundaries
- [ ] Tests included and passing
- [ ] Code is well-documented
- [ ] No breaking changes to other agents' work
- [ ] PROGRESS.md updated
- [ ] CI/CD passing

## 🐛 Reporting Bugs

1. **Check existing issues** first
2. **Use bug report template**
3. **Include:**
   - Clear description
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details
   - Error logs/screenshots
4. **Label appropriately** (bug, backend, ios, etc.)

## 💡 Suggesting Features

For now, we're focused on completing the MVP as specified in `spec.md`.

**Feature requests should:**
1. Align with MVP goals
2. Not conflict with spec.md
3. Be discussed in an issue first
4. Get approval before implementation

## 📊 Project Status

Check **PROGRESS.md** for:
- Which agents have completed their work
- Which agent should work next
- Current blockers
- Overall progress percentage

## 🆘 Getting Help

- **Technical questions:** Open an issue with the "question" label
- **Spec clarification:** Reference spec.md section in issue
- **Agent workflow:** See AGENT_INSTRUCTIONS.md
- **Setup issues:** Check QUICKSTART.md

## 📞 Communication

- **Issues:** Use for bug reports, agent tasks, questions
- **Pull Requests:** Use for code reviews
- **Discussions:** Use GitHub Discussions for general chat

## 🎯 Agent Execution Order

Agents must work in this sequence:

```
Agent 1 (Database) 
    ↓
Agent 2 (Backend) 
    ↓
Agent 3 (Frontend)
    ↓
Agent 4 (Integration)
    ↓
Agent 5 (Testing - can work in parallel after Agent 1)
```

**Check PROGRESS.md before starting work!**

## ⚖️ License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙏 Thank You!

Every contribution helps make this project better. Whether you're fixing a typo or completing an entire agent task, your work is appreciated!

---

**Questions?** Open an issue with the "question" label.  
**Ready to contribute?** Check PROGRESS.md to see what needs to be done next!
