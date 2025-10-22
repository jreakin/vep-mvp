"""
VEP MVP Backend - Integration Tests

End-to-end integration tests covering complete workflows
across multiple endpoints and services.
"""

import pytest
from fastapi import status
from uuid import uuid4
from datetime import datetime, timedelta


# =============================================================================
# Complete Workflow Tests
# =============================================================================

@pytest.mark.integration
class TestCompleteWorkflows:
    """Test complete user workflows from start to finish."""

    def test_canvasser_daily_workflow(
        self,
        client,
        auth_headers_manager,
        auth_headers_canvasser,
        canvasser_user,
        sample_voters,
    ):
        """
        Test complete canvasser daily workflow:
        1. Manager creates assignment
        2. Canvasser views assignment
        3. Canvasser starts walking
        4. Canvasser logs contacts
        5. Canvasser completes assignment
        """
        pytest.skip("Backend implementation pending from Agent 2")
        
        # 1. Manager creates assignment for canvasser
        assignment_data = {
            "name": "Morning Walk - Oct 22",
            "description": "Residential neighborhood",
            "user_id": canvasser_user["id"],
            "voter_ids": [v["id"] for v in sample_voters[:5]],
            "due_date": (datetime.now() + timedelta(days=1)).date().isoformat(),
        }
        
        create_response = client.post(
            "/assignments",
            headers=auth_headers_manager,
            json=assignment_data,
        )
        assert create_response.status_code == status.HTTP_201_CREATED
        assignment_id = create_response.json()["id"]
        
        # 2. Canvasser views assignment
        view_response = client.get(
            f"/assignments/{assignment_id}",
            headers=auth_headers_canvasser,
        )
        assert view_response.status_code == status.HTTP_200_OK
        assignment = view_response.json()
        assert len(assignment["voters"]) == 5
        
        # 3. Canvasser starts assignment
        start_response = client.patch(
            f"/assignments/{assignment_id}",
            headers=auth_headers_canvasser,
            json={"status": "in_progress"},
        )
        assert start_response.status_code == status.HTTP_200_OK
        
        # 4. Canvasser logs contacts for each voter
        for i, voter in enumerate(assignment["voters"]):
            contact_response = client.post(
                "/contact-logs",
                headers=auth_headers_canvasser,
                json={
                    "assignment_id": assignment_id,
                    "voter_id": voter["id"],
                    "contact_type": ["knocked", "not_home", "knocked", "knocked", "refused"][i],
                    "result": f"Contact {i + 1}",
                    "support_level": (i % 5) + 1 if i != 4 else None,
                    "location": {
                        "latitude": 30.2672 + (i * 0.001),
                        "longitude": -97.7431 + (i * 0.001),
                    },
                },
            )
            assert contact_response.status_code == status.HTTP_201_CREATED
        
        # 5. Check progress
        progress_response = client.get(
            f"/assignments/{assignment_id}/progress",
            headers=auth_headers_canvasser,
        )
        assert progress_response.status_code == status.HTTP_200_OK
        progress = progress_response.json()
        assert progress["contacted"] == 5
        assert progress["completion_percentage"] == 100
        
        # 6. Complete assignment
        complete_response = client.patch(
            f"/assignments/{assignment_id}",
            headers=auth_headers_canvasser,
            json={"status": "completed"},
        )
        assert complete_response.status_code == status.HTTP_200_OK

    def test_manager_campaign_overview_workflow(
        self,
        client,
        auth_headers_manager,
        auth_headers_admin,
    ):
        """
        Test manager campaign overview workflow:
        1. View all assignments
        2. Create new assignments
        3. Monitor progress
        4. View analytics
        """
        pytest.skip("Backend implementation pending from Agent 2")
        
        # 1. Manager views all assignments
        assignments_response = client.get(
            "/assignments",
            headers=auth_headers_manager,
        )
        assert assignments_response.status_code == status.HTTP_200_OK
        
        # 2. Filter by status
        pending_response = client.get(
            "/assignments?status=pending",
            headers=auth_headers_manager,
        )
        assert pending_response.status_code == status.HTTP_200_OK
        
        # 3. View overall progress
        analytics_response = client.get(
            "/analytics/progress",
            headers=auth_headers_manager,
        )
        assert analytics_response.status_code == status.HTTP_200_OK
        analytics = analytics_response.json()
        assert "total_voters" in analytics
        assert "contacted" in analytics
        assert "support_distribution" in analytics
        
        # 4. View contact type breakdown
        assert "contact_types" in analytics
        assert isinstance(analytics["contact_types"], dict)


