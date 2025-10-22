"""
VEP MVP Backend - Contact Logs Tests

Tests for contact logging endpoints including creating contact logs,
tracking voter interactions, and analytics.
"""

import pytest
from fastapi import status
from uuid import uuid4
from datetime import datetime, timedelta


# =============================================================================
# Contact Log CRUD Tests
# =============================================================================

@pytest.mark.api
class TestContactLogEndpoints:
    """Test contact log API endpoints."""

    def test_create_contact_log(
        self, client, auth_headers_canvasser, sample_assignment, sample_voters
    ):
        """Test creating a contact log."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        contact_log = {
            "assignment_id": sample_assignment["id"],
            "voter_id": sample_voters[0]["id"],
            "contact_type": "knocked",
            "result": "Strong supporter, wants yard sign",
            "support_level": 5,
            "location": {"latitude": 30.2672, "longitude": -97.7431},
        }
        
        response = client.post(
            "/contact-logs",
            headers=auth_headers_canvasser,
            json=contact_log,
        )
        
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert "id" in data
        assert "contacted_at" in data

    def test_create_contact_log_updates_voter_support(
        self, client, auth_headers_canvasser, sample_assignment, sample_voters
    ):
        """Test that logging contact updates voter's support level."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        voter = sample_voters[0]
        
        # Log contact with new support level
        contact_log = {
            "assignment_id": sample_assignment["id"],
            "voter_id": voter["id"],
            "contact_type": "knocked",
            "result": "Changed to strong supporter",
            "support_level": 5,
        }
        
        response = client.post(
            "/contact-logs",
            headers=auth_headers_canvasser,
            json=contact_log,
        )
        assert response.status_code == status.HTTP_201_CREATED
        
        # Verify voter's support level updated
        voter_response = client.get(
            f"/voters/{voter['id']}",
            headers=auth_headers_canvasser,
        )
        assert voter_response.json()["support_level"] == 5

    def test_create_contact_log_invalid_assignment(
        self, client, auth_headers_canvasser, sample_voters
    ):
        """Test creating contact log with non-existent assignment."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        contact_log = {
            "assignment_id": str(uuid4()),  # Non-existent
            "voter_id": sample_voters[0]["id"],
            "contact_type": "knocked",
            "result": "Test",
        }
        
        response = client.post(
            "/contact-logs",
            headers=auth_headers_canvasser,
            json=contact_log,
        )
        
        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_create_contact_log_invalid_voter(
        self, client, auth_headers_canvasser, sample_assignment
    ):
        """Test creating contact log with non-existent voter."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        contact_log = {
            "assignment_id": sample_assignment["id"],
            "voter_id": str(uuid4()),  # Non-existent
            "contact_type": "knocked",
            "result": "Test",
        }
        
        response = client.post(
            "/contact-logs",
            headers=auth_headers_canvasser,
            json=contact_log,
        )
        
        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_create_contact_log_invalid_type(
        self, client, auth_headers_canvasser, sample_assignment, sample_voters
    ):
        """Test creating contact log with invalid contact type."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        contact_log = {
            "assignment_id": sample_assignment["id"],
            "voter_id": sample_voters[0]["id"],
            "contact_type": "invalid_type",
            "result": "Test",
        }
        
        response = client.post(
            "/contact-logs",
            headers=auth_headers_canvasser,
            json=contact_log,
        )
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_get_contact_logs_list(self, client, auth_headers_canvasser):
        """Test getting list of contact logs."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get("/contact-logs", headers=auth_headers_canvasser)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "logs" in data
        assert isinstance(data["logs"], list)

    def test_get_contact_log_by_id(
        self, client, auth_headers_canvasser, sample_contact_log
    ):
        """Test getting single contact log by ID."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            f"/contact-logs/{sample_contact_log['id']}",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["id"] == sample_contact_log["id"]

    def test_update_contact_log(
        self, client, auth_headers_canvasser, sample_contact_log
    ):
        """Test updating contact log."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        updates = {
            "result": "Updated result",
            "support_level": 4,
        }
        
        response = client.patch(
            f"/contact-logs/{sample_contact_log['id']}",
            headers=auth_headers_canvasser,
            json=updates,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["result"] == updates["result"]

    def test_update_other_user_contact_log_forbidden(
        self, client, auth_headers_manager, sample_contact_log
    ):
        """Test that users cannot update other users' contact logs."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.patch(
            f"/contact-logs/{sample_contact_log['id']}",
            headers=auth_headers_manager,
            json={"result": "Hacked"},
        )
        
        # Should only be able to update own logs
        assert response.status_code in [
            status.HTTP_403_FORBIDDEN,
            status.HTTP_404_NOT_FOUND,
        ]

    def test_delete_contact_log_admin(
        self, client, auth_headers_admin, sample_contact_log
    ):
        """Test deleting contact log as admin."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.delete(
            f"/contact-logs/{sample_contact_log['id']}",
            headers=auth_headers_admin,
        )
        
        assert response.status_code == status.HTTP_204_NO_CONTENT


# =============================================================================
# Contact Log Filtering Tests
# =============================================================================

@pytest.mark.api
class TestContactLogFiltering:
    """Test contact log filtering functionality."""

    def test_filter_by_assignment(
        self, client, auth_headers_canvasser, sample_assignment
    ):
        """Test filtering contact logs by assignment."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            f"/contact-logs?assignment_id={sample_assignment['id']}",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        for log in data["logs"]:
            assert log["assignment_id"] == sample_assignment["id"]

    def test_filter_by_voter(self, client, auth_headers_canvasser, sample_voters):
        """Test filtering contact logs by voter."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        voter = sample_voters[0]
        response = client.get(
            f"/contact-logs?voter_id={voter['id']}",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        for log in data["logs"]:
            assert log["voter_id"] == voter["id"]

    def test_filter_by_contact_type(self, client, auth_headers_canvasser):
        """Test filtering contact logs by contact type."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            "/contact-logs?contact_type=knocked",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        for log in data["logs"]:
            assert log["contact_type"] == "knocked"

    def test_filter_by_date_range(self, client, auth_headers_canvasser):
        """Test filtering contact logs by date range."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        start_date = (datetime.now() - timedelta(days=7)).isoformat()
        end_date = datetime.now().isoformat()
        
        response = client.get(
            f"/contact-logs?start_date={start_date}&end_date={end_date}",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK

    def test_filter_by_support_level(self, client, auth_headers_manager):
        """Test filtering contact logs by support level."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            "/contact-logs?support_level=5",
            headers=auth_headers_manager,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        for log in data["logs"]:
            if log.get("support_level"):
                assert log["support_level"] == 5

    def test_pagination_contact_logs(self, client, auth_headers_canvasser):
        """Test contact log pagination."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            "/contact-logs?limit=10&offset=0",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "logs" in data
        assert "total" in data
        assert "limit" in data
        assert "offset" in data


# =============================================================================
# Contact Log Statistics Tests
# =============================================================================

@pytest.mark.api
class TestContactLogStatistics:
    """Test contact log statistics and aggregation."""

    def test_get_daily_contact_stats(self, client, auth_headers_canvasser):
        """Test getting daily contact statistics."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        today = datetime.now().date().isoformat()
        response = client.get(
            f"/contact-logs/stats/daily?date={today}",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "total_contacts" in data
        assert "by_type" in data
        assert "by_result" in data

    def test_get_assignment_contact_stats(
        self, client, auth_headers_canvasser, sample_assignment
    ):
        """Test getting contact stats for assignment."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            f"/assignments/{sample_assignment['id']}/stats",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "total_voters" in data
        assert "contacted" in data
        assert "not_contacted" in data

    def test_get_user_contact_stats(
        self, client, auth_headers_canvasser, canvasser_user
    ):
        """Test getting contact stats for user."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        response = client.get(
            f"/users/{canvasser_user['id']}/stats",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "total_contacts" in data
        assert "contacts_today" in data


# =============================================================================
# Contact Types Tests
# =============================================================================

@pytest.mark.unit
class TestContactTypes:
    """Test different contact types."""

    def test_knocked_contact_type(
        self, client, auth_headers_canvasser, sample_assignment, sample_voters
    ):
        """Test logging 'knocked' contact."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        contact_log = {
            "assignment_id": sample_assignment["id"],
            "voter_id": sample_voters[0]["id"],
            "contact_type": "knocked",
            "result": "Home, talked to voter",
        }
        
        response = client.post(
            "/contact-logs",
            headers=auth_headers_canvasser,
            json=contact_log,
        )
        
        assert response.status_code == status.HTTP_201_CREATED

    def test_not_home_contact_type(
        self, client, auth_headers_canvasser, sample_assignment, sample_voters
    ):
        """Test logging 'not_home' contact."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        contact_log = {
            "assignment_id": sample_assignment["id"],
            "voter_id": sample_voters[0]["id"],
            "contact_type": "not_home",
            "result": "No answer",
        }
        
        response = client.post(
            "/contact-logs",
            headers=auth_headers_canvasser,
            json=contact_log,
        )
        
        assert response.status_code == status.HTTP_201_CREATED

    def test_refused_contact_type(
        self, client, auth_headers_canvasser, sample_assignment, sample_voters
    ):
        """Test logging 'refused' contact."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        contact_log = {
            "assignment_id": sample_assignment["id"],
            "voter_id": sample_voters[0]["id"],
            "contact_type": "refused",
            "result": "Refused to engage",
        }
        
        response = client.post(
            "/contact-logs",
            headers=auth_headers_canvasser,
            json=contact_log,
        )
        
        assert response.status_code == status.HTTP_201_CREATED

    def test_phone_contact_type(
        self, client, auth_headers_canvasser, sample_assignment, sample_voters
    ):
        """Test logging 'phone' contact."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        contact_log = {
            "assignment_id": sample_assignment["id"],
            "voter_id": sample_voters[0]["id"],
            "contact_type": "phone",
            "result": "Spoke on phone",
        }
        
        response = client.post(
            "/contact-logs",
            headers=auth_headers_canvasser,
            json=contact_log,
        )
        
        assert response.status_code == status.HTTP_201_CREATED


# =============================================================================
# Offline Sync Tests
# =============================================================================

@pytest.mark.integration
class TestOfflineSync:
    """Test offline contact log syncing."""

    def test_batch_create_contact_logs(
        self, client, auth_headers_canvasser, sample_assignment, sample_voters
    ):
        """Test creating multiple contact logs at once (offline sync)."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        contact_logs = [
            {
                "assignment_id": sample_assignment["id"],
                "voter_id": sample_voters[i]["id"],
                "contact_type": "knocked",
                "result": f"Contact {i}",
                "contacted_at": (datetime.now() - timedelta(hours=i)).isoformat(),
            }
            for i in range(5)
        ]
        
        response = client.post(
            "/contact-logs/batch",
            headers=auth_headers_canvasser,
            json={"logs": contact_logs},
        )
        
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert "created" in data
        assert data["created"] == 5

    def test_batch_create_with_failures(
        self, client, auth_headers_canvasser, sample_assignment, sample_voters
    ):
        """Test batch create with some failures."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        contact_logs = [
            # Valid log
            {
                "assignment_id": sample_assignment["id"],
                "voter_id": sample_voters[0]["id"],
                "contact_type": "knocked",
                "result": "Valid",
            },
            # Invalid log (bad voter ID)
            {
                "assignment_id": sample_assignment["id"],
                "voter_id": str(uuid4()),
                "contact_type": "knocked",
                "result": "Invalid",
            },
        ]
        
        response = client.post(
            "/contact-logs/batch",
            headers=auth_headers_canvasser,
            json={"logs": contact_logs},
        )
        
        # Should create valid ones, report errors for invalid
        assert response.status_code == status.HTTP_207_MULTI_STATUS
        data = response.json()
        assert "created" in data
        assert "errors" in data


# =============================================================================
# Integration Tests
# =============================================================================

@pytest.mark.integration
class TestContactLogIntegration:
    """Integration tests for contact logging."""

    def test_contact_logging_workflow(
        self, client, auth_headers_canvasser, sample_assignment, sample_voters
    ):
        """Test complete contact logging workflow."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # 1. Get assignment with voters
        assignment_response = client.get(
            f"/assignments/{sample_assignment['id']}",
            headers=auth_headers_canvasser,
        )
        assert assignment_response.status_code == status.HTTP_200_OK
        voters = assignment_response.json()["voters"]
        
        # 2. Log contact for first voter
        contact_log = {
            "assignment_id": sample_assignment["id"],
            "voter_id": voters[0]["id"],
            "contact_type": "knocked",
            "result": "Strong supporter",
            "support_level": 5,
        }
        
        log_response = client.post(
            "/contact-logs",
            headers=auth_headers_canvasser,
            json=contact_log,
        )
        assert log_response.status_code == status.HTTP_201_CREATED
        
        # 3. Check updated assignment progress
        progress_response = client.get(
            f"/assignments/{sample_assignment['id']}/progress",
            headers=auth_headers_canvasser,
        )
        assert progress_response.status_code == status.HTTP_200_OK
        assert progress_response.json()["contacted"] >= 1
        
        # 4. Check voter contact history
        voter_response = client.get(
            f"/voters/{voters[0]['id']}/contacts",
            headers=auth_headers_canvasser,
        )
        assert voter_response.status_code == status.HTTP_200_OK
        assert len(voter_response.json()["contacts"]) >= 1

    def test_contact_log_location_tracking(
        self, client, auth_headers_canvasser, sample_assignment, sample_voters
    ):
        """Test that contact logs capture location."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        contact_log = {
            "assignment_id": sample_assignment["id"],
            "voter_id": sample_voters[0]["id"],
            "contact_type": "knocked",
            "result": "Contacted",
            "location": {"latitude": 30.2672, "longitude": -97.7431},
        }
        
        response = client.post(
            "/contact-logs",
            headers=auth_headers_canvasser,
            json=contact_log,
        )
        
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        
        # Verify location was captured
        log_id = data["id"]
        get_response = client.get(
            f"/contact-logs/{log_id}",
            headers=auth_headers_canvasser,
        )
        assert "location" in get_response.json()
