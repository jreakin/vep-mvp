"""
VEP MVP Backend - Dependencies

Provides dependency injection for FastAPI endpoints:
- Database session management
- Authentication and authorization
- User context
"""

from typing import Annotated, Optional
from uuid import UUID

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from sqlmodel import Session, create_engine, select
from sqlalchemy.pool import NullPool

from app.config import settings
from app.models.user import User

# Database engine
engine = create_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,
    poolclass=NullPool,  # Use NullPool for serverless environments
)

# Security scheme
security = HTTPBearer()


def get_db() -> Session:
    """
    Dependency that provides a database session.
    
    Yields:
        Session: SQLModel database session
    """
    with Session(engine) as session:
        yield session


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(security)],
    db: Annotated[Session, Depends(get_db)],
) -> User:
    """
    Dependency that extracts and validates the current user from JWT token.
    
    Args:
        credentials: HTTP bearer token credentials
        db: Database session
        
    Returns:
        User: The authenticated user
        
    Raises:
        HTTPException: If token is invalid or user not found
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        token = credentials.credentials
        payload = jwt.decode(
            token,
            settings.JWT_SECRET,
            algorithms=[settings.JWT_ALGORITHM],
        )
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    # Fetch user from database
    statement = select(User).where(User.id == UUID(user_id))
    user = db.exec(statement).first()
    
    if user is None:
        raise credentials_exception
    
    return user


async def get_current_active_user(
    current_user: Annotated[User, Depends(get_current_user)]
) -> User:
    """
    Dependency that ensures the current user is active.
    
    Args:
        current_user: The authenticated user
        
    Returns:
        User: The active user
        
    Raises:
        HTTPException: If user is inactive
    """
    # For MVP, all users are considered active
    # This can be extended later with user.is_active field
    return current_user


async def require_manager(
    current_user: Annotated[User, Depends(get_current_active_user)]
) -> User:
    """
    Dependency that requires the current user to be a manager or admin.
    
    Args:
        current_user: The authenticated user
        
    Returns:
        User: The manager/admin user
        
    Raises:
        HTTPException: If user is not a manager or admin
    """
    if current_user.role not in ["manager", "admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions. Manager or admin role required.",
        )
    return current_user


async def require_admin(
    current_user: Annotated[User, Depends(get_current_active_user)]
) -> User:
    """
    Dependency that requires the current user to be an admin.
    
    Args:
        current_user: The authenticated user
        
    Returns:
        User: The admin user
        
    Raises:
        HTTPException: If user is not an admin
    """
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions. Admin role required.",
        )
    return current_user


# Type aliases for common dependencies
CurrentUser = Annotated[User, Depends(get_current_active_user)]
ManagerUser = Annotated[User, Depends(require_manager)]
AdminUser = Annotated[User, Depends(require_admin)]
DatabaseSession = Annotated[Session, Depends(get_db)]
