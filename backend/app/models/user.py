"""
VEP MVP Backend - User Models

Database models and Pydantic schemas for users.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from pydantic import EmailStr
from sqlmodel import Field, SQLModel


class UserRole:
    """User role constants."""
    ADMIN = "admin"
    MANAGER = "manager"
    CANVASSER = "canvasser"


class UserBase(SQLModel):
    """Base user fields shared across schemas."""
    email: EmailStr
    full_name: str
    role: str = Field(default=UserRole.CANVASSER)
    phone: Optional[str] = None


class User(UserBase, table=True):
    """
    User database model.
    
    Stores user metadata for authentication and role-based access control.
    Supabase Auth handles authentication; this table stores additional metadata.
    """
    __tablename__ = "users"
    
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


class UserCreate(UserBase):
    """Schema for creating a new user."""
    password: str


class UserUpdate(SQLModel):
    """Schema for updating a user."""
    email: Optional[EmailStr] = None
    full_name: Optional[str] = None
    role: Optional[str] = None
    phone: Optional[str] = None


class UserRead(UserBase):
    """Schema for reading a user (public fields)."""
    id: UUID
    created_at: datetime
    updated_at: datetime
