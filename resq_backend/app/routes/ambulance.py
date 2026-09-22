from fastapi import APIRouter, Depends, HTTPException, status
from app.auth import get_current_user_uid
from app.models.ambulance import AmbulanceLocationUpdate, AmbulanceStatusResponse
from app.services.dispatch_service import DispatchService
from app.firebase import get_db
from app.config import settings

router = APIRouter(prefix="/api/ambulances", tags=["ambulances"])

@router.post("/main/location", status_code=status.HTTP_200_OK)
async def update_ambulance_location(
    req: AmbulanceLocationUpdate,
    current_uid: str = Depends(get_current_user_uid),
):
    """
    Ambulance phone uploads its real-time GPS coordinates.
    Updates the single ambulance document in Firestore.
    """
    return DispatchService.update_ambulance_location(
        driver_uid=current_uid,
        latitude=req.latitude,
        longitude=req.longitude,
    )

@router.get("/main", response_model=AmbulanceStatusResponse, status_code=status.HTTP_200_OK)
async def get_ambulance_status(
    current_uid: str = Depends(get_current_user_uid),
):
    """
    Returns current status and coordinates of the single configured ambulance.
    """
    db = get_db()
    snap = db.collection("ambulances").document(settings.AMBULANCE_DOCUMENT_ID).get()
    if not snap.exists:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Ambulance unit not initialized.",
        )
    data = snap.to_dict()
    return AmbulanceStatusResponse(
        ambulanceId=data.get("ambulanceId", settings.AMBULANCE_DOCUMENT_ID),
        status=data.get("status", "AVAILABLE"),
        driverName=data.get("driverName", settings.AMBULANCE_DEFAULT_DRIVER),
        vehicleNumber=data.get("vehicleNumber", settings.AMBULANCE_DEFAULT_VEHICLE),
        phone=data.get("phone", settings.AMBULANCE_DEFAULT_PHONE),
        latitude=data.get("latitude"),
        longitude=data.get("longitude"),
        lastLocationUpdate=data.get("lastLocationUpdate"),
    )
