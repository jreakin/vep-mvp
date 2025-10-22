# VEP MVP Test Suite

Comprehensive test suite for the Voter Engagement Platform MVP covering backend API and iOS application.

## Overview

This test suite provides **>4,760 lines** of test code covering:
- **Backend**: FastAPI endpoints, authentication, database operations, spatial queries
- **iOS**: ViewModels, Services, Models, and UI flows
- **Integration**: End-to-end workflows and cross-service interactions

## Backend Tests

### Structure

```
backend/tests/
├── conftest.py              # Test fixtures and configuration
├── test_auth.py            # Authentication and authorization
├── test_users.py           # User management
├── test_assignments.py     # Assignment operations
├── test_voters.py          # Voter management and spatial queries
├── test_contact_logs.py    # Contact logging and statistics
└── test_integration.py     # End-to-end workflows
```

### Running Backend Tests

```bash
# Navigate to backend directory
cd backend

# Run all tests
uv run pytest

# Run with coverage report
uv run pytest --cov=app --cov-report=html

# Run specific test file
uv run pytest tests/test_auth.py

# Run tests by marker
uv run pytest -m unit          # Fast unit tests only
uv run pytest -m integration   # Integration tests only
uv run pytest -m api           # API endpoint tests
uv run pytest -m "not slow"    # Skip slow tests

# Run tests in parallel (faster)
uv run pytest -n auto

# Run with verbose output
uv run pytest -vv
```

### Test Categories

Tests are organized using pytest markers:

- **`@pytest.mark.unit`**: Fast unit tests with no external dependencies
- **`@pytest.mark.integration`**: Integration tests requiring database
- **`@pytest.mark.api`**: API endpoint tests
- **`@pytest.mark.auth`**: Authentication and authorization tests
- **`@pytest.mark.slow`**: Performance tests with large datasets

### Coverage Goals

- **Target**: >80% code coverage for backend
- **Critical paths**: 100% coverage for auth and contact logging
- **All endpoints**: Full CRUD coverage from spec.md Section 3

### Test Fixtures

Common fixtures in `conftest.py`:

- `client`: FastAPI test client
- `async_client`: Async HTTP client
- `db_session`: Database session for tests
- `admin_user`, `manager_user`, `canvasser_user`: Test users with different roles
- `auth_headers_*`: Authentication headers for different roles
- `sample_voters`: Sample voter data
- `sample_assignment`: Sample assignment with voters
- `sample_contact_log`: Sample contact log

## iOS Tests

### Structure

```
ios/VEPTests/
├── ViewModelsTests.swift   # ViewModel unit tests
├── ServicesTests.swift     # Service layer tests
├── ModelsTests.swift       # Model and Codable tests
└── UITests.swift          # UI and integration tests
```

### Running iOS Tests

```bash
# Navigate to iOS directory
cd ios

# Run unit tests
xcodebuild test \
  -scheme VEP \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' \
  -enableCodeCoverage YES

# Run UI tests only
xcodebuild test \
  -scheme VEP \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' \
  -only-testing:VEPUITests

# Run in Xcode
# Open VEP.xcodeproj and press Cmd+U
```

### Test Coverage

- **ViewModels**: State management, user interactions, async operations
- **Services**: API client, offline storage, sync service, location tracking
- **Models**: Codable conformance, computed properties, validation
- **UI Tests**: Complete user flows, offline functionality, performance

### Coverage Goals

- **Target**: >70% code coverage for iOS
- **Critical flows**: 100% coverage for canvassing workflow
- **Offline sync**: Full coverage of sync queue and offline storage

## CI/CD Integration

### Backend CI

Tests run automatically on:
- Pull requests to `main` or `develop`
- Pushes to `main` or `develop`
- Changes to `backend/**` files

Workflow: `.github/workflows/backend-tests.yml`

**Steps:**
1. Set up Python 3.11 and PostgreSQL (PostGIS)
2. Install dependencies with `uv`
3. Run database migrations
4. Run linting (ruff, black, mypy)
5. Run tests with coverage
6. Upload coverage to Codecov
7. Run security scan (bandit)

### iOS CI

Tests run automatically on:
- Pull requests to `main` or `develop`
- Pushes to `main` or `develop`
- Changes to `ios/**` files

Workflow: `.github/workflows/ios-tests.yml`

**Steps:**
1. Set up Xcode 15.0 on macOS
2. Resolve Swift Package Manager dependencies
3. Run unit tests with coverage
4. Run UI tests
5. Generate and upload coverage reports
6. Build for iOS simulator and device

### Deployment

Workflow: `.github/workflows/deploy.yml`

Runs on push to `main` and deploys:
- Backend to production (Supabase)
- iOS to TestFlight

## Test Data

### Backend Test Database

Tests use an in-memory SQLite database for unit tests and PostgreSQL for integration tests.

**Environment Variables:**
- `TEST_DATABASE_URL`: SQLite for fast tests
- `DATABASE_URL`: PostgreSQL for integration tests

