"""
VEP MVP Backend - Authentication Routes

Endpoints for user authentication and authorization.
"""

from datetime import datetime, timedelta
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from jose import jwt
from passlib.context import CryptContext
from pydantic import BaseModel, EmailStr
from sqlmodel import select

from app.config import settings
from app.dependencies import CurrentUser, DatabaseSession, get_db
from app.models.user import User, UserCreate, UserRead

router = APIRouter()

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class Token(BaseModel):
    """JWT token response."""
    user_id: str
    email: str
    token: str
    role: str


class LoginRequest(BaseModel):
    """Login request schema."""
    email: EmailStr
    password: str


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash."""
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """Hash a password."""
    return pwd_context.hash(password)


def create_access_token(data: dict, expires_delta: timedelta | None = None) -> str:
    """Create a JWT access token."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)
    return encoded_jwt


@router.post("/signup", response_model=Token, status_code=status.HTTP_201_CREATED)
async def signup(user_data: UserCreate, db: DatabaseSession):
    """
    Create a new user account.
    
    Args:
        user_data: User registration data
        db: Database session
        
    Returns:
        Token: JWT token and user info
        
    Raises:
        HTTPException: If email already exists
    """
    # Check if user already exists
    statement = select(User).where(User.email == user_data.email)
    existing_user = db.exec(statement).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )
    
    # Create new user
    hashed_password = get_password_hash(user_data.password)
    db_user = User(
        email=user_data.email,
        full_name=user_data.full_name,
        role=user_data.role,
        phone=user_data.phone,
    )
    # Note: In production, we'd store hashed_password in a separate auth table
    # For MVP with Supabase, this is handled by Supabase Auth
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    # Create access token
    access_token = create_access_token(data={"sub": str(db_user.id)})
    
    return Token(
        user_id=str(db_user.id),
        email=db_user.email,
        token=access_token,
        role=db_user.role,
    )


@router.post("/login", response_model=Token)
async def login(login_data: LoginRequest, db: DatabaseSession):
    """
    Authenticate a user and return a JWT token.
    
    Args:
        login_data: Login credentials
        db: Database session
        
    Returns:
        Token: JWT token and user info
        
    Raises:
        HTTPException: If credentials are invalid
    """
    # Find user by email
    statement = select(User).where(User.email == login_data.email)
    user = db.exec(statement).first()
    
    # Note: In production with Supabase, we'd call Supabase Auth API
    # For MVP demo, we'll verify against a mock password check
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # TODO: Verify password with Supabase Auth
    # For MVP, we'll just check if password is provided
    if not login_data.password:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Create access token
    access_token = create_access_token(data={"sub": str(user.id)})
    
    return Token(
        user_id=str(user.id),
        email=user.email,
        token=access_token,
        role=user.role,
    )


@router.get("/me", response_model=UserRead)
async def get_current_user_info(current_user: CurrentUser):
    """
    Get the current authenticated user's information.
    
    Args:
        current_user: The authenticated user
        
    Returns:
        UserRead: User information
    """
    return current_user


@router.post("/logout")
async def logout():
    """
    Logout the current user.
    
    Note: With JWT, logout is typically handled client-side by discarding the token.
    This endpoint exists for API completeness and could be used for token blacklisting.
    
    Returns:
        dict: Success message
    """
    return {"message": "Successfully logged out"}
