"""
VEP MVP Backend - User Routes

Endpoints for user management.
"""

from uuid import UUID

from fastapi import APIRouter, HTTPException, status
from sqlmodel import select

from app.dependencies import AdminUser, CurrentUser, DatabaseSession, ManagerUser
from app.models.user import User, UserCreate, UserRead, UserUpdate
from app.routes.auth import get_password_hash

router = APIRouter()


@router.get("/", response_model=list[UserRead])
async def list_users(db: DatabaseSession, current_user: ManagerUser):
    """
    List all users (managers and admins only).
    
    Args:
        db: Database session
        current_user: Authenticated manager/admin user
        
    Returns:
        list[UserRead]: List of users
    """
    statement = select(User)
    users = db.exec(statement).all()
    return users


@router.get("/{user_id}", response_model=UserRead)
async def get_user(user_id: UUID, db: DatabaseSession, current_user: CurrentUser):
    """
    Get a specific user by ID.
    
    Users can view their own profile, managers/admins can view any user.
    
    Args:
        user_id: User ID
        db: Database session
        current_user: Authenticated user
        
    Returns:
        UserRead: User information
        
    Raises:
        HTTPException: If user not found or unauthorized
    """
    statement = select(User).where(User.id == user_id)
    user = db.exec(statement).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    
    # Check authorization: users can view themselves, managers/admins can view anyone
    if user.id != current_user.id and current_user.role not in ["manager", "admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view this user",
        )
    
    return user


@router.post("/", response_model=UserRead, status_code=status.HTTP_201_CREATED)
async def create_user(user_data: UserCreate, db: DatabaseSession, current_user: AdminUser):
    """
    Create a new user (admin only).
    
    Args:
        user_data: User data
        db: Database session
        current_user: Authenticated admin user
        
    Returns:
        UserRead: Created user
        
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
    # Note: password stored in Supabase Auth, not in this table
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    return db_user


@router.put("/{user_id}", response_model=UserRead)
async def update_user(
    user_id: UUID,
    user_data: UserUpdate,
    db: DatabaseSession,
    current_user: CurrentUser,
):
    """
    Update a user.
    
    Users can update their own profile, admins can update any user.
    
    Args:
        user_id: User ID
        user_data: User update data
        db: Database session
        current_user: Authenticated user
        
    Returns:
        UserRead: Updated user
        
    Raises:
        HTTPException: If user not found or unauthorized
    """
    statement = select(User).where(User.id == user_id)
    user = db.exec(statement).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    
    # Check authorization: users can update themselves, admins can update anyone
    if user.id != current_user.id and current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to update this user",
        )
    
    # Only admins can change roles
    if user_data.role is not None and current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins can change user roles",
        )
    
    # Update fields
    update_data = user_data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(user, key, value)
    
    db.add(user)
    db.commit()
    db.refresh(user)
    
    return user
