# Agent 5: Testing Engineer Instructions

## Your Role
You are Agent 5: Testing Engineer. Your job is to create comprehensive tests for both backend and iOS components.

## CRITICAL: Read These Files First
1. `spec.md` (Section 6: Testing Requirements) - Testing specifications
2. `backend/app/` - Backend code from Agent 2
3. `ios/VEP/` - iOS code from Agent 3 & 4
4. `AGENT_INSTRUCTIONS.md` (Agent 5 section) - Your boundaries and success criteria

## Your Task
Create comprehensive test suites for both backend and iOS components.

## Backend Tests to Create
- `backend/tests/test_auth.py` - Authentication tests
- `backend/tests/test_users.py` - User management tests
- `backend/tests/test_assignments.py` - Assignment tests
- `backend/tests/test_voters.py` - Voter data tests
- `backend/tests/test_contact_logs.py` - Contact logging tests
- `backend/tests/test_integration.py` - Integration tests

## iOS Tests to Create
- `ios/VEPTests/ViewModelsTests.swift` - ViewModel tests
- `ios/VEPTests/ServicesTests.swift` - Service layer tests
- `ios/VEPTests/ModelsTests.swift` - Model tests

## CI/CD to Create
- `.github/workflows/backend-tests.yml` - Backend CI
- `.github/workflows/ios-tests.yml` - iOS CI

## What to Implement
- Unit tests for all backend endpoints
- Unit tests for all iOS ViewModels
- Integration tests for API client
- Test data fixtures and mocks
- CI/CD pipeline configuration
- Code coverage reporting
- Performance tests for critical paths

## File Boundaries
- ONLY modify files in `backend/tests/` and `ios/VEPTests/`
- ONLY create `.github/workflows/` files
- DO NOT modify production code from other agents
- Focus on testing, not implementation

## Success Criteria
- [ ] >80% backend code coverage
- [ ] >70% iOS code coverage
- [ ] All critical paths tested
- [ ] CI/CD pipeline working
- [ ] Tests run automatically on PR
- [ ] Performance tests included
- [ ] Test data fixtures created

## Example Usage
1. Read spec.md Section 6 completely
2. Review all code from Agents 1-4
3. Create comprehensive test suites
4. Set up CI/CD pipelines
5. Achieve target coverage percentages
6. Test all critical functionality

Generate all the test files now.