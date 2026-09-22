from pydantic import BaseModel, Field

class FcmTokenRegistrationRequest(BaseModel):
    fcmToken: str = Field(..., min_length=10, description="Firebase Cloud Messaging device token")
    deviceType: str = Field("ambulance", description="Device type: ambulance or user")