# =============================================================================
# Cross-Entity Tests
# =============================================================================

@pytest.mark.integration
class TestCrossEntityRelationships:
    """Test relationships and dependencies between different entities."""

    def test_user_deletion_cascades_to_assignments(
        self,
        client,
        auth_headers_admin,
        db_session,
    ):
        """Test that deleting user cascades to their assignments."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        from tests.conftest import create_test_user, create_test_voter
        
        # Create test user
        user = create_test_user(db_session, role="canvasser")
        
        # Create voters
        voters = [create_test_voter(db_session) for _ in range(3)]
        
        # Create assignment for user
        assignment_response = client.post(
            "/assignments",
            headers=auth_headers_admin,
            json={
                "name": "Test Assignment",
                "user_id": user["id"],
                "voter_ids": [v["id"] for v in voters],
            },
        )
        assignment_id = assignment_response.json()["id"]
        
        # Delete user
        client.delete(f"/users/{user['id']}", headers=auth_headers_admin)
        
        # Verify assignment is also deleted
        get_assignment = client.get(
            f"/assignments/{assignment_id}",
            headers=auth_headers_admin,
        )
        assert get_assignment.status_code == status.HTTP_404_NOT_FOUND

    def test_voter_contact_history_across_assignments(
        self,
        client,
        auth_headers_manager,
        auth_headers_canvasser,
        canvasser_user,
        sample_voters,
    ):
        """Test that voter contact history shows across multiple assignments."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        voter = sample_voters[0]
        
        # Create two assignments with same voter
        assignment1 = client.post(
            "/assignments",
            headers=auth_headers_manager,
            json={
                "name": "Assignment 1",
                "user_id": canvasser_user["id"],
                "voter_ids": [voter["id"]],
            },
        ).json()
        
        assignment2 = client.post(
            "/assignments",
            headers=auth_headers_manager,
            json={
                "name": "Assignment 2",
                "user_id": canvasser_user["id"],
                "voter_ids": [voter["id"]],
            },
        ).json()
        
        # Log contacts from both assignments
        client.post(
            "/contact-logs",
            headers=auth_headers_canvasser,
            json={
                "assignment_id": assignment1["id"],
                "voter_id": voter["id"],
                "contact_type": "knocked",
                "result": "First contact",
            },
        )
        
        client.post(
            "/contact-logs",
            headers=auth_headers_canvasser,
            json={
                "assignment_id": assignment2["id"],
                "voter_id": voter["id"],
                "contact_type": "phone",
                "result": "Second contact",
            },
        )
        
        # Get voter contact history
        history_response = client.get(
            f"/voters/{voter['id']}/contacts",
            headers=auth_headers_canvasser,
        )
        
        assert history_response.status_code == status.HTTP_200_OK
        contacts = history_response.json()["contacts"]
        assert len(contacts) >= 2


# =============================================================================
# Analytics Integration Tests
# =============================================================================

