"""
VEP MVP Backend - Contact Log Models

Database models and Pydantic schemas for contact logs.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlmodel import Field, SQLModel

from app.models.voter import Coordinate


class ContactType:
    """Contact type constants."""
    KNOCKED = "knocked"
    PHONE = "phone"
    TEXT = "text"
    EMAIL = "email"
    NOT_HOME = "not_home"
    REFUSED = "refused"
    MOVED = "moved"
    DECEASED = "deceased"


class ContactLogBase(SQLModel):
    """Base contact log fields shared across schemas."""
    assignment_id: UUID
    voter_id: UUID
    contact_type: str
    result: Optional[str] = None
    support_level: Optional[int] = Field(default=None, ge=1, le=5)


class ContactLog(ContactLogBase, table=True):
    """
    ContactLog database model.
    
    Records every voter contact interaction made by canvassers.
    Tracks contact type, result, support level changes, and GPS location.
    Location field records where the canvasser was when logging (for verification).
    """
    __tablename__ = "contact_logs"
    
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id")
    # Note: location is stored as GEOMETRY(POINT, 4326) in PostgreSQL
    # We'll handle conversion in the routes layer
    contacted_at: datetime = Field(default_factory=datetime.utcnow)
    created_at: datetime = Field(default_factory=datetime.utcnow)


class ContactLogCreate(ContactLogBase):
    """Schema for creating a new contact log."""
    location: Optional[Coordinate] = None


class ContactLogUpdate(SQLModel):
    """Schema for updating a contact log."""
    contact_type: Optional[str] = None
    result: Optional[str] = None
    support_level: Optional[int] = Field(default=None, ge=1, le=5)


class ContactLogRead(ContactLogBase):
    """Schema for reading a contact log."""
    id: UUID
    user_id: UUID
    location: Optional[Coordinate] = None
    contacted_at: datetime
    created_at: datetime


class ContactLogWithDetails(ContactLogRead):
    """Schema for reading a contact log with voter details."""
    voter_name: Optional[str] = None
