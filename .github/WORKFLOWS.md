# GitHub Actions Workflows

## 🚀 Overview

This repository includes comprehensive CI/CD workflows for the VEP MVP project, covering backend testing, iOS testing, deployment, project automation, code quality, and releases.

## 📋 Workflow Summary

| Workflow | Trigger | Purpose | Status |
|----------|---------|---------|--------|
| **Backend Tests** | Push/PR to main/develop | Test Python backend with PostgreSQL | ✅ Active |
| **iOS Tests** | Push/PR to main/develop | Test iOS app with Xcode | ✅ Active |
| **Deploy** | Push to main | Deploy backend and iOS to production | ✅ Active |
| **Project Automation** | Issues/PRs | Auto-update project board and dependencies | ✅ Active |
| **Code Quality** | Push/PR + Weekly | Run linting, security, and quality checks | ✅ Active |
| **Release** | Tags + Manual | Create releases with artifacts | ✅ Active |

## 🔧 Workflow Details

### 1. Backend Tests (`backend-tests.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Only when `backend/` files change

**Features:**
- ✅ PostgreSQL with PostGIS support
- ✅ Python 3.11 with UV package manager
- ✅ Database migrations
- ✅ Linting (Ruff, Black, MyPy)
- ✅ Test coverage reporting
- ✅ Security scanning (Bandit)
- ✅ Codecov integration

**Services:**
- PostgreSQL 15 with PostGIS 3.3
- Health checks and connection testing

### 2. iOS Tests (`ios-tests.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Only when `ios/` files change

**Features:**
- ✅ Xcode 15.0 with iOS 17.0 simulator
- ✅ Swift Package Manager caching
- ✅ Unit tests with code coverage
- ✅ UI tests
- ✅ Build verification for simulator and device
- ✅ Archive creation for App Store

**Test Targets:**
- iPhone 15 simulator (iOS 17.0)
- Generic iOS device builds
- App Store archive

### 3. Deploy (`deploy.yml`)

**Triggers:**
- Push to `main` branch
- Manual workflow dispatch
- Only when relevant files change

**Features:**
- ✅ Backend deployment with database migrations
- ✅ iOS deployment to TestFlight
- ✅ Health checks after deployment
- ✅ Conditional deployment (only changed components)
- ✅ Deployment status notifications

**Environment Variables Required:**
- `DATABASE_URL` - Production database connection
- `JWT_SECRET_KEY` - JWT signing key
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key
- `SUPABASE_SERVICE_ROLE_KEY` - Supabase service role key
- `APP_STORE_CONNECT_API_KEY` - App Store Connect API key
- `APP_STORE_CONNECT_ISSUER_ID` - App Store Connect issuer ID
- `APP_STORE_CONNECT_KEY_ID` - App Store Connect key ID

### 4. Project Automation (`project-automation.yml`)

**Triggers:**
- Issue events (opened, closed, assigned, labeled)
- Pull request events (opened, closed, merged, labeled)
- Project card events

**Features:**
- ✅ Auto-update project status using GitHub Projects V2 API
- ✅ Auto-unblock dependent issues
- ✅ Update issue status based on events
- ✅ Update PROGRESS.md automatically
- ✅ Dependency resolution
- ✅ Support for both organization and user projects

**Automation Rules:**
- Issue assigned → Move to "In Progress"
- PR created/reopened → Move to "Code Review"
- PR merged → Move to "Testing"
- PR closed (not merged) → Move back to "Ready"
- Issue closed → Move to "Done"
- Agent completed → Unblock dependent agents

**Technical Details:**
- Uses GitHub Projects V2 API (not Classic Projects)
- Automatically detects organization vs. user projects
- Supports status field with custom options
- Handles emoji prefixes in status names (🟠, 🟡, 👀, ✅, 🎉)

### 5. Code Quality (`code-quality.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Weekly schedule (Mondays)

**Features:**
- ✅ Backend quality checks (Black, Ruff, MyPy, Bandit)
- ✅ iOS quality checks (SwiftLint, SwiftFormat)
- ✅ Security vulnerability scanning
- ✅ Dependency auditing
- ✅ Performance testing
- ✅ Complexity analysis

**Quality Metrics:**
- Code formatting compliance
- Linting errors and warnings
- Type checking accuracy
- Security vulnerabilities
- Code complexity scores
- Performance benchmarks

