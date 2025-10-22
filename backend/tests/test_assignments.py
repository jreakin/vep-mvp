"""
VEP MVP Backend - Assignments Tests

Tests for assignment management endpoints including creating, updating,
and managing canvassing assignments with voters.
"""

import pytest
from fastapi import status
from uuid import uuid4


# =============================================================================
# Assignment CRUD Tests
# =============================================================================

@pytest.mark.api
class TestAssignmentEndpoints:
    """Test assignment management API endpoints."""

    def test_get_assignments_list(self, client, auth_headers_canvasser):
        """Test getting list of assignments."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get("/assignments", headers=auth_headers_canvasser)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "assignments" in data
        assert isinstance(data["assignments"], list)

    def test_get_assignments_filtered_by_user(
        self, client, auth_headers_canvasser, canvasser_user
    ):
        """Test that canvassers only see their own assignments."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get("/assignments", headers=auth_headers_canvasser)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        # All returned assignments should belong to the canvasser
        for assignment in data["assignments"]:
            assert assignment["user_id"] == canvasser_user["id"]

    def test_get_assignments_manager_sees_all(self, client, auth_headers_manager):
        """Test that managers see all assignments."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get("/assignments", headers=auth_headers_manager)
        
        assert response.status_code == status.HTTP_200_OK
        # Managers should see all assignments, not just their own

    def test_get_assignment_by_id(
        self, client, auth_headers_canvasser, sample_assignment
    ):
        """Test getting single assignment by ID."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            f"/assignments/{sample_assignment['id']}",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["id"] == sample_assignment["id"]
        assert data["name"] == sample_assignment["name"]
        assert "voters" in data

    def test_get_assignment_not_found(self, client, auth_headers_canvasser):
        """Test getting non-existent assignment."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        fake_id = str(uuid4())
        response = client.get(
            f"/assignments/{fake_id}",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_create_assignment_manager(
        self, client, auth_headers_manager, canvasser_user, sample_voters
    ):
        """Test creating new assignment as manager."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        new_assignment = {
            "name": "New Assignment",
            "description": "Test assignment",
            "user_id": canvasser_user["id"],
            "voter_ids": [v["id"] for v in sample_voters[:5]],
            "due_date": "2025-10-25",
        }
        
        response = client.post(
            "/assignments",
            headers=auth_headers_manager,
            json=new_assignment,
        )
        
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert data["name"] == new_assignment["name"]
        assert data["status"] == "pending"
        assert "id" in data

    def test_create_assignment_canvasser_forbidden(
        self, client, auth_headers_canvasser
    ):
        """Test that canvasser cannot create assignments."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        new_assignment = {
            "name": "Unauthorized Assignment",
            "user_id": str(uuid4()),
            "voter_ids": [],
        }
        
        response = client.post(
            "/assignments",
            headers=auth_headers_canvasser,
            json=new_assignment,
        )
        
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_create_assignment_invalid_user(
        self, client, auth_headers_manager, sample_voters
    ):
        """Test creating assignment with non-existent user."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        new_assignment = {
            "name": "Invalid User Assignment",
            "user_id": str(uuid4()),  # Non-existent user
            "voter_ids": [v["id"] for v in sample_voters[:3]],
        }
        
        response = client.post(
            "/assignments",
            headers=auth_headers_manager,
            json=new_assignment,
        )
        
        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_create_assignment_invalid_voters(
        self, client, auth_headers_manager, canvasser_user
    ):
        """Test creating assignment with non-existent voters."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        new_assignment = {
            "name": "Invalid Voters Assignment",
            "user_id": canvasser_user["id"],
            "voter_ids": [str(uuid4()), str(uuid4())],  # Non-existent voters
        }
        
        response = client.post(
            "/assignments",
            headers=auth_headers_manager,
            json=new_assignment,
        )
        
        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_update_assignment_status(
        self, client, auth_headers_canvasser, sample_assignment
    ):
        """Test updating assignment status."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        updates = {"status": "in_progress"}
        
        response = client.patch(
            f"/assignments/{sample_assignment['id']}",
            headers=auth_headers_canvasser,
            json=updates,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["status"] == "in_progress"

    def test_update_assignment_complete(
        self, client, auth_headers_canvasser, sample_assignment
    ):
        """Test marking assignment as completed."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        updates = {"status": "completed"}
        
        response = client.patch(
            f"/assignments/{sample_assignment['id']}",
            headers=auth_headers_canvasser,
            json=updates,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["status"] == "completed"

    def test_update_assignment_invalid_status(
        self, client, auth_headers_canvasser, sample_assignment
    ):
        """Test updating assignment with invalid status."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        updates = {"status": "invalid_status"}
        
        response = client.patch(
            f"/assignments/{sample_assignment['id']}",
            headers=auth_headers_canvasser,
            json=updates,
        )
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_update_other_user_assignment_forbidden(
        self, client, auth_headers_canvasser, db_session, manager_user
    ):
        """Test that canvasser cannot update other users' assignments."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # Create assignment for manager
        other_assignment = {
            "id": str(uuid4()),
            "user_id": manager_user["id"],
            "name": "Manager's Assignment",
            "status": "pending",
        }
        
        response = client.patch(
            f"/assignments/{other_assignment['id']}",
            headers=auth_headers_canvasser,
            json={"status": "completed"},
        )
        
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_delete_assignment_manager(
        self, client, auth_headers_manager, sample_assignment
    ):
        """Test deleting assignment as manager."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.delete(
            f"/assignments/{sample_assignment['id']}",
            headers=auth_headers_manager,
        )
        
        assert response.status_code == status.HTTP_204_NO_CONTENT

    def test_delete_assignment_canvasser_forbidden(
        self, client, auth_headers_canvasser, sample_assignment
    ):
        """Test that canvasser cannot delete assignments."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.delete(
            f"/assignments/{sample_assignment['id']}",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_403_FORBIDDEN


# =============================================================================
# Assignment Filtering Tests
# =============================================================================

@pytest.mark.api
class TestAssignmentFiltering:
    """Test assignment filtering and search functionality."""

    def test_filter_assignments_by_status(self, client, auth_headers_manager):
        """Test filtering assignments by status."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            "/assignments?status=pending",
            headers=auth_headers_manager,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        for assignment in data["assignments"]:
            assert assignment["status"] == "pending"

    def test_filter_assignments_by_date_range(self, client, auth_headers_manager):
        """Test filtering assignments by date range."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            "/assignments?start_date=2025-10-20&end_date=2025-10-30",
            headers=auth_headers_manager,
        )
        
        assert response.status_code == status.HTTP_200_OK

    def test_filter_assignments_by_user(self, client, auth_headers_manager, canvasser_user):
        """Test filtering assignments by user."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            f"/assignments?user_id={canvasser_user['id']}",
            headers=auth_headers_manager,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        for assignment in data["assignments"]:
            assert assignment["user_id"] == canvasser_user["id"]

    def test_search_assignments_by_name(self, client, auth_headers_manager):
        """Test searching assignments by name."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            "/assignments?search=Test",
            headers=auth_headers_manager,
        )
        
        assert response.status_code == status.HTTP_200_OK

    def test_pagination_assignments(self, client, auth_headers_manager):
        """Test assignment list pagination."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            "/assignments?limit=10&offset=0",
            headers=auth_headers_manager,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "assignments" in data
        assert "total" in data
        assert "limit" in data
        assert "offset" in data