@pytest.mark.integration
class TestAnalyticsIntegration:
    """Test analytics endpoints with real data."""

    def test_campaign_progress_analytics(
        self,
        client,
        auth_headers_manager,
        auth_headers_canvasser,
        canvasser_user,
        sample_voters,
    ):
        """Test campaign progress analytics with real contact data."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # Create assignment
        assignment = client.post(
            "/assignments",
            headers=auth_headers_manager,
            json={
                "name": "Analytics Test",
                "user_id": canvasser_user["id"],
                "voter_ids": [v["id"] for v in sample_voters[:10]],
            },
        ).json()
        
        # Log various contacts with different support levels
        support_levels = [5, 5, 4, 4, 3, 3, 2, 1, None, None]
        contact_types = [
            "knocked",
            "knocked",
            "knocked",
            "phone",
            "knocked",
            "not_home",
            "knocked",
            "refused",
            "knocked",
            "not_home",
        ]
        
        for i, voter in enumerate(sample_voters[:10]):
            client.post(
                "/contact-logs",
                headers=auth_headers_canvasser,
                json={
                    "assignment_id": assignment["id"],
                    "voter_id": voter["id"],
                    "contact_type": contact_types[i],
                    "result": f"Contact {i}",
                    "support_level": support_levels[i],
                },
            )
        
        # Get analytics
        analytics_response = client.get(
            "/analytics/progress",
            headers=auth_headers_manager,
        )
        
        assert analytics_response.status_code == status.HTTP_200_OK
        analytics = analytics_response.json()
        
        # Verify support distribution
        support_dist = analytics["support_distribution"]
        assert support_dist["5"] >= 2
        assert support_dist["4"] >= 2
        assert support_dist["3"] >= 2
        
        # Verify contact types
        contact_types_dist = analytics["contact_types"]
        assert contact_types_dist["knocked"] >= 6
        assert contact_types_dist["not_home"] >= 2

    def test_user_performance_analytics(
        self,
        client,
        auth_headers_manager,
        auth_headers_canvasser,
        canvasser_user,
    ):
        """Test user performance analytics."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # Get user stats
        stats_response = client.get(
            f"/users/{canvasser_user['id']}/stats",
            headers=auth_headers_manager,
        )
        
        assert stats_response.status_code == status.HTTP_200_OK
        stats = stats_response.json()
        assert "total_contacts" in stats
        assert "assignments_completed" in stats
        assert "average_contacts_per_day" in stats


# =============================================================================
# Error Handling Integration Tests
# =============================================================================

@pytest.mark.integration
class TestErrorHandling:
    """Test error handling across the application."""

    def test_concurrent_assignment_updates(
        self,
        client,
        auth_headers_canvasser,
        sample_assignment,
    ):
        """Test handling of concurrent updates to same assignment."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # Simulate two concurrent updates
        response1 = client.patch(
            f"/assignments/{sample_assignment['id']}",
            headers=auth_headers_canvasser,
            json={"status": "in_progress"},
        )
        
        response2 = client.patch(
            f"/assignments/{sample_assignment['id']}",
            headers=auth_headers_canvasser,
            json={"status": "completed"},
        )
        
        # Both should succeed or one should handle conflict
        assert response1.status_code in [status.HTTP_200_OK, status.HTTP_409_CONFLICT]
        assert response2.status_code in [status.HTTP_200_OK, status.HTTP_409_CONFLICT]

    def test_database_transaction_rollback(
        self,
        client,
        auth_headers_manager,
        canvasser_user,
        sample_voters,
    ):
        """Test that failed operations rollback properly."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # Try to create assignment with invalid data that will fail mid-transaction
        response = client.post(
            "/assignments",
            headers=auth_headers_manager,
            json={
                "name": "Test Assignment",
                "user_id": canvasser_user["id"],
                "voter_ids": [
                    sample_voters[0]["id"],
                    str(uuid4()),  # Invalid voter ID should cause rollback
                ],
            },
        )
        
        assert response.status_code == status.HTTP_404_NOT_FOUND
        
        # Verify no partial data was created
        # (assignment should not exist)
        assignments = client.get(
            "/assignments?search=Test Assignment",
            headers=auth_headers_manager,
        )
        assert len(assignments.json()["assignments"]) == 0


# =============================================================================
# Performance Tests
# =============================================================================

