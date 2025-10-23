"""
VEP MVP Backend - Assignment Routes

Endpoints for assignment management.
"""

from uuid import UUID

from fastapi import APIRouter, HTTPException, status
from sqlmodel import func, select, text

from app.dependencies import CurrentUser, DatabaseSession, ManagerUser
from app.models.assignment import (
    Assignment,
    AssignmentCreate,
    AssignmentRead,
    AssignmentUpdate,
    AssignmentVoter,
    AssignmentWithVoters,
)
from app.models.voter import Voter

router = APIRouter()


def point_to_coordinate(point_str: str) -> dict:
    """Convert PostGIS POINT string to coordinate dict."""
    if not point_str or point_str == "None":
        return None
    try:
        coords = point_str.replace("POINT(", "").replace(")", "").split()
        return {"latitude": float(coords[1]), "longitude": float(coords[0])}
    except:
        return None


@router.get("/", response_model=list[AssignmentRead])
async def list_assignments(db: DatabaseSession, current_user: CurrentUser):
    """
    List assignments for the current user.
    
    Managers/admins can see all assignments, canvassers see only their own.
    
    Args:
        db: Database session
        current_user: Authenticated user
        
    Returns:
        list[AssignmentRead]: List of assignments
    """
    statement = select(Assignment)
    
    # Filter by user role
    if current_user.role not in ["manager", "admin"]:
        statement = statement.where(Assignment.user_id == current_user.id)
    
    assignments = db.exec(statement).all()
    
    # Enhance with voter counts
    result = []
    for assignment in assignments:
        assignment_dict = assignment.model_dump()
        
        # Get voter count
        voter_count_query = select(func.count(AssignmentVoter.id)).where(
            AssignmentVoter.assignment_id == assignment.id
        )
        voter_count = db.exec(voter_count_query).first()
        assignment_dict["voter_count"] = voter_count or 0
        
        # Get completed count (voters with contact logs)
        completed_count_query = text("""
            SELECT COUNT(DISTINCT cl.voter_id)
            FROM contact_logs cl
            WHERE cl.assignment_id = :assignment_id
        """)
        completed_count = db.exec(
            completed_count_query, {"assignment_id": assignment.id}
        ).first()
        assignment_dict["completed_count"] = completed_count[0] if completed_count else 0
        
        result.append(AssignmentRead(**assignment_dict))
    
    return result


@router.get("/{assignment_id}", response_model=AssignmentWithVoters)
async def get_assignment(assignment_id: UUID, db: DatabaseSession, current_user: CurrentUser):
    """
    Get a specific assignment with voter details.
    
    Args:
        assignment_id: Assignment ID
        db: Database session
        current_user: Authenticated user
        
    Returns:
        AssignmentWithVoters: Assignment with voter list
        
    Raises:
        HTTPException: If assignment not found or unauthorized
    """
    statement = select(Assignment).where(Assignment.id == assignment_id)
    assignment = db.exec(statement).first()
    
    if not assignment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Assignment not found",
        )
    
    # Check authorization
    if (
        current_user.role not in ["manager", "admin"]
        and assignment.user_id != current_user.id
    ):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view this assignment",
        )
    
    assignment_dict = assignment.model_dump()
    
    # Get voter count
    voter_count_query = select(func.count(AssignmentVoter.id)).where(
        AssignmentVoter.assignment_id == assignment.id
    )
    voter_count = db.exec(voter_count_query).first()
    assignment_dict["voter_count"] = voter_count or 0
    
    # Get completed count
    completed_count_query = text("""
        SELECT COUNT(DISTINCT cl.voter_id)
        FROM contact_logs cl
        WHERE cl.assignment_id = :assignment_id
    """)
    completed_count = db.exec(
        completed_count_query, {"assignment_id": assignment.id}
    ).first()
    assignment_dict["completed_count"] = completed_count[0] if completed_count else 0
    
    # Get voters with details
    voters_query = text("""
        SELECT 
            v.id, v.voter_id, v.first_name, v.last_name, v.address, 
            v.city, v.zip, v.party_affiliation, v.support_level,
            av.sequence_order,
            ST_AsText(v.location) as location_text,
            (
                SELECT json_build_object(
                    'date', cl.contacted_at,
                    'type', cl.contact_type,
                    'result', cl.result
                )
                FROM contact_logs cl
                WHERE cl.voter_id = v.id
                  AND cl.assignment_id = :assignment_id
                ORDER BY cl.contacted_at DESC
                LIMIT 1
            ) as last_contact
        FROM voters v
        JOIN assignment_voters av ON v.id = av.voter_id
        WHERE av.assignment_id = :assignment_id
        ORDER BY av.sequence_order NULLS LAST, v.last_name, v.first_name
    """)
    
    voters_results = db.exec(voters_query.bindparams(assignment_id=str(assignment.id))).all()
    
    voters = []
    for row in voters_results:
        voter_data = {
            "id": row[0],
            "voter_id": row[1],
            "first_name": row[2],
            "last_name": row[3],
            "address": row[4],
            "city": row[5],
            "zip": row[6],
            "party_affiliation": row[7],
            "support_level": row[8],
            "sequence_order": row[9],
            "location": point_to_coordinate(row[10]) if row[10] else None,
            "last_contact": row[11] if row[11] else None,
        }
        voters.append(voter_data)
    
    assignment_dict["voters"] = voters
    
    return AssignmentWithVoters(**assignment_dict)


