"""
VEP MVP Backend - Assignment Models

Database models and Pydantic schemas for assignments and assignment_voters.
"""

from datetime import date, datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlmodel import Field, SQLModel


class AssignmentStatus:
    """Assignment status constants."""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class AssignmentBase(SQLModel):
    """Base assignment fields shared across schemas."""
    name: str
    description: Optional[str] = None
    assigned_date: date = Field(default_factory=date.today)
    due_date: Optional[date] = None
    status: str = Field(default=AssignmentStatus.PENDING)


class Assignment(AssignmentBase, table=True):
    """
    Assignment database model.
    
    Stores canvassing assignments linking managers to canvassers.
    Status lifecycle: pending → in_progress → completed (or cancelled).
    """
    __tablename__ = "assignments"
    
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id")
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


class AssignmentVoter(SQLModel, table=True):
    """
    AssignmentVoter junction table model.
    
    Links assignments to voters (many-to-many relationship).
    Allows pre-planned route optimization via sequence_order.
    """
    __tablename__ = "assignment_voters"
    
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    assignment_id: UUID = Field(foreign_key="assignments.id")
    voter_id: UUID = Field(foreign_key="voters.id")
    sequence_order: Optional[int] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)


class AssignmentCreate(AssignmentBase):
    """Schema for creating a new assignment."""
    user_id: UUID
    voter_ids: list[UUID] = Field(default_factory=list)


class AssignmentUpdate(SQLModel):
    """Schema for updating an assignment."""
    name: Optional[str] = None
    description: Optional[str] = None
    due_date: Optional[date] = None
    status: Optional[str] = None


class AssignmentRead(AssignmentBase):
    """Schema for reading an assignment."""
    id: UUID
    user_id: UUID
    voter_count: int = 0
    completed_count: int = 0
    created_at: datetime
    updated_at: datetime


class AssignmentWithVoters(AssignmentRead):
    """Schema for reading an assignment with voter details."""
    voters: list = Field(default_factory=list)
