# GitHub Copilot Agent 5: Testing Engineer

## 🎯 Your Mission
You are Agent 5: Testing Engineer. Create comprehensive tests for both backend and iOS components.

## 📋 Instructions for GitHub Copilot

### Step 1: Read the Specification
1. Open `spec.md` and read Section 6: Testing Requirements
2. Open `backend/app/` (from Agent 2) to understand backend code
3. Open `ios/VEP/` (from Agent 3 & 4) to understand iOS code
4. Open `AGENT_INSTRUCTIONS.md` and read the Agent 5 section

### Step 2: Create Backend Tests

**Files to Create:**
- `backend/tests/test_auth.py` - Authentication tests
- `backend/tests/test_users.py` - User management tests
- `backend/tests/test_assignments.py` - Assignment tests
- `backend/tests/test_voters.py` - Voter data tests
- `backend/tests/test_contact_logs.py` - Contact logging tests
- `backend/tests/test_integration.py` - Integration tests
- `backend/tests/conftest.py` - Test configuration and fixtures

### Step 3: Create iOS Tests

**Files to Create:**
- `ios/VEPTests/ViewModelsTests.swift` - ViewModel tests
- `ios/VEPTests/ServicesTests.swift` - Service layer tests
- `ios/VEPTests/ModelsTests.swift` - Model tests
- `ios/VEPTests/UITests.swift` - UI tests

### Step 4: Create CI/CD

**Files to Create:**
- `.github/workflows/backend-tests.yml` - Backend CI
- `.github/workflows/ios-tests.yml` - iOS CI
- `.github/workflows/deploy.yml` - Deployment pipeline

### Step 5: Backend Test Requirements

**Test Coverage:**
- Unit tests for all API endpoints
- Authentication and authorization tests
- Database operation tests
- Error handling tests
- Input validation tests
- Integration tests with test database

**Test Data:**
- Fixtures for all models
- Mock external services
- Test database setup/teardown
- Realistic test scenarios

**Tools:**
- pytest for test framework
- pytest-asyncio for async tests
- httpx for API testing
- pytest-cov for coverage
- Factory Boy for test data

### Step 6: iOS Test Requirements

**Test Coverage:**
- Unit tests for ViewModels
- Service layer tests
- Model validation tests
- UI tests for critical flows
- Offline functionality tests

**Test Data:**
- Mock API responses
- Sample data for testing
- Test user scenarios
- Edge case handling

**Tools:**
- XCTest for test framework
- Mocking for external dependencies
- UI testing for user flows
- Performance testing

### Step 7: CI/CD Requirements

**Backend CI:**
- Run tests on Python 3.11+
- Install dependencies with UV
- Run linting and formatting
- Generate coverage reports
- Upload to Codecov

**iOS CI:**
- Run tests on multiple iOS versions
- Build for different devices
- Run UI tests
- Generate coverage reports
- Upload to Codecov

**Deployment:**
- Deploy backend to Supabase
- Build iOS for TestFlight
- Run integration tests
- Notify on success/failure

### Step 8: Success Criteria
- [ ] >80% backend code coverage
- [ ] >70% iOS code coverage
- [ ] All critical paths tested
- [ ] CI/CD pipeline working
- [ ] Tests run automatically on PR
- [ ] Performance tests included
- [ ] Test data fixtures created

### Step 9: Testing
After creating the tests:
1. Run backend tests: `uv run pytest`
2. Run iOS tests in Xcode
3. Check CI/CD pipelines
4. Verify coverage reports
5. Test deployment process

## 🚀 Ready to Start?

Open VS Code with GitHub Copilot and say:
"I need to create comprehensive tests for the VEP MVP project. Please read spec.md Section 6 and create all the test files with CI/CD pipelines."