@pytest.mark.integration
@pytest.mark.slow
class TestPerformance:
    """Test performance with larger datasets."""

    def test_large_assignment_performance(
        self,
        client,
        auth_headers_manager,
        auth_headers_canvasser,
        canvasser_user,
        db_session,
    ):
        """Test performance with large assignment (100+ voters)."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        from tests.conftest import create_test_voter
        
        # Create 100 voters
        voters = [create_test_voter(db_session) for _ in range(100)]
        
        # Create large assignment
        import time
        start_time = time.time()
        
        response = client.post(
            "/assignments",
            headers=auth_headers_manager,
            json={
                "name": "Large Assignment",
                "user_id": canvasser_user["id"],
                "voter_ids": [v["id"] for v in voters],
            },
        )
        
        create_time = time.time() - start_time
        assert response.status_code == status.HTTP_201_CREATED
        assert create_time < 5.0  # Should complete in under 5 seconds
        
        # Test retrieving large assignment
        assignment_id = response.json()["id"]
        start_time = time.time()
        
        get_response = client.get(
            f"/assignments/{assignment_id}",
            headers=auth_headers_canvasser,
        )
        
        get_time = time.time() - start_time
        assert get_response.status_code == status.HTTP_200_OK
        assert len(get_response.json()["voters"]) == 100
        assert get_time < 2.0  # Should complete in under 2 seconds

    def test_bulk_contact_logging_performance(
        self,
        client,
        auth_headers_canvasser,
        sample_assignment,
        sample_voters,
    ):
        """Test performance of batch contact logging."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # Create 50 contact logs
        contact_logs = [
            {
                "assignment_id": sample_assignment["id"],
                "voter_id": sample_voters[i % len(sample_voters)]["id"],
                "contact_type": "knocked",
                "result": f"Contact {i}",
                "contacted_at": (
                    datetime.now() - timedelta(minutes=i)
                ).isoformat(),
            }
            for i in range(50)
        ]
        
        import time
        start_time = time.time()
        
        response = client.post(
            "/contact-logs/batch",
            headers=auth_headers_canvasser,
            json={"logs": contact_logs},
        )
        
        batch_time = time.time() - start_time
        assert response.status_code == status.HTTP_201_CREATED
        assert batch_time < 3.0  # Should complete in under 3 seconds


# =============================================================================
# Security Integration Tests
# =============================================================================

@pytest.mark.integration
class TestSecurityIntegration:
    """Test security features across the application."""

    def test_role_based_data_isolation(
        self,
        client,
        auth_headers_canvasser,
        auth_headers_manager,
        canvasser_user,
        manager_user,
    ):
        """Test that users can only access their own data appropriately."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # Canvasser should only see their assignments
        canvasser_assignments = client.get(
            "/assignments",
            headers=auth_headers_canvasser,
        )
        for assignment in canvasser_assignments.json()["assignments"]:
            assert assignment["user_id"] == canvasser_user["id"]
        
        # Manager should see all assignments
        manager_assignments = client.get(
            "/assignments",
            headers=auth_headers_manager,
        )
        # Manager view should include more assignments
        assert len(manager_assignments.json()["assignments"]) >= len(
            canvasser_assignments.json()["assignments"]
        )

    def test_sql_injection_prevention(self, client, auth_headers_canvasser):
        """Test that SQL injection attempts are prevented."""
        pytest.skip("Backend implementation pending from Agent 2")
        
        # Try SQL injection in search parameter
        malicious_search = "'; DROP TABLE voters; --"
        
        response = client.get(
            f"/voters?search={malicious_search}",
            headers=auth_headers_canvasser,
        )
        
        # Should return empty results, not cause error
        assert response.status_code == status.HTTP_200_OK
        
        # Verify voters table still exists (next query should work)
        verify_response = client.get("/voters", headers=auth_headers_canvasser)
        assert verify_response.status_code == status.HTTP_200_OK