@router.post("/", response_model=AssignmentRead, status_code=status.HTTP_201_CREATED)
async def create_assignment(
    assignment_data: AssignmentCreate,
    db: DatabaseSession,
    current_user: ManagerUser,
):
    """
    Create a new assignment (managers and admins only).
    
    Args:
        assignment_data: Assignment data
        db: Database session
        current_user: Authenticated manager/admin user
        
    Returns:
        AssignmentRead: Created assignment
    """
    # Create assignment
    db_assignment = Assignment(
        user_id=assignment_data.user_id,
        name=assignment_data.name,
        description=assignment_data.description,
        assigned_date=assignment_data.assigned_date,
        due_date=assignment_data.due_date,
        status=assignment_data.status,
    )
    
    db.add(db_assignment)
    db.commit()
    db.refresh(db_assignment)
    
    # Add voters to assignment
    for idx, voter_id in enumerate(assignment_data.voter_ids):
        assignment_voter = AssignmentVoter(
            assignment_id=db_assignment.id,
            voter_id=voter_id,
            sequence_order=idx + 1,
        )
        db.add(assignment_voter)
    
    db.commit()
    
    # Prepare response
    assignment_dict = db_assignment.model_dump()
    assignment_dict["voter_count"] = len(assignment_data.voter_ids)
    assignment_dict["completed_count"] = 0
    
    return AssignmentRead(**assignment_dict)


@router.patch("/{assignment_id}", response_model=AssignmentRead)
async def update_assignment(
    assignment_id: UUID,
    assignment_data: AssignmentUpdate,
    db: DatabaseSession,
    current_user: CurrentUser,
):
    """
    Update an assignment.
    
    Canvassers can update their own assignments (e.g., status).
    Managers can update any assignment.
    
    Args:
        assignment_id: Assignment ID
        assignment_data: Assignment update data
        db: Database session
        current_user: Authenticated user
        
    Returns:
        AssignmentRead: Updated assignment
        
    Raises:
        HTTPException: If assignment not found or unauthorized
    """
    statement = select(Assignment).where(Assignment.id == assignment_id)
    assignment = db.exec(statement).first()
    
    if not assignment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Assignment not found",
        )
    
    # Check authorization
    if (
        current_user.role not in ["manager", "admin"]
        and assignment.user_id != current_user.id
    ):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to update this assignment",
        )
    
    # Update fields
    update_data = assignment_data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(assignment, key, value)
    
    db.add(assignment)
    db.commit()
    db.refresh(assignment)
    
    # Prepare response
    assignment_dict = assignment.model_dump()
    
    voter_count_query = select(func.count(AssignmentVoter.id)).where(
        AssignmentVoter.assignment_id == assignment.id
    )
    voter_count = db.exec(voter_count_query).first()
    assignment_dict["voter_count"] = voter_count or 0
    
    completed_count_query = text("""
        SELECT COUNT(DISTINCT cl.voter_id)
        FROM contact_logs cl
        WHERE cl.assignment_id = :assignment_id
    """)
    completed_count = db.exec(
        completed_count_query, {"assignment_id": assignment.id}
    ).first()
    assignment_dict["completed_count"] = completed_count[0] if completed_count else 0
    
    return AssignmentRead(**assignment_dict)


@router.delete("/{assignment_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_assignment(
    assignment_id: UUID,
    db: DatabaseSession,
    current_user: ManagerUser,
):
    """
    Delete an assignment (managers and admins only).
    
    Args:
        assignment_id: Assignment ID
        db: Database session
        current_user: Authenticated manager/admin user
        
    Raises:
        HTTPException: If assignment not found
    """
    statement = select(Assignment).where(Assignment.id == assignment_id)
    assignment = db.exec(statement).first()
    
    if not assignment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Assignment not found",
        )
    
    db.delete(assignment)
    db.commit()
    
    return None


@router.get("/{assignment_id}/voters", response_model=list[dict])
async def get_assignment_voters(
    assignment_id: UUID,
    db: DatabaseSession,
    current_user: CurrentUser,
):
    """
    Get voters for a specific assignment.
    
    Args:
        assignment_id: Assignment ID
        db: Database session
        current_user: Authenticated user
        
    Returns:
        list[dict]: List of voters
        
    Raises:
        HTTPException: If assignment not found or unauthorized
    """
    statement = select(Assignment).where(Assignment.id == assignment_id)
    assignment = db.exec(statement).first()
    
    if not assignment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Assignment not found",
        )
    
    # Check authorization
    if (
        current_user.role not in ["manager", "admin"]
        and assignment.user_id != current_user.id
    ):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view this assignment",
        )
    
    # Get voters
    voters_query = text("""
        SELECT 
            v.id, v.voter_id, v.first_name, v.last_name, v.address, 
            v.city, v.zip, v.party_affiliation, v.support_level,
            av.sequence_order,
            ST_AsText(v.location) as location_text
        FROM voters v
        JOIN assignment_voters av ON v.id = av.voter_id
        WHERE av.assignment_id = :assignment_id
        ORDER BY av.sequence_order NULLS LAST, v.last_name, v.first_name
    """)
    
    results = db.exec(voters_query.bindparams(assignment_id=str(assignment.id))).all()
    
    voters = []
    for row in results:
        voter_data = {
            "id": str(row[0]),
            "voter_id": row[1],
            "first_name": row[2],
            "last_name": row[3],
            "address": row[4],
            "city": row[5],
            "zip": row[6],
            "party_affiliation": row[7],
            "support_level": row[8],
            "sequence_order": row[9],
            "location": point_to_coordinate(row[10]) if row[10] else None,
        }
        voters.append(voter_data)
    
    return voters
