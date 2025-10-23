"""
VEP MVP Backend - Voter Routes

Endpoints for voter data management.
"""

from typing import Optional
from uuid import UUID

from fastapi import APIRouter, HTTPException, Query, status
from sqlmodel import func, select, text

from app.dependencies import CurrentUser, DatabaseSession
from app.models.voter import Voter, VoterCreate, VoterRead, VoterUpdate, VoterWithContactHistory

router = APIRouter()


def coordinate_to_point(latitude: float, longitude: float) -> str:
    """Convert coordinate to PostGIS POINT string."""
    return f"SRID=4326;POINT({longitude} {latitude})"


def point_to_coordinate(point_str: str) -> dict:
    """Convert PostGIS POINT string to coordinate dict."""
    if not point_str or point_str == "None":
        return None
    # Parse "POINT(lng lat)" format
    try:
        coords = point_str.replace("POINT(", "").replace(")", "").split()
        return {"latitude": float(coords[1]), "longitude": float(coords[0])}
    except:
        return None


@router.get("/", response_model=list[VoterRead])
async def list_voters(
    db: DatabaseSession,
    current_user: CurrentUser,
    zip: Optional[str] = Query(None, description="Filter by ZIP code"),
    limit: int = Query(50, ge=1, le=100, description="Maximum number of results"),
    offset: int = Query(0, ge=0, description="Number of results to skip"),
):
    """
    List voters with optional filters.
    
    Args:
        db: Database session
        current_user: Authenticated user
        zip: Optional ZIP code filter
        limit: Maximum number of results
        offset: Number of results to skip
        
    Returns:
        list[VoterRead]: List of voters
    """
    statement = select(Voter)
    
    if zip:
        statement = statement.where(Voter.zip == zip)
    
    statement = statement.limit(limit).offset(offset)
    voters = db.exec(statement).all()
    
    # Convert to response format
    result = []
    for voter in voters:
        voter_dict = voter.model_dump()
        # Get location from database
        location_query = text(
            "SELECT ST_AsText(location) FROM voters WHERE id = :voter_id"
        )
        location_result = db.exec(location_query.bindparams(voter_id=str(voter.id))).first()
        if location_result and location_result[0]:
            voter_dict["location"] = point_to_coordinate(location_result[0])
        else:
            voter_dict["location"] = None
        result.append(VoterRead(**voter_dict))
    
    return result


@router.get("/{voter_id}", response_model=VoterWithContactHistory)
async def get_voter(voter_id: UUID, db: DatabaseSession, current_user: CurrentUser):
    """
    Get a specific voter by ID with contact history.
    
    Args:
        voter_id: Voter ID
        db: Database session
        current_user: Authenticated user
        
    Returns:
        VoterWithContactHistory: Voter information with contact history
        
    Raises:
        HTTPException: If voter not found
    """
    statement = select(Voter).where(Voter.id == voter_id)
    voter = db.exec(statement).first()
    
    if not voter:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Voter not found",
        )
    
    voter_dict = voter.model_dump()
    
    # Get location
    location_query = text(
        "SELECT ST_AsText(location) FROM voters WHERE id = :voter_id"
    )
    location_result = db.exec(location_query.bindparams(voter_id=str(voter.id))).first()
    if location_result and location_result[0]:
        voter_dict["location"] = point_to_coordinate(location_result[0])
    else:
        voter_dict["location"] = None
    
    # Get contact history
    contact_query = text("""
        SELECT cl.contacted_at, cl.contact_type, cl.result, u.full_name as user_name
        FROM contact_logs cl
        JOIN users u ON cl.user_id = u.id
        WHERE cl.voter_id = :voter_id
        ORDER BY cl.contacted_at DESC
        LIMIT 10
    """)
    contact_results = db.exec(contact_query.bindparams(voter_id=str(voter.id))).all()
    
    contact_history = [
        {
            "date": row[0].isoformat() if row[0] else None,
            "type": row[1],
            "result": row[2],
            "user": row[3],
        }
        for row in contact_results
    ]
    
    voter_dict["contact_history"] = contact_history
    
    return VoterWithContactHistory(**voter_dict)


@router.put("/{voter_id}", response_model=VoterRead)
async def update_voter(
    voter_id: UUID,
    voter_data: VoterUpdate,
    db: DatabaseSession,
    current_user: CurrentUser,
):
    """
    Update a voter.
    
    Args:
        voter_id: Voter ID
        voter_data: Voter update data
        db: Database session
        current_user: Authenticated user
        
    Returns:
        VoterRead: Updated voter
        
    Raises:
        HTTPException: If voter not found
    """
    statement = select(Voter).where(Voter.id == voter_id)
    voter = db.exec(statement).first()
    
    if not voter:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Voter not found",
        )
    
    # Update fields
    update_data = voter_data.model_dump(exclude_unset=True, exclude={"location"})
    for key, value in update_data.items():
        setattr(voter, key, value)
    
    db.add(voter)
    
    # Update location if provided
    if voter_data.location:
        point = coordinate_to_point(
            voter_data.location.latitude,
            voter_data.location.longitude,
        )
        update_location_query = text(
            "UPDATE voters SET location = ST_GeomFromEWKT(:point) WHERE id = :voter_id"
        )
        db.exec(update_location_query.bindparams(point=point, voter_id=str(voter.id)))
    
    db.commit()
    db.refresh(voter)
    
    # Get updated location
    voter_dict = voter.model_dump()
    location_query = text(
        "SELECT ST_AsText(location) FROM voters WHERE id = :voter_id"
    )
    location_result = db.exec(location_query.bindparams(voter_id=str(voter.id))).first()
    if location_result and location_result[0]:
        voter_dict["location"] = point_to_coordinate(location_result[0])
    else:
        voter_dict["location"] = None
    
    return VoterRead(**voter_dict)


@router.get("/nearby/", response_model=list[VoterRead])
async def find_nearby_voters(
    db: DatabaseSession,
    current_user: CurrentUser,
    latitude: float = Query(..., description="Latitude"),
    longitude: float = Query(..., description="Longitude"),
    radius_meters: float = Query(1000, description="Search radius in meters"),
    limit: int = Query(50, ge=1, le=100, description="Maximum number of results"),
):
    """
    Find voters near a specific location.
    
    Args:
        db: Database session
        current_user: Authenticated user
        latitude: Search center latitude
        longitude: Search center longitude
        radius_meters: Search radius in meters
        limit: Maximum number of results
        
    Returns:
        list[VoterRead]: List of nearby voters
    """
    # Use PostGIS spatial query
    query = text("""
        SELECT v.*, ST_AsText(v.location) as location_text,
               ST_Distance(v.location::geography, 
                          ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)::geography) as distance
        FROM voters v
        WHERE v.location IS NOT NULL
          AND ST_DWithin(v.location::geography,
                        ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)::geography,
                        :radius)
        ORDER BY distance
        LIMIT :limit
    """)
    
    results = db.exec(
        query,
        {
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius_meters,
            "limit": limit,
        },
    ).all()
    
    voters = []
    for row in results:
        voter_dict = {
            "id": row[0],
            "voter_id": row[1],
            "first_name": row[2],
            "last_name": row[3],
            "address": row[4],
            "city": row[5],
            "state": row[6],
            "zip": row[7],
            "party_affiliation": row[9],
            "support_level": row[10],
            "phone": row[11],
            "email": row[12],
            "created_at": row[13],
            "updated_at": row[14],
            "location": point_to_coordinate(row[15]) if len(row) > 15 and row[15] else None,
        }
        voters.append(VoterRead(**voter_dict))
    
    return voters
