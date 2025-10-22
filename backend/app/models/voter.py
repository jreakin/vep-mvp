"""
VEP MVP Backend - Voter Models

Database models and Pydantic schemas for voters.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlmodel import Field, SQLModel


class Coordinate(SQLModel):
    """Geographic coordinate."""
    latitude: float
    longitude: float


class VoterBase(SQLModel):
    """Base voter fields shared across schemas."""
    voter_id: str = Field(unique=True, index=True)
    first_name: str
    last_name: str
    address: str
    city: str
    state: str = Field(default="TX")
    zip: str
    party_affiliation: Optional[str] = None
    support_level: Optional[int] = Field(default=None, ge=1, le=5)
    phone: Optional[str] = None
    email: Optional[str] = None


class Voter(VoterBase, table=True):
    """
    Voter database model.
    
    Stores voter information with PostGIS location data for spatial queries.
    External voter_id links to VAN/PDI voter databases.
    Support level: 1=Strong Opponent, 2=Lean Opponent, 3=Undecided,
                   4=Lean Support, 5=Strong Support
    """
    __tablename__ = "voters"
    
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    # Note: location is stored as GEOMETRY(POINT, 4326) in PostgreSQL
    # We'll handle conversion in the routes layer
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


class VoterCreate(VoterBase):
    """Schema for creating a new voter."""
    location: Optional[Coordinate] = None


class VoterUpdate(SQLModel):
    """Schema for updating a voter."""
    voter_id: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    zip: Optional[str] = None
    party_affiliation: Optional[str] = None
    support_level: Optional[int] = Field(default=None, ge=1, le=5)
    phone: Optional[str] = None
    email: Optional[str] = None
    location: Optional[Coordinate] = None


class VoterRead(VoterBase):
    """Schema for reading a voter."""
    id: UUID
    location: Optional[Coordinate] = None
    created_at: datetime
    updated_at: datetime


class VoterWithContactHistory(VoterRead):
    """Schema for reading a voter with contact history."""
    contact_history: list = Field(default_factory=list)