### iOS Test Data

iOS tests use in-memory Core Data for offline storage tests and mock API clients for service tests.

## Best Practices

### Writing Tests

1. **Use descriptive test names**: `test_create_assignment_with_invalid_user`
2. **Follow AAA pattern**: Arrange, Act, Assert
3. **Test one thing**: Each test should verify one behavior
4. **Use fixtures**: Reuse test data through fixtures
5. **Mock external dependencies**: Don't hit real APIs in unit tests
6. **Test error cases**: Include negative test cases
7. **Add markers**: Use pytest markers to categorize tests

### Example Test

```python
@pytest.mark.api
@pytest.mark.auth
def test_login_with_invalid_credentials(client):
    """Test that login fails with wrong password."""
    # Arrange
    credentials = {
        "email": "user@test.com",
        "password": "wrong-password"
    }
    
    # Act
    response = client.post("/auth/login", json=credentials)
    
    # Assert
    assert response.status_code == 401
    assert "detail" in response.json()
```

## Test Implementation Status

### Backend Tests

| Test File | Lines | Status | Coverage |
|-----------|-------|--------|----------|
| conftest.py | 400+ | ✅ Ready | N/A |
| test_auth.py | 400+ | ⏸️ Waiting for Agent 2 | TBD |
| test_users.py | 450+ | ⏸️ Waiting for Agent 2 | TBD |
| test_assignments.py | 550+ | ⏸️ Waiting for Agent 2 | TBD |
| test_voters.py | 550+ | ⏸️ Waiting for Agent 2 | TBD |
| test_contact_logs.py | 600+ | ⏸️ Waiting for Agent 2 | TBD |
| test_integration.py | 550+ | ⏸️ Waiting for Agent 2 | TBD |

**Note**: All tests are written and ready. They are currently marked with `pytest.skip()` until Agent 2 completes the backend implementation.

### iOS Tests

| Test File | Lines | Status | Coverage |
|-----------|-------|--------|----------|
| ViewModelsTests.swift | 340+ | ⏸️ Waiting for Agents 3 & 4 | TBD |
| ServicesTests.swift | 380+ | ⏸️ Waiting for Agents 3 & 4 | TBD |
| ModelsTests.swift | 490+ | ⏸️ Waiting for Agents 3 & 4 | TBD |
| UITests.swift | 450+ | ⏸️ Waiting for Agents 3 & 4 | TBD |

**Note**: All tests are written and ready. They are currently marked with `XCTSkip()` until Agents 3 & 4 complete the iOS implementation.

## Activating Tests

Once implementation is complete:

### Backend
1. Remove `pytest.skip()` statements from test files
2. Import actual models and functions
3. Uncomment TODO sections in conftest.py
4. Run tests: `uv run pytest`

### iOS
1. Remove `throw XCTSkip()` statements from test files
2. Ensure models and ViewModels are properly imported
3. Run tests in Xcode or via xcodebuild

## Performance Benchmarks

### Backend

- **API response time**: <200ms for simple queries
- **Database queries**: <100ms for most operations
- **Spatial queries**: <500ms for nearby voter searches
- **Batch operations**: <3s for 50 contact logs

### iOS

- **ViewModel state updates**: <100ms
- **Offline sync**: <5s for 50 pending logs
- **Map rendering**: <2s for 100 voter pins
- **UI navigation**: <1s between views

## Troubleshooting

### Backend Tests Failing

**Issue**: Database connection errors
```bash
# Check PostgreSQL is running
psql postgresql://postgres:postgres@localhost:5432/vep_test -c "SELECT 1"

# Run migrations
cd backend/migrations
for f in *.sql; do psql $DATABASE_URL -f $f; done
```

**Issue**: Import errors
```bash
# Ensure dependencies are installed
cd backend
uv pip install -e ".[dev]"
```

### iOS Tests Failing

**Issue**: Simulator not available
```bash
# List available simulators
xcrun simctl list devices available

# Boot simulator
xcrun simctl boot "iPhone 15"
```

**Issue**: Build failures
```bash
# Clean build
xcodebuild clean -scheme VEP
rm -rf ~/Library/Developer/Xcode/DerivedData
```

## Contributing

When adding new features:

1. **Write tests first** (TDD approach)
2. **Update this README** with new test information
3. **Maintain coverage** above target thresholds
4. **Use appropriate markers** for test categorization
5. **Add fixtures** for reusable test data

## Resources

- [pytest Documentation](https://docs.pytest.org/)
- [FastAPI Testing](https://fastapi.tiangolo.com/tutorial/testing/)
- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Codecov](https://codecov.io/)

## Contact

For questions about the test suite, see:
- `.github/copilot/agent-5-testing.md` - Testing agent instructions
- `spec.md` Section 6 - Testing requirements
- `AGENT_INSTRUCTIONS.md` - Agent 5 section
