"""
VEP MVP Backend - Contact Log Routes

Endpoints for logging voter contacts.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID

from fastapi import APIRouter, HTTPException, Query, status
from sqlmodel import select, text

from app.dependencies import CurrentUser, DatabaseSession
from app.models.assignment import Assignment
from app.models.contact_log import ContactLog, ContactLogCreate, ContactLogRead, ContactLogUpdate

router = APIRouter()


def coordinate_to_point(latitude: float, longitude: float) -> str:
    """Convert coordinate to PostGIS POINT string."""
    return f"SRID=4326;POINT({longitude} {latitude})"


def point_to_coordinate(point_str: str) -> dict:
    """Convert PostGIS POINT string to coordinate dict."""
    if not point_str or point_str == "None":
        return None
    try:
        coords = point_str.replace("POINT(", "").replace(")", "").split()
        return {"latitude": float(coords[1]), "longitude": float(coords[0])}
    except:
        return None


@router.post("/", response_model=ContactLogRead, status_code=status.HTTP_201_CREATED)
async def create_contact_log(
    log_data: ContactLogCreate,
    db: DatabaseSession,
    current_user: CurrentUser,
):
    """
    Create a new contact log.
    
    Users can only log contacts for their own assignments.
    
    Args:
        log_data: Contact log data
        db: Database session
        current_user: Authenticated user
        
    Returns:
        ContactLogRead: Created contact log
        
    Raises:
        HTTPException: If assignment not found or unauthorized
    """
    # Verify assignment belongs to user
    statement = select(Assignment).where(Assignment.id == log_data.assignment_id)
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
            detail="You can only log contacts for your own assignments",
        )
    
    # Create contact log
    db_log = ContactLog(
        assignment_id=log_data.assignment_id,
        voter_id=log_data.voter_id,
        user_id=current_user.id,
        contact_type=log_data.contact_type,
        result=log_data.result,
        support_level=log_data.support_level,
    )
    
    db.add(db_log)
    db.commit()
    
    # Update location if provided
    if log_data.location:
        point = coordinate_to_point(
            log_data.location.latitude,
            log_data.location.longitude,
        )
        update_location_query = text(
            "UPDATE contact_logs SET location = ST_GeomFromEWKT(:point) WHERE id = :log_id"
        )
        db.exec(update_location_query, {"point": point, "log_id": db_log.id})
        db.commit()
    
    db.refresh(db_log)
    
    # Prepare response
    log_dict = db_log.model_dump()
    
    # Get location
    if log_data.location:
        location_query = text(
            "SELECT ST_AsText(location) FROM contact_logs WHERE id = :log_id"
        )
        location_result = db.exec(location_query, {"log_id": db_log.id}).first()
        if location_result and location_result[0]:
            log_dict["location"] = point_to_coordinate(location_result[0])
        else:
            log_dict["location"] = None
    else:
        log_dict["location"] = None
    
    return ContactLogRead(**log_dict)


@router.get("/", response_model=list[dict])
async def list_contact_logs(
    db: DatabaseSession,
    current_user: CurrentUser,
    assignment_id: Optional[UUID] = Query(None, description="Filter by assignment ID"),
    start_date: Optional[datetime] = Query(None, description="Filter by start date"),
    limit: int = Query(50, ge=1, le=100, description="Maximum number of results"),
    offset: int = Query(0, ge=0, description="Number of results to skip"),
):
    """
    List contact logs with filters.
    
    Users can see their own logs, managers can see all logs.
    
    Args:
        db: Database session
        current_user: Authenticated user
        assignment_id: Optional assignment filter
        start_date: Optional start date filter
        limit: Maximum number of results
        offset: Number of results to skip
        
    Returns:
        list[dict]: List of contact logs with voter details
    """
    # Build query
    query_parts = ["SELECT cl.*, v.first_name, v.last_name FROM contact_logs cl"]
    query_parts.append("JOIN voters v ON cl.voter_id = v.id")
    
    where_clauses = []
    params = {"limit": limit, "offset": offset}
    
    # Filter by user role
    if current_user.role not in ["manager", "admin"]:
        where_clauses.append("cl.user_id = :user_id")
        params["user_id"] = current_user.id
    
    if assignment_id:
        where_clauses.append("cl.assignment_id = :assignment_id")
        params["assignment_id"] = assignment_id
    
    if start_date:
        where_clauses.append("cl.contacted_at >= :start_date")
        params["start_date"] = start_date
    
    if where_clauses:
        query_parts.append("WHERE " + " AND ".join(where_clauses))
    
    query_parts.append("ORDER BY cl.contacted_at DESC")
    query_parts.append("LIMIT :limit OFFSET :offset")
    
    query = text(" ".join(query_parts))
    results = db.exec(query, params).all()
    
    logs = []
    for row in results:
        log_data = {
            "id": row[0],
            "assignment_id": row[1],
            "voter_id": row[2],
            "user_id": row[3],
            "contact_type": row[4],
            "result": row[5],
            "support_level": row[6],
            "contacted_at": row[8].isoformat() if row[8] else None,
            "created_at": row[9].isoformat() if row[9] else None,
            "voter_name": f"{row[10]} {row[11]}",
        }
        logs.append(log_data)
    
    return logs


@router.put("/{log_id}", response_model=ContactLogRead)
async def update_contact_log(
    log_id: UUID,
    log_data: ContactLogUpdate,
    db: DatabaseSession,
    current_user: CurrentUser,
):
    """
    Update a contact log.
    
    Users can update their own logs, managers can update any log.
    
    Args:
        log_id: Contact log ID
        log_data: Contact log update data
        db: Database session
        current_user: Authenticated user
        
    Returns:
        ContactLogRead: Updated contact log
        
    Raises:
        HTTPException: If log not found or unauthorized
    """
    statement = select(ContactLog).where(ContactLog.id == log_id)
    log = db.exec(statement).first()
    
    if not log:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Contact log not found",
        )
    
    # Check authorization
    if current_user.role not in ["manager", "admin"] and log.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to update this contact log",
        )
    
    # Update fields
    update_data = log_data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(log, key, value)
    
    db.add(log)
    db.commit()
    db.refresh(log)
    
    # Prepare response
    log_dict = log.model_dump()
    
    # Get location
    location_query = text(
        "SELECT ST_AsText(location) FROM contact_logs WHERE id = :log_id"
    )
    location_result = db.exec(location_query, {"log_id": log.id}).first()
    if location_result and location_result[0]:
        log_dict["location"] = point_to_coordinate(location_result[0])
    else:
        log_dict["location"] = None
    
    return ContactLogRead(**log_dict)


@router.delete("/{log_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_contact_log(
    log_id: UUID,
    db: DatabaseSession,
    current_user: CurrentUser,
):
    """
    Delete a contact log.
    
    Users can delete their own logs, managers can delete any log.
    
    Args:
        log_id: Contact log ID
        db: Database session
        current_user: Authenticated user
        
    Raises:
        HTTPException: If log not found or unauthorized
    """
    statement = select(ContactLog).where(ContactLog.id == log_id)
    log = db.exec(statement).first()
    
    if not log:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Contact log not found",
        )
    
    # Check authorization
    if current_user.role not in ["manager", "admin"] and log.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to delete this contact log",
        )
    
    db.delete(log)
    db.commit()
    
    return None
