"""
VEP MVP Backend - Configuration

Application settings loaded from environment variables.
"""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Application settings loaded from environment variables.
    
    See .env.example for all available configuration options.
    """

    # Supabase Configuration
    SUPABASE_URL: str = "https://your-project.supabase.co"
    SUPABASE_KEY: str = "your-supabase-anon-key"
    SUPABASE_SERVICE_KEY: str = "your-supabase-service-key"
    DATABASE_URL: str = "postgresql://postgres:password@localhost:5432/vep"

    # JWT Configuration
    JWT_SECRET: str = "change-me-in-production"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # Application Configuration
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    LOG_LEVEL: str = "INFO"

    # CORS Configuration
    ALLOWED_ORIGINS: list[str] = [
        "http://localhost:3000",
        "http://localhost:8000",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8000",
    ]

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
    )


# Global settings instance
settings = Settings()
