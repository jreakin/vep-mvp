## Description
<!-- Describe your changes in detail -->

## Agent
<!-- Which agent created this PR? -->
- [ ] Agent 1 - Database
- [ ] Agent 2 - Backend API
- [ ] Agent 3 - iOS Frontend
- [ ] Agent 4 - Integration
- [ ] Agent 5 - Testing
- [ ] Human - Manual changes

## Type of Change
- [ ] New feature (Agent completing their assigned task)
- [ ] Bug fix
- [ ] Documentation update
- [ ] Refactoring
- [ ] Configuration change

## Checklist
<!-- Mark completed items with [x] -->

### General
- [ ] I have read the `spec.md` and `AGENT_INSTRUCTIONS.md`
- [ ] My changes follow the project coding standards
- [ ] I have stayed within my agent's file boundaries
- [ ] I have added helpful comments to my code
- [ ] My code follows the spec.md exactly

### Agent-Specific

#### Agent 1 (Database)
- [ ] SQL migration runs without errors
- [ ] All tables created as specified in spec.md Section 2
- [ ] All indexes created
- [ ] RLS policies implemented
- [ ] Trigger created
- [ ] Tested with `psql -d test_db -f migrations/001_initial_schema.sql`

#### Agent 2 (Backend)
- [ ] All routes implemented from spec.md Section 3
- [ ] SQLModel models match database schema
- [ ] Authentication working
- [ ] Error handling implemented
- [ ] Tested with Postman/curl
- [ ] All tests passing (if Agent 5 complete)

#### Agent 3 (iOS)
- [ ] All views implemented from spec.md Section 4.3
- [ ] All ViewModels implemented from spec.md Section 4.4
- [ ] Data models match spec.md Section 4.2
- [ ] Navigation works correctly
- [ ] Compiles without errors
- [ ] Tested in simulator

#### Agent 4 (Integration)
- [ ] APIClient implements all endpoints from spec.md Section 3
- [ ] OfflineStorageService implemented
- [ ] SyncService implemented
- [ ] ViewModels updated to use real services (no more mocks)
- [ ] Offline mode tested
- [ ] End-to-end flow tested

#### Agent 5 (Testing)
- [ ] Backend tests achieve >80% coverage
- [ ] iOS tests achieve >70% coverage
- [ ] All tests passing
- [ ] CI/CD workflows passing
- [ ] Edge cases covered
- [ ] Error cases covered

### Documentation
- [ ] I have updated PROGRESS.md with my completion status
- [ ] I have updated README.md if needed
- [ ] I have added docstrings/comments

## Testing
<!-- Describe how you tested your changes -->

### Backend
```bash
# Commands used to test
cd backend
source .venv/bin/activate
pytest
```

### iOS
```bash
# Tested in Xcode
# Simulator: iPhone 15, iOS 17.2
```

## Screenshots (if applicable)
<!-- Add screenshots of UI changes -->

## Related Issues
<!-- Link to related issues -->
Closes #

## Notes for Reviewers
<!-- Any additional context or notes -->

## Post-Merge Actions
- [ ] Update PROGRESS.md to show this agent is complete
- [ ] Notify next agent they can start (if applicable)
- [ ] Update project board/kanban

---

**Remember:** Each agent should only modify files within their boundaries as defined in AGENT_INSTRUCTIONS.md!
