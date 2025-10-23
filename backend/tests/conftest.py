"""
VEP MVP Backend - Test Configuration and Fixtures

This module provides pytest fixtures for testing the FastAPI backend.
Includes database setup, test client, authentication helpers, and test data.
"""

import asyncio
import os
from typing import AsyncGenerator, Generator
from uuid import uuid4

import pytest
from fastapi.testclient import TestClient
from httpx import AsyncClient
from sqlalchemy import event
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from app.main import app
from app.models.user import User
from app.models.voter import Voter
from app.models.assignment import Assignment, AssignmentVoter
from app.models.contact_log import ContactLog
from app.dependencies import get_db
from app.config import settings


# =============================================================================
# Test Database Configuration
# =============================================================================

# Use in-memory SQLite for fast tests, or PostgreSQL for integration tests
TEST_DATABASE_URL = os.getenv(
    "TEST_DATABASE_URL",
    "sqlite:///./test.db",
)

# For PostgreSQL tests (integration tests)
POSTGRES_TEST_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:postgres@localhost:5432/vep_test",
)


# =============================================================================
# Database Fixtures
# =============================================================================

@pytest.fixture(scope="session")
def event_loop():
    """Create event loop for async tests."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="function")
def db_engine():
    """Create test database engine."""
    # Use SQLite for unit tests (fast)
    engine = create_engine(
        TEST_DATABASE_URL,
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    
    # Create tables from models
    SQLModel.metadata.create_all(bind=engine)
    
    yield engine
    
    # Cleanup
    SQLModel.metadata.drop_all(bind=engine)
    engine.dispose()


@pytest.fixture(scope="function")
def db_session(db_engine) -> Generator[Session, None, None]:
    """Create database session for tests."""
    session = Session(db_engine)
    try:
        yield session
    finally:
        session.rollback()
        session.close()


@pytest.fixture(scope="function")
def client(db_session) -> Generator[TestClient, None, None]:
    """Create FastAPI test client."""
    def override_get_db():
        try:
            yield db_session
        finally:
            pass
    
    app.dependency_overrides[get_db] = override_get_db
    
    with TestClient(app) as test_client:
        yield test_client
    
    app.dependency_overrides.clear()


@pytest.fixture(scope="function")
async def async_client(db_session) -> AsyncGenerator[AsyncClient, None]:
    """Create async HTTP client for tests."""
    def override_get_db():
        try:
            yield db_session
        finally:
            pass
    
    app.dependency_overrides[get_db] = override_get_db
    
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac
    
    app.dependency_overrides.clear()


# =============================================================================
# Authentication Fixtures
# =============================================================================

@pytest.fixture
def test_password() -> str:
    """Standard test password."""
    return "TestPassword123!"


@pytest.fixture
def admin_user(db_session, test_password):
    """Create admin user for testing."""
    user = User(
        id=uuid4(),
        email="admin@test.com",
        full_name="Test Admin",
        role="admin",
        phone="555-0001",
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def manager_user(db_session, test_password):
    """Create manager user for testing."""
    user = User(
        id=uuid4(),
        email="manager@test.com",
        full_name="Test Manager",
        role="manager",
        phone="555-0002",
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def canvasser_user(db_session, test_password):
    """Create canvasser user for testing."""
    user = User(
        id=uuid4(),
        email="canvasser@test.com",
        full_name="Test Canvasser",
        role="canvasser",
        phone="555-0003",
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def auth_headers_admin(admin_user) -> dict:
    """Get authentication headers for admin user."""
    from jose import jwt
    from app.config import settings
    
    token = jwt.encode(
        {"sub": str(admin_user.id), "email": admin_user.email},
        settings.JWT_SECRET,
        algorithm=settings.JWT_ALGORITHM,
    )
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def auth_headers_manager(manager_user) -> dict:
    """Get authentication headers for manager user."""
    from jose import jwt
    from app.config import settings
    
    token = jwt.encode(
        {"sub": str(manager_user.id), "email": manager_user.email},
        settings.JWT_SECRET,
        algorithm=settings.JWT_ALGORITHM,
    )
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def auth_headers_canvasser(canvasser_user) -> dict:
    """Get authentication headers for canvasser user."""
    from jose import jwt
    from app.config import settings
    
    token = jwt.encode(
        {"sub": str(canvasser_user.id), "email": canvasser_user.email},
        settings.JWT_SECRET,
        algorithm=settings.JWT_ALGORITHM,
    )
    return {"Authorization": f"Bearer {token}"}


# =============================================================================
# Test Data Fixtures
# =============================================================================

@pytest.fixture
def sample_voters(db_session):
    """Create sample voters for testing."""
    voters = []
    for i in range(10):
        voter = Voter(
            id=uuid4(),
            voter_id=f"TX{1000000 + i}",
            first_name=f"Voter{i}",
            last_name=f"Test{i}",
            address=f"{100 + i} Main St",
            city="Austin",
            state="TX",
            zip="78701",
            party_affiliation=["D", "R", "I"][i % 3],
            support_level=(i % 5) + 1,
            phone=f"555-010{i}",
            email=f"voter{i}@test.com",
        )
        db_session.add(voter)
        voters.append(voter)
    
    db_session.commit()
    for voter in voters:
        db_session.refresh(voter)
    
    return voters


@pytest.fixture
def sample_assignment(db_session, canvasser_user, sample_voters):
    """Create sample assignment for testing."""
    from datetime import date
    
    assignment = Assignment(
        id=uuid4(),
        user_id=canvasser_user.id,
        name="Test Assignment",
        description="Test assignment for unit tests",
        assigned_date=date(2025, 10, 22),
        due_date=date(2025, 10, 25),
        status="pending",
    )
    db_session.add(assignment)
    db_session.commit()
    db_session.refresh(assignment)
    
    # Link voters to assignment
    for i, voter in enumerate(sample_voters[:5]):
        av = AssignmentVoter(
            assignment_id=assignment.id,
            voter_id=voter.id,
            sequence_order=i + 1,
        )
        db_session.add(av)
    db_session.commit()
    
    return assignment


@pytest.fixture
def sample_contact_log(db_session, sample_assignment, sample_voters):
    """Create sample contact log for testing."""
    from datetime import datetime
    
    contact_log = ContactLog(
        id=uuid4(),
        assignment_id=sample_assignment.id,
        voter_id=sample_voters[0].id,
        user_id=sample_assignment.user_id,
        contact_type="knocked",
        result="Strong supporter, wants yard sign",
        support_level=5,
        contacted_at=datetime.fromisoformat("2025-10-22T14:30:00"),
    )
    db_session.add(contact_log)
    db_session.commit()
    db_session.refresh(contact_log)
    
    return contact_log


# =============================================================================
# Helper Functions
# =============================================================================

def create_test_user(db_session, role: str = "canvasser", **kwargs):
    """Helper to create test user with custom attributes."""
    user = User(
        id=kwargs.get("id", uuid4()),
        email=kwargs.get("email", f"{role}@test.com"),
        full_name=kwargs.get("full_name", f"Test {role.title()}"),
        role=role,
        phone=kwargs.get("phone", "555-0100"),
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


def create_test_voter(db_session, **kwargs):
    """Helper to create test voter with custom attributes."""
    voter = Voter(
        id=kwargs.get("id", uuid4()),
        voter_id=kwargs.get("voter_id", f"TX{uuid4().hex[:8]}"),
        first_name=kwargs.get("first_name", "John"),
        last_name=kwargs.get("last_name", "Doe"),
        address=kwargs.get("address", "123 Main St"),
        city=kwargs.get("city", "Austin"),
        state=kwargs.get("state", "TX"),
        zip=kwargs.get("zip", "78701"),
        party_affiliation=kwargs.get("party_affiliation", "D"),
        support_level=kwargs.get("support_level", 3),
    )
    db_session.add(voter)
    db_session.commit()
    db_session.refresh(voter)
    return voter


# =============================================================================
# PostgreSQL Integration Test Fixtures
# =============================================================================

@pytest.fixture(scope="session")
def postgres_engine():
    """Create PostgreSQL engine for integration tests."""
    if "postgresql" not in POSTGRES_TEST_URL:
        pytest.skip("PostgreSQL not configured for integration tests")
    
    engine = create_engine(POSTGRES_TEST_URL)
    
    # Create tables when models are available
    SQLModel.metadata.create_all(bind=engine)
    
    yield engine
    
    # Cleanup
    SQLModel.metadata.drop_all(bind=engine)
    engine.dispose()


@pytest.fixture(scope="function")
def postgres_session(postgres_engine) -> Generator[Session, None, None]:
    """Create PostgreSQL session for integration tests."""
    session = Session(postgres_engine)
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()


# =============================================================================
# Markers
# =============================================================================

# Use markers to categorize tests:
# @pytest.mark.unit - Fast unit tests
# @pytest.mark.integration - Integration tests with database
# @pytest.mark.slow - Slow running tests
# @pytest.mark.auth - Authentication tests
# @pytest.mark.api - API endpoint tests