# =============================================================================
# Assignment Voters Tests
# =============================================================================

@pytest.mark.api
class TestAssignmentVoters:
    """Test assignment-voter relationship management."""

    def test_get_assignment_with_voters(
        self, client, auth_headers_canvasser, sample_assignment
    ):
        """Test getting assignment includes voter list."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            f"/assignments/{sample_assignment['id']}",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "voters" in data
        assert isinstance(data["voters"], list)
        assert len(data["voters"]) > 0

    def test_voters_ordered_by_sequence(
        self, client, auth_headers_canvasser, sample_assignment
    ):
        """Test that voters are returned in sequence order."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            f"/assignments/{sample_assignment['id']}",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        voters = data["voters"]
        
        # Verify voters are in sequence order
        for i in range(len(voters) - 1):
            assert voters[i]["sequence_order"] <= voters[i + 1]["sequence_order"]

    def test_add_voters_to_assignment(
        self, client, auth_headers_manager, sample_assignment, sample_voters
    ):
        """Test adding voters to existing assignment."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        new_voter_ids = [sample_voters[5]["id"], sample_voters[6]["id"]]
        
        response = client.post(
            f"/assignments/{sample_assignment['id']}/voters",
            headers=auth_headers_manager,
            json={"voter_ids": new_voter_ids},
        )
        
        assert response.status_code == status.HTTP_200_OK

    def test_remove_voter_from_assignment(
        self, client, auth_headers_manager, sample_assignment, sample_voters
    ):
        """Test removing voter from assignment."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        voter_to_remove = sample_voters[0]["id"]
        
        response = client.delete(
            f"/assignments/{sample_assignment['id']}/voters/{voter_to_remove}",
            headers=auth_headers_manager,
        )
        
        assert response.status_code == status.HTTP_204_NO_CONTENT

    def test_reorder_assignment_voters(
        self, client, auth_headers_manager, sample_assignment, sample_voters
    ):
        """Test reordering voters in assignment."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        new_order = [
            {"voter_id": sample_voters[2]["id"], "sequence_order": 1},
            {"voter_id": sample_voters[0]["id"], "sequence_order": 2},
            {"voter_id": sample_voters[1]["id"], "sequence_order": 3},
        ]
        
        response = client.patch(
            f"/assignments/{sample_assignment['id']}/voters/reorder",
            headers=auth_headers_manager,
            json={"voters": new_order},
        )
        
        assert response.status_code == status.HTTP_200_OK


# =============================================================================
# Assignment Progress Tests
# =============================================================================

@pytest.mark.api
class TestAssignmentProgress:
    """Test assignment progress tracking."""

    def test_get_assignment_progress(
        self, client, auth_headers_canvasser, sample_assignment
    ):
        """Test getting assignment progress statistics."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            f"/assignments/{sample_assignment['id']}/progress",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "total_voters" in data
        assert "contacted" in data
        assert "remaining" in data
        assert "completion_percentage" in data

    def test_assignment_auto_complete(
        self, client, auth_headers_canvasser, sample_assignment, sample_voters
    ):
        """Test that assignment auto-completes when all voters contacted."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # Log contact for all voters in assignment
        for voter in sample_voters[:5]:  # Assuming 5 voters in sample_assignment
            client.post(
                "/contact-logs",
                headers=auth_headers_canvasser,
                json={
                    "assignment_id": sample_assignment["id"],
                    "voter_id": voter["id"],
                    "contact_type": "knocked",
                    "result": "Contacted",
                },
            )
        
        # Check assignment status
        response = client.get(
            f"/assignments/{sample_assignment['id']}",
            headers=auth_headers_canvasser,
        )
        
        data = response.json()
        # Assignment should auto-complete or show 100% progress
        assert data["status"] == "completed" or data.get("completion_percentage") == 100


# =============================================================================
# Integration Tests
# =============================================================================

@pytest.mark.integration
class TestAssignmentIntegration:
    """Integration tests for assignment operations."""

    def test_assignment_lifecycle(
        self, client, auth_headers_manager, auth_headers_canvasser, 
        canvasser_user, sample_voters
    ):
        """Test complete assignment lifecycle."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # 1. Manager creates assignment
        create_response = client.post(
            "/assignments",
            headers=auth_headers_manager,
            json={
                "name": "Lifecycle Test",
                "user_id": canvasser_user["id"],
                "voter_ids": [v["id"] for v in sample_voters[:3]],
                "due_date": "2025-10-25",
            },
        )
        assert create_response.status_code == status.HTTP_201_CREATED
        assignment_id = create_response.json()["id"]
        
        # 2. Canvasser views assignment
        view_response = client.get(
            f"/assignments/{assignment_id}",
            headers=auth_headers_canvasser,
        )
        assert view_response.status_code == status.HTTP_200_OK
        
        # 3. Canvasser starts assignment
        start_response = client.patch(
            f"/assignments/{assignment_id}",
            headers=auth_headers_canvasser,
            json={"status": "in_progress"},
        )
        assert start_response.status_code == status.HTTP_200_OK
        
        # 4. Canvasser completes assignment
        complete_response = client.patch(
            f"/assignments/{assignment_id}",
            headers=auth_headers_canvasser,
            json={"status": "completed"},
        )
        assert complete_response.status_code == status.HTTP_200_OK
        
        # 5. Verify final status
        final_response = client.get(
            f"/assignments/{assignment_id}",
            headers=auth_headers_canvasser,
        )
        assert final_response.json()["status"] == "completed"
