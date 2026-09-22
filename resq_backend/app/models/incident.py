from pydantic import BaseModel, Field, field_validator
from typing import Optional, Literal

class IncidentCreateRequest(BaseModel):
    latitude: float = Field(..., description="GPS latitude of patient")
    longitude: float = Field(..., description="GPS longitude of patient")
    description: Optional[str] = Field(None, description="Optional emergency description or bystander notes")
    category: Optional[str] = Field("selfSOS", description="Emergency category: selfSOS, bystanderAccident, cardiac, etc.")
    serviceType: Literal["ambulance", "women_safety", "fire_brigade"] = Field("ambulance", description="Emergency service type")
    priority: Optional[str] = Field("CRITICAL", description="Emergency priority level")
    locationTitle: Optional[str] = Field("Current Location", description="Civic operational location address title")
    locationSubtitle: Optional[str] = Field(None, description="Detailed area landmark or road description")
    medicalProfileRef: Optional[str] = Field(None, description="Optional reference to patient medical profile")

    @field_validator("latitude")
    @classmethod
    def validate_latitude(cls, v: float) -> float:
        if not (-90.0 <= v <= 90.0):
            raise ValueError("Latitude must be between -90.0 and 90.0 degrees")
        return v

    @field_validator("longitude")
    @classmethod
    def validate_longitude(cls, v: float) -> float:
        if not (-180.0 <= v <= 180.0):
            raise ValueError("Longitude must be between -180.0 and 180.0 degrees")
        return v

class IncidentRespondRequest(BaseModel):
    response: Literal["ACCEPT", "REJECT"]

class IncidentResponse(BaseModel):
    incidentId: str
    status: str
    userId: str
    latitude: float
    longitude: float
    serviceType: str = "ambulance"
    priority: Optional[str] = "CRITICAL"
    assignedAmbulanceId: Optional[str] = None
    createdAt: Optional[str] = None
    offerExpiresAt: Optional[str] = None
    acceptanceTimeoutSeconds: int = 6
    message: Optional[str] = None
