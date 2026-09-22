import logging
from typing import Optional
from fastapi import Header, HTTPException, status
from app.config import settings

logger = logging.getLogger("resq_backend.auth")

async def get_current_user_uid(authorization: Optional[str] = Header(None)) -> str:
    """
    Extracts and verifies Firebase Authentication ID Token from Authorization header.
    Returns the authenticated user UID.
    """
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization header missing. Bearer token required.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    parts = authorization.split(" ")
    if len(parts) != 2 or parts[0].lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authorization format. Must be 'Bearer <token>'.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = parts[1]

    # Dev/Testing Bypass for offline tests and college demo
    if settings.ALLOW_DEV_TOKEN_AUTH:
        if token == "dev-test-token":
            return "dev-test-uid"
        elif token == "driver-token":
            return "driver-default"
        elif token.startswith("dev-user:"):
            return token.split("dev-user:")[1]

    try:
        from firebase_admin import auth
        decoded_token = auth.verify_id_token(token)
        uid = decoded_token.get("uid")
        if not uid:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Firebase token contains no UID.",
            )
        return uid
    except HTTPException:
        raise
    except Exception as e:
        logger.warning(f"Failed to verify Firebase ID token: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid or expired Firebase ID token: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )
