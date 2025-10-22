"""
VEP MVP Backend - Main Application

FastAPI application with all routes and middleware configured.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.routes import auth, assignments, contact_logs, users, voters

app = FastAPI(
    title="VEP MVP API",
    description="Voter Engagement Platform MVP - Backend API",
    version="0.1.0",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/auth", tags=["Authentication"])
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(assignments.router, prefix="/assignments", tags=["Assignments"])
app.include_router(voters.router, prefix="/voters", tags=["Voters"])
app.include_router(contact_logs.router, prefix="/contact-logs", tags=["Contact Logs"])


@app.get("/")
async def root():
    """
    API root endpoint with basic information.
    """
    return {
        "message": "VEP MVP API",
        "status": "ok",
        "version": "0.1.0",
        "docs": "/docs",
        "environment": settings.ENVIRONMENT,
    }


@app.get("/health")
async def health_check():
    """
    Health check endpoint for monitoring and load balancers.
    """
    return {
        "status": "healthy",
        "version": "0.1.0",
        "environment": settings.ENVIRONMENT,
    }


@app.on_event("startup")
async def startup_event():
    """
    Initialize application on startup.
    """
    print(f"🚀 VEP MVP API starting in {settings.ENVIRONMENT} mode")
    print(f"📊 Debug mode: {settings.DEBUG}")


@app.on_event("shutdown")
async def shutdown_event():
    """
    Cleanup on application shutdown.
    """
    print("👋 VEP MVP API shutting down")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )
