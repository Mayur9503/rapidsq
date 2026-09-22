from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

class Settings(BaseSettings):
    PROJECT_NAME: str = "ResQ Emergency Dispatch Backend"
    ENVIRONMENT: str = "development"
    PORT: int = 8000
    HOST: str = "0.0.0.0"

    # Firebase Admin SDK Configuration
    FIREBASE_PROJECT_ID: str = "rapidsq-firebase"
    FIREBASE_CREDENTIALS_PATH: Optional[str] = "serviceAccountKey.json"

    # Single Ambulance Configuration
    AMBULANCE_DOCUMENT_ID: str = "main"
    AMBULANCE_DEFAULT_VEHICLE: str = "MH 12 AB 4521"
    AMBULANCE_DEFAULT_DRIVER: str = "Rahul Patil"
    AMBULANCE_DEFAULT_PHONE: str = "+91 98765 12345"

    # Dev/Test Auth Bypass Flag
    ALLOW_DEV_TOKEN_AUTH: bool = True

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

settings = Settings()
