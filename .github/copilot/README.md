# GitHub Copilot Agents for VEP MVP

This directory contains instructions for using GitHub Copilot Agents to build the VEP MVP project.

## 🤖 How to Use GitHub Copilot Agents

### Prerequisites
- VS Code with GitHub Copilot extension installed
- GitHub Copilot subscription active
- Project cloned locally

### 🚀 Quick Start

1. **Open VS Code** with the project folder
2. **Open a file** in the area you want to work on
3. **Press `Ctrl+I`** (or `Cmd+I` on Mac) to open GitHub Copilot
4. **Copy and paste** the appropriate agent prompt
5. **Let Copilot generate** the code
6. **Review and test** the generated code
7. **Commit and push** when satisfied

## 📋 Agent Instructions

| Agent | File | What They Build | Time Estimate |
|-------|------|----------------|---------------|
| **Agent 1** | [agent-1-database.md](agent-1-database.md) | Database schema | 2-4 hours |
| **Agent 2** | [agent-2-backend.md](agent-2-backend.md) | FastAPI backend | 1-2 weeks |
| **Agent 3** | [agent-3-ios.md](agent-3-ios.md) | SwiftUI iOS app | 1-2 weeks |
| **Agent 4** | [agent-4-integration.md](agent-4-integration.md) | API integration | 1 week |
| **Agent 5** | [agent-5-testing.md](agent-5-testing.md) | Tests & CI/CD | 1-2 weeks |

## 🎯 Agent Workflow

### Step 1: Agent 1 - Database Schema
```bash
# Open VS Code
code /Users/johneakin/PyCharmProjects/vep-mvp

# Open the agent instructions
open .github/copilot/agent-1-database.md

# Press Ctrl+I and paste the prompt from the file
```

### Step 2: Agent 2 - Backend API
```bash
# After Agent 1 is complete
# Open agent-2-backend.md
# Press Ctrl+I and paste the prompt
```

### Step 3: Agent 3 - iOS Frontend
```bash
# After Agent 2 is complete
# Open agent-3-ios.md
# Press Ctrl+I and paste the prompt
```

### Step 4: Agent 4 - Integration
```bash
# After Agent 3 is complete
# Open agent-4-integration.md
# Press Ctrl+I and paste the prompt
```

### Step 5: Agent 5 - Testing
```bash
# Can start after Agent 1
# Open agent-5-testing.md
# Press Ctrl+I and paste the prompt
```

## 💡 Tips for Success

### Before Starting Each Agent
1. **Read the spec** - Always read `spec.md` first
2. **Review previous work** - Check what previous agents built
3. **Understand boundaries** - Each agent has specific files they can modify
4. **Test frequently** - Don't wait until the end to test

### During Development
1. **Be specific** - Give Copilot clear, detailed instructions
2. **Iterate** - Don't expect perfect code on first try
3. **Review carefully** - Always review generated code before committing
4. **Ask for changes** - Tell Copilot what to fix or improve

### After Each Agent
1. **Test the code** - Make sure it works as expected
2. **Commit changes** - Use descriptive commit messages
3. **Update progress** - Mark completed items in `PROGRESS.md`
4. **Document issues** - Note any problems or questions

## 🔧 Troubleshooting

### Copilot Not Responding
- Check your GitHub Copilot subscription
- Restart VS Code
- Check internet connection
- Try a simpler prompt

### Generated Code Not Working
- Check for syntax errors
- Verify dependencies are installed
- Read error messages carefully
- Ask Copilot to fix specific issues

### Code Quality Issues
- Ask Copilot to add error handling
- Request better documentation
- Ask for performance improvements
- Request code cleanup

## 📚 Additional Resources

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [VS Code GitHub Copilot Extension](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot)
- [Project Specification](spec.md)
- [Agent Instructions](AGENT_INSTRUCTIONS.md)

## 🎉 Success Criteria

Your project is complete when:
- [ ] Database schema created and tested
- [ ] Backend API fully functional
- [ ] iOS app working with real data
- [ ] Offline functionality implemented
- [ ] Tests passing with >80% coverage
- [ ] CI/CD pipeline working
- [ ] App deployed to TestFlight

---

**Ready to start?** Open VS Code and begin with Agent 1! 🚀