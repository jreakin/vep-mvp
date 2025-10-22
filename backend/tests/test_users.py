"""
VEP MVP Backend - Users Tests

Tests for user management endpoints including CRUD operations
and role-based access control for user data.
"""

import pytest
from fastapi import status
from uuid import uuid4


# =============================================================================
# User CRUD Tests
# =============================================================================

@pytest.mark.api
class TestUserEndpoints:
    """Test user management API endpoints."""

    def test_get_users_list_admin(self, client, auth_headers_admin):
        """Test that admin can list all users."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get("/users", headers=auth_headers_admin)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "users" in data
        assert isinstance(data["users"], list)

    def test_get_users_list_manager(self, client, auth_headers_manager):
        """Test that manager can list users."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get("/users", headers=auth_headers_manager)
        
        # Managers should be able to see users in their org
        assert response.status_code == status.HTTP_200_OK

    def test_get_users_list_canvasser_forbidden(self, client, auth_headers_canvasser):
        """Test that canvasser cannot list all users."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get("/users", headers=auth_headers_canvasser)
        
        # Canvassers should not have access to user list
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_get_user_by_id(self, client, auth_headers_admin, canvasser_user):
        """Test getting single user by ID."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            f"/users/{canvasser_user['id']}",
            headers=auth_headers_admin,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["id"] == canvasser_user["id"]
        assert data["email"] == canvasser_user["email"]
        assert data["role"] == canvasser_user["role"]

    def test_get_user_not_found(self, client, auth_headers_admin):
        """Test getting non-existent user."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        fake_id = str(uuid4())
        response = client.get(f"/users/{fake_id}", headers=auth_headers_admin)
        
        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_create_user_admin(self, client, auth_headers_admin):
        """Test creating new user as admin."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        new_user = {
            "email": "newuser@test.com",
            "full_name": "New User",
            "role": "canvasser",
            "phone": "555-0200",
        }
        
        response = client.post(
            "/users",
            headers=auth_headers_admin,
            json=new_user,
        )
        
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert data["email"] == new_user["email"]
        assert data["full_name"] == new_user["full_name"]
        assert "id" in data

    def test_create_user_manager(self, client, auth_headers_manager):
        """Test creating new user as manager."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        new_user = {
            "email": "newcanvasser@test.com",
            "full_name": "New Canvasser",
            "role": "canvasser",
            "phone": "555-0201",
        }
        
        response = client.post(
            "/users",
            headers=auth_headers_manager,
            json=new_user,
        )
        
        # Managers can create canvassers
        assert response.status_code == status.HTTP_201_CREATED

    def test_create_user_duplicate_email(self, client, auth_headers_admin, canvasser_user):
        """Test creating user with duplicate email."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        duplicate_user = {
            "email": canvasser_user["email"],  # Duplicate email
            "full_name": "Duplicate User",
            "role": "canvasser",
        }
        
        response = client.post(
            "/users",
            headers=auth_headers_admin,
            json=duplicate_user,
        )
        
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "email" in response.json()["detail"].lower()

    def test_create_user_invalid_role(self, client, auth_headers_admin):
        """Test creating user with invalid role."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        invalid_user = {
            "email": "invalid@test.com",
            "full_name": "Invalid Role User",
            "role": "superuser",  # Invalid role
        }
        
        response = client.post(
            "/users",
            headers=auth_headers_admin,
            json=invalid_user,
        )
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_update_user(self, client, auth_headers_admin, canvasser_user):
        """Test updating user information."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        updates = {
            "full_name": "Updated Name",
            "phone": "555-9999",
        }
        
        response = client.patch(
            f"/users/{canvasser_user['id']}",
            headers=auth_headers_admin,
            json=updates,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["full_name"] == updates["full_name"]
        assert data["phone"] == updates["phone"]

    def test_update_user_role_admin_only(self, client, auth_headers_manager, canvasser_user):
        """Test that only admin can change user roles."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        updates = {"role": "manager"}
        
        response = client.patch(
            f"/users/{canvasser_user['id']}",
            headers=auth_headers_manager,
            json=updates,
        )
        
        # Manager should not be able to change roles
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_update_own_profile(self, client, auth_headers_canvasser, canvasser_user):
        """Test user updating their own profile."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        updates = {
            "full_name": "Updated Self",
            "phone": "555-8888",
        }
        
        response = client.patch(
            f"/users/{canvasser_user['id']}",
            headers=auth_headers_canvasser,
            json=updates,
        )
        
        assert response.status_code == status.HTTP_200_OK

    def test_update_other_user_forbidden(self, client, auth_headers_canvasser, manager_user):
        """Test that canvasser cannot update other users."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        updates = {"full_name": "Hacked Name"}
        
        response = client.patch(
            f"/users/{manager_user['id']}",
            headers=auth_headers_canvasser,
            json=updates,
        )
        
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_delete_user_admin(self, client, auth_headers_admin, db_session):
        """Test deleting user as admin."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # Create a user to delete
        from tests.conftest import create_test_user
        
        user_to_delete = create_test_user(db_session, role="canvasser")
        
        response = client.delete(
            f"/users/{user_to_delete['id']}",
            headers=auth_headers_admin,
        )
        
        assert response.status_code == status.HTTP_204_NO_CONTENT
        
        # Verify user is deleted
        get_response = client.get(
            f"/users/{user_to_delete['id']}",
            headers=auth_headers_admin,
        )
        assert get_response.status_code == status.HTTP_404_NOT_FOUND

    def test_delete_user_forbidden(self, client, auth_headers_canvasser, manager_user):
        """Test that non-admin cannot delete users."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.delete(
            f"/users/{manager_user['id']}",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_403_FORBIDDEN


# =============================================================================
# User Filtering and Search Tests
# =============================================================================

@pytest.mark.api
class TestUserFiltering:
    """Test user filtering and search functionality."""

    def test_filter_users_by_role(self, client, auth_headers_admin):
        """Test filtering users by role."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            "/users?role=canvasser",
            headers=auth_headers_admin,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        for user in data["users"]:
            assert user["role"] == "canvasser"

    def test_search_users_by_email(self, client, auth_headers_admin):
        """Test searching users by email."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            "/users?search=canvasser@test.com",
            headers=auth_headers_admin,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert len(data["users"]) > 0

    def test_search_users_by_name(self, client, auth_headers_admin):
        """Test searching users by name."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            "/users?search=Canvasser",
            headers=auth_headers_admin,
        )
        
        assert response.status_code == status.HTTP_200_OK

    def test_pagination(self, client, auth_headers_admin):
        """Test user list pagination."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # First page
        response = client.get(
            "/users?limit=10&offset=0",
            headers=auth_headers_admin,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "users" in data
        assert "total" in data
        assert "limit" in data
        assert "offset" in data


# =============================================================================
# User Validation Tests
# =============================================================================

@pytest.mark.unit
class TestUserValidation:
    """Test user data validation."""

    def test_valid_email_format(self, client, auth_headers_admin):
        """Test email format validation."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        invalid_emails = [
            "notanemail",
            "@test.com",
            "test@",
            "test@.com",
            "test..test@test.com",
        ]
        
        for email in invalid_emails:
            response = client.post(
                "/users",
                headers=auth_headers_admin,
                json={
                    "email": email,
                    "full_name": "Test User",
                    "role": "canvasser",
                },
            )
            assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_required_fields(self, client, auth_headers_admin):
        """Test that required fields are enforced."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # Missing email
        response = client.post(
            "/users",
            headers=auth_headers_admin,
            json={
                "full_name": "Test User",
                "role": "canvasser",
            },
        )
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY
        
        # Missing full_name
        response = client.post(
            "/users",
            headers=auth_headers_admin,
            json={
                "email": "test@test.com",
                "role": "canvasser",
            },
        )
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY
        
        # Missing role
        response = client.post(
            "/users",
            headers=auth_headers_admin,
            json={
                "email": "test@test.com",
                "full_name": "Test User",
            },
        )
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_phone_format_validation(self, client, auth_headers_admin):
        """Test phone number format validation."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # Valid phone formats
        valid_phones = [
            "555-1234",
            "(555) 123-4567",
            "555.123.4567",
            "5551234567",
        ]
        
        for phone in valid_phones:
            response = client.post(
                "/users",
                headers=auth_headers_admin,
                json={
                    "email": f"test{phone.replace('-', '')}@test.com",
                    "full_name": "Test User",
                    "role": "canvasser",
                    "phone": phone,
                },
            )
            # Should accept various phone formats
            assert response.status_code in [
                status.HTTP_201_CREATED,
                status.HTTP_400_BAD_REQUEST,
            ]


# =============================================================================
# Integration Tests
# =============================================================================

@pytest.mark.integration
class TestUserIntegration:
    """Integration tests for user operations."""

    def test_user_lifecycle(self, client, auth_headers_admin):
        """Test complete user lifecycle: create, read, update, delete."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # 1. Create user
        new_user = {
            "email": "lifecycle@test.com",
            "full_name": "Lifecycle Test",
            "role": "canvasser",
            "phone": "555-0300",
        }
        
        create_response = client.post(
            "/users",
            headers=auth_headers_admin,
            json=new_user,
        )
        assert create_response.status_code == status.HTTP_201_CREATED
        user_id = create_response.json()["id"]
        
        # 2. Read user
        read_response = client.get(
            f"/users/{user_id}",
            headers=auth_headers_admin,
        )
        assert read_response.status_code == status.HTTP_200_OK
        assert read_response.json()["email"] == new_user["email"]
        
        # 3. Update user
        update_response = client.patch(
            f"/users/{user_id}",
            headers=auth_headers_admin,
            json={"full_name": "Updated Lifecycle"},
        )
        assert update_response.status_code == status.HTTP_200_OK
        assert update_response.json()["full_name"] == "Updated Lifecycle"
        
        # 4. Delete user
        delete_response = client.delete(
            f"/users/{user_id}",
            headers=auth_headers_admin,
        )
        assert delete_response.status_code == status.HTTP_204_NO_CONTENT
        
        # 5. Verify deletion
        final_response = client.get(
            f"/users/{user_id}",
            headers=auth_headers_admin,
        )
        assert final_response.status_code == status.HTTP_404_NOT_FOUND

    def test_cascade_delete_user_with_assignments(self, client, auth_headers_admin, db_session):
        """Test that deleting user cascades to their assignments."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # This test ensures that when a user is deleted,
        # their assignments are also deleted (cascade behavior)
        from tests.conftest import create_test_user
        
        user = create_test_user(db_session, role="canvasser")
        
        # Create assignment for user (TODO: implement when assignment tests are ready)
        # ...
        
        # Delete user
        response = client.delete(
            f"/users/{user['id']}",
            headers=auth_headers_admin,
        )
        assert response.status_code == status.HTTP_204_NO_CONTENT
        
        # Check that assignments are also deleted
        # ...
