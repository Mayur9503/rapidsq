from pydantic import BaseModel, Field, field_validator
from typing import Optional

class AmbulanceLocationUpdate(BaseModel):
    latitude: float = Field(..., description="Ambulance GPS latitude")
    longitude: float = Field(..., description="Ambulance GPS longitude")

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

class AmbulanceStatusResponse(BaseModel):
    ambulanceId: str
    status: str
    driverName: str
    vehicleNumber: str
    phone: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    lastLocationUpdate: Optional[str] = None
