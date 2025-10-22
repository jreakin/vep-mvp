"""
VEP MVP Backend - Main Application

This is a skeleton file created for multi-agent development.
Agent 2 (Backend Engineer) will complete this implementation.

See: spec.md Section 3 and AGENT_INSTRUCTIONS.md (Agent 2)
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# TODO (Agent 2): Import your route modules
# from app.routes import auth, assignments, voters, contact_logs, analytics
# from app.config import settings

app = FastAPI(
    title="VEP MVP API",
    description="Voter Engagement Platform MVP - Backend API",
    version="0.1.0",
)

# TODO (Agent 2): Configure CORS from settings
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=settings.ALLOWED_ORIGINS,
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# TODO (Agent 2): Include routers
# app.include_router(auth.router, prefix="/auth", tags=["auth"])
# app.include_router(assignments.router, prefix="/assignments", tags=["assignments"])
# app.include_router(voters.router, prefix="/voters", tags=["voters"])
# app.include_router(contact_logs.router, prefix="/contact-logs", tags=["contact-logs"])
# app.include_router(analytics.router, prefix="/analytics", tags=["analytics"])


@app.get("/")
async def root():
    """
    Health check endpoint.
    """
    return {
        "message": "VEP MVP API",
        "status": "ok",
        "version": "0.1.0",
        "docs": "/docs",
    }


@app.get("/health")
async def health_check():
    """
    Health check for monitoring.
    """
    # TODO (Agent 2): Add database health check
    return {"status": "healthy"}


# TODO (Agent 2): Add startup and shutdown event handlers
# @app.on_event("startup")
# async def startup_event():
#     """Initialize database connection pool, etc."""
#     pass

# @app.on_event("shutdown")
# async def shutdown_event():
#     """Close database connections, cleanup, etc."""
#     pass


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )
