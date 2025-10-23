"""
VEP MVP Backend - Voters Tests

Tests for voter management endpoints including search, filtering,
and spatial queries using PostGIS.
"""

import pytest
from fastapi import status
from uuid import uuid4


# =============================================================================
# Voter CRUD Tests
# =============================================================================

@pytest.mark.api
class TestVoterEndpoints:
    """Test voter management API endpoints."""

    def test_get_voters_list(self, client, auth_headers_canvasser):
        """Test getting list of voters."""
        response = client.get("/voters", headers=auth_headers_canvasser)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "voters" in data
        assert isinstance(data["voters"], list)

    def test_get_voter_by_id(self, client, auth_headers_canvasser, sample_voters):
        """Test getting single voter by ID."""
        voter = sample_voters[0]
        response = client.get(
            f"/voters/{voter.id}",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["id"] == voter.id
        assert data["voter_id"] == voter.voter_id
        assert data["first_name"] == voter.first_name

    def test_get_voter_not_found(self, client, auth_headers_canvasser):
        """Test getting non-existent voter."""
        fake_id = str(uuid4())
        response = client.get(f"/voters/{fake_id}", headers=auth_headers_canvasser)
        
        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_create_voter_manager(self, client, auth_headers_manager):
        """Test creating new voter as manager."""
        new_voter = {
            "voter_id": "TX99999999",
            "first_name": "New",
            "last_name": "Voter",
            "address": "999 Test St",
            "city": "Austin",
            "state": "TX",
            "zip": "78701",
            "location": {"latitude": 30.2672, "longitude": -97.7431},
            "party_affiliation": "D",
            "support_level": 3,
        }
        
        response = client.post(
            "/voters",
            headers=auth_headers_manager,
            json=new_voter,
        )
        
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert data["voter_id"] == new_voter.voter_id
        assert "id" in data

    def test_create_voter_duplicate_voter_id(
        self, client, auth_headers_manager, sample_voters
    ):
        """Test creating voter with duplicate voter_id."""
        duplicate_voter = {
            "voter_id": sample_voters[0].voter_id,  # Duplicate
            "first_name": "Duplicate",
            "last_name": "Voter",
            "address": "123 Test St",
            "city": "Austin",
            "state": "TX",
            "zip": "78701",
        }
        
        response = client.post(
            "/voters",
            headers=auth_headers_manager,
            json=duplicate_voter,
        )
        
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_create_voter_canvasser_forbidden(self, client, auth_headers_canvasser):
        """Test that canvasser cannot create voters."""
        new_voter = {
            "voter_id": "TX88888888",
            "first_name": "Test",
            "last_name": "Voter",
            "address": "123 St",
            "city": "Austin",
            "state": "TX",
            "zip": "78701",
        }
        
        response = client.post(
            "/voters",
            headers=auth_headers_canvasser,
            json=new_voter,
        )
        
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_update_voter(self, client, auth_headers_manager, sample_voters):
        """Test updating voter information."""
        voter = sample_voters[0]
        updates = {
            "phone": "555-9999",
            "email": "updated@test.com",
            "support_level": 5,
        }
        
        response = client.patch(
            f"/voters/{voter.id}",
            headers=auth_headers_manager,
            json=updates,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["phone"] == updates["phone"]
        assert data["email"] == updates["email"]
        assert data["support_level"] == updates["support_level"]

    def test_update_voter_canvasser_forbidden(
        self, client, auth_headers_canvasser, sample_voters
    ):
        """Test that canvasser cannot update voter data."""
        voter = sample_voters[0]
        response = client.patch(
            f"/voters/{voter.id}",
            headers=auth_headers_canvasser,
            json={"support_level": 4},
        )
        
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_delete_voter_admin(self, client, auth_headers_admin, db_session):
        """Test deleting voter as admin."""
        from tests.conftest import create_test_voter
        
        voter = create_test_voter(db_session)
        
        response = client.delete(
            f"/voters/{voter.id}",
            headers=auth_headers_admin,
        )
        
        assert response.status_code == status.HTTP_204_NO_CONTENT


# =============================================================================
# Voter Search and Filtering Tests
# =============================================================================

@pytest.mark.api
class TestVoterSearchAndFilter:
    """Test voter search and filtering functionality."""

    def test_filter_voters_by_zip(self, client, auth_headers_canvasser):
        """Test filtering voters by ZIP code."""
        response = client.get(
            "/voters?zip=78701",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        for voter in data["voters"]:
            assert voter.zip == "78701"

    def test_filter_voters_by_city(self, client, auth_headers_canvasser):
        """Test filtering voters by city."""
        response = client.get(
            "/voters?city=Austin",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        for voter in data["voters"]:
            assert voter.city == "Austin"

    def test_filter_voters_by_support_level(self, client, auth_headers_manager):
        """Test filtering voters by support level."""
        response = client.get(
            "/voters?support_level=5",
            headers=auth_headers_manager,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        for voter in data["voters"]:
            assert voter.support_level == 5

    def test_filter_voters_by_party(self, client, auth_headers_canvasser):
        """Test filtering voters by party affiliation."""
        response = client.get(
            "/voters?party=D",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        for voter in data["voters"]:
            assert voter.party_affiliation == "D"

    def test_search_voters_by_name(self, client, auth_headers_canvasser):
        """Test searching voters by name."""
        response = client.get(
            "/voters?search=Smith",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        # Results should contain "Smith" in first or last name
        for voter in data["voters"]:
            name = f"{voter['first_name']} {voter['last_name']}".lower()
            assert "smith" in name

    def test_search_voters_by_address(self, client, auth_headers_canvasser):
        """Test searching voters by address."""
        response = client.get(
            "/voters?search=Main St",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK

    def test_pagination_voters(self, client, auth_headers_canvasser):
        """Test voter list pagination."""
        response = client.get(
            "/voters?limit=10&offset=0",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "voters" in data
        assert "total" in data
        assert "limit" in data
        assert "offset" in data


# =============================================================================
# Spatial Query Tests (PostGIS)
# =============================================================================

@pytest.mark.integration
class TestVoterSpatialQueries:
    """Test spatial queries using PostGIS."""

    def test_find_voters_nearby(self, client, auth_headers_canvasser):
        """Test finding voters within radius of location."""
        response = client.get(
            "/voters/nearby?latitude=30.2672&longitude=-97.7431&radius=1000",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "voters" in data
        assert isinstance(data["voters"], list)

    def test_find_voters_in_bounding_box(self, client, auth_headers_canvasser):
        """Test finding voters within bounding box."""
        response = client.get(
            "/voters/in-bounds?"
            "min_lat=30.25&max_lat=30.30&min_lng=-97.75&max_lng=-97.70",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK

    def test_calculate_distance_to_voter(
        self, client, auth_headers_canvasser, sample_voters
    ):
        """Test calculating distance from point to voter."""
        voter = sample_voters[0]
        response = client.get(
            f"/voters/{voter.id}/distance?"
            f"latitude=30.2672&longitude=-97.7431",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "distance_meters" in data
        assert isinstance(data["distance_meters"], (int, float))

    def test_route_optimization(
        self, client, auth_headers_manager, sample_voters
    ):
        """Test getting optimized route through voters."""
        voter_ids = [v["id"] for v in sample_voters[:5]]
        
        response = client.post(
            "/voters/optimize-route",
            headers=auth_headers_manager,
            json={
                "voter_ids": voter_ids,
                "start_location": {"latitude": 30.2672, "longitude": -97.7431},
            },
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "optimized_order" in data
        assert len(data["optimized_order"]) == len(voter_ids)


# =============================================================================
# Voter Contact History Tests
# =============================================================================

@pytest.mark.api
class TestVoterContactHistory:
    """Test voter contact history functionality."""

    def test_get_voter_contact_history(
        self, client, auth_headers_canvasser, sample_voters, sample_contact_log
    ):
        """Test getting contact history for voter."""
        voter = sample_voters[0]
        response = client.get(
            f"/voters/{voter.id}/contacts",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "contacts" in data
        assert isinstance(data["contacts"], list)

    def test_contact_history_ordered_by_date(
        self, client, auth_headers_canvasser, sample_voters
    ):
        """Test that contact history is ordered by date descending."""
        voter = sample_voters[0]
        response = client.get(
            f"/voters/{voter.id}/contacts",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        contacts = data["contacts"]
        
        # Verify descending order (most recent first)
        for i in range(len(contacts) - 1):
            assert contacts[i]["contacted_at"] >= contacts[i + 1]["contacted_at"]

    def test_voter_last_contact_info(
        self, client, auth_headers_canvasser, sample_voters
    ):
        """Test that voter includes last contact info."""
        voter = sample_voters[0]
        response = client.get(
            f"/voters/{voter.id}",
            headers=auth_headers_canvasser,
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        if data.get("last_contact"):
            assert "date" in data["last_contact"]
            assert "type" in data["last_contact"]
            assert "result" in data["last_contact"]


# =============================================================================
# Voter Validation Tests
# =============================================================================

@pytest.mark.unit
class TestVoterValidation:
    """Test voter data validation."""

    def test_required_fields(self, client, auth_headers_manager):
        """Test that required fields are enforced."""
        invalid_voters = [
            {},  # All fields missing
            {"voter_id": "TX123"},  # Missing name and address
            {"first_name": "John", "last_name": "Doe"},  # Missing voter_id
        ]
        
        for invalid_voter in invalid_voters:
            response = client.post(
                "/voters",
                headers=auth_headers_manager,
                json=invalid_voter,
            )
            assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_support_level_range(self, client, auth_headers_manager):
        """Test support level validation (1-5)."""
        invalid_levels = [0, 6, -1, 10]
        
        for level in invalid_levels:
            voter = {
                "voter_id": f"TX{level}",
                "first_name": "Test",
                "last_name": "Voter",
                "address": "123 St",
                "city": "Austin",
                "state": "TX",
                "zip": "78701",
                "support_level": level,
            }
            response = client.post(
                "/voters",
                headers=auth_headers_manager,
                json=voter,
            )
            assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_location_coordinates_valid(self, client, auth_headers_manager):
        """Test location coordinate validation."""
        invalid_locations = [
            {"latitude": 91, "longitude": 0},  # Invalid latitude
            {"latitude": 0, "longitude": 181},  # Invalid longitude
            {"latitude": -91, "longitude": 0},  # Invalid latitude
        ]
        
        for location in invalid_locations:
            voter = {
                "voter_id": "TX999",
                "first_name": "Test",
                "last_name": "Voter",
                "address": "123 St",
                "city": "Austin",
                "state": "TX",
                "zip": "78701",
                "location": location,
            }
            response = client.post(
                "/voters",
                headers=auth_headers_manager,
                json=voter,
            )
            assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


# =============================================================================
# Integration Tests
# =============================================================================

@pytest.mark.integration
class TestVoterIntegration:
    """Integration tests for voter operations."""

    def test_voter_lifecycle(self, client, auth_headers_manager, auth_headers_admin):
        """Test complete voter lifecycle: create, read, update, delete."""
        # 1. Create voter
        new_voter = {
            "voter_id": "TX00000001",
            "first_name": "Lifecycle",
            "last_name": "Test",
            "address": "100 Test St",
            "city": "Austin",
            "state": "TX",
            "zip": "78701",
            "location": {"latitude": 30.2672, "longitude": -97.7431},
        }
        
        create_response = client.post(
            "/voters",
            headers=auth_headers_manager,
            json=new_voter,
        )
        assert create_response.status_code == status.HTTP_201_CREATED
        voter_id = create_response.json()["id"]
        
        # 2. Read voter
        read_response = client.get(
            f"/voters/{voter_id}",
            headers=auth_headers_manager,
        )
        assert read_response.status_code == status.HTTP_200_OK
        
        # 3. Update voter
        update_response = client.patch(
            f"/voters/{voter_id}",
            headers=auth_headers_manager,
            json={"support_level": 5},
        )
        assert update_response.status_code == status.HTTP_200_OK
        
        # 4. Delete voter
        delete_response = client.delete(
            f"/voters/{voter_id}",
            headers=auth_headers_admin,
        )
        assert delete_response.status_code == status.HTTP_204_NO_CONTENT
        
        # 5. Verify deletion
        final_response = client.get(
            f"/voters/{voter_id}",
            headers=auth_headers_manager,
        )
        assert final_response.status_code == status.HTTP_404_NOT_FOUND