### 6. Release (`release.yml`)

**Triggers:**
- Git tags (v*)
- Manual workflow dispatch

**Features:**
- ✅ Automatic changelog generation
- ✅ Backend package building
- ✅ iOS archive creation
- ✅ Release asset uploads
- ✅ Pre-release detection
- ✅ Version validation

**Release Process:**
1. Create git tag: `git tag v1.0.0`
2. Push tag: `git push origin v1.0.0`
3. Workflow automatically:
   - Generates changelog from commits
   - Builds backend package
   - Creates iOS archive
   - Uploads release assets
   - Creates GitHub release

## 🔐 Secrets Required

### Repository Secrets
Add these in GitHub Settings → Secrets and variables → Actions:

**Backend:**
- `DATABASE_URL` - Production database connection string
- `JWT_SECRET_KEY` - JWT signing secret
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key
- `SUPABASE_SERVICE_ROLE_KEY` - Supabase service role key

**iOS:**
- `APP_STORE_CONNECT_API_KEY` - App Store Connect API key
- `APP_STORE_CONNECT_ISSUER_ID` - App Store Connect issuer ID
- `APP_STORE_CONNECT_KEY_ID` - App Store Connect key ID

**Deployment:**
- `BACKEND_URL` - Production backend URL for health checks

## 📊 Workflow Status

### Current Status
- ✅ All workflows are active and configured
- ✅ Backend tests run on every push/PR
- ✅ iOS tests run on every push/PR
- ✅ Project automation is enabled
- ✅ Code quality checks run weekly
- ✅ Release workflow is ready

### Coverage
- **Backend:** >80% code coverage target
- **iOS:** >70% code coverage target
- **Security:** Bandit + Safety scanning
- **Quality:** Ruff + SwiftLint + MyPy

## 🚀 Usage

### Running Tests Locally
```bash
# Backend
cd backend
uv run pytest
uv run ruff check .
uv run black --check .
uv run mypy .

# iOS
cd ios
xcodebuild test -scheme VEP -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'
swiftlint lint
```

### Creating a Release
```bash
# Create and push a tag
git tag v1.0.0
git push origin v1.0.0

# Or use manual workflow dispatch in GitHub Actions
```

### Monitoring Workflows
- **Actions Tab:** https://github.com/jreakin/vep-mvp/actions
- **Project Board:** Auto-updated by workflows
- **Issues:** Auto-updated by project automation

## 🔧 Customization

### Adding New Tests
1. Add test files to `backend/tests/` or `ios/VEPTests/`
2. Workflows will automatically pick them up
3. Update coverage targets if needed

### Modifying Deployment
1. Edit `.github/workflows/deploy.yml`
2. Add your deployment commands
3. Update environment variables

### Adding Quality Checks
1. Edit `.github/workflows/code-quality.yml`
2. Add new tools to the appropriate job
3. Update artifact uploads

## 🆘 Troubleshooting

### Common Issues

**Backend Tests Failing:**
- Check PostgreSQL connection
- Verify environment variables
- Check database migrations

**iOS Tests Failing:**
- Verify Xcode version compatibility
- Check simulator availability
- Verify Swift Package Manager dependencies

**Deployment Failing:**
- Check secrets are set correctly
- Verify deployment targets are accessible
- Check health check endpoints

**Project Automation Not Working:**
- Verify workflow uses GitHub Projects V2 (not Classic Projects)
- Ensure project board is owned by the repository owner (user or org)
- Check that project name includes "VEP MVP"
- Verify Status field exists with expected options
- Check workflow logs for detailed error messages

### Debug Steps
1. Check workflow logs in Actions tab
2. Verify all secrets are set
3. Check file paths and permissions
4. Verify trigger conditions

## 📈 Metrics and Reporting

### Coverage Reports
- Backend: Uploaded to Codecov
- iOS: Generated in Xcode and uploaded
- Reports available in Actions artifacts

### Quality Reports
- Ruff, Black, MyPy reports
- SwiftLint, SwiftFormat reports
- Security scan results
- Performance benchmarks

### Project Tracking
- Automatic project board updates
- Issue dependency resolution
- Progress tracking in PROGRESS.md

---

**All workflows are ready to use!** 🎉

The CI/CD pipeline will automatically test, build, and deploy your VEP MVP as you develop with the multi-agent workflow.