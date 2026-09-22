from fastapi import APIRouter, Depends, HTTPException, status
from app.auth import get_current_user_uid
from app.models.incident import IncidentCreateRequest, IncidentResponse, IncidentRespondRequest
from app.services.dispatch_service import DispatchService
from app.firebase import get_db

router = APIRouter(prefix="/api/incidents", tags=["incidents"])

@router.post("", response_model=IncidentResponse, status_code=status.HTTP_201_CREATED)
async def create_incident(
    req: IncidentCreateRequest,
    current_uid: str = Depends(get_current_user_uid),
):
    """
    User Phone triggers emergency SOS.
    1. Verifies Firebase ID Token and gets authenticated UID.
    2. Validates latitude & longitude.
    3. Creates Firestore emergency document with SEARCHING status.
    4. Automatically offers to single ambulance unit and dispatches FCM notification.
    """
    return DispatchService.create_incident(user_uid=current_uid, req=req)

@router.post("/{incident_id}/respond", status_code=status.HTTP_200_OK)
async def respond_to_incident(
    incident_id: str,
    req: IncidentRespondRequest,
    current_uid: str = Depends(get_current_user_uid),
):
    """
    Ambulance Phone driver accepts or rejects an emergency offer.
    - ACCEPT: Incident status -> ASSIGNED, Ambulance status -> BUSY.
    - REJECT: Incident status -> FAILED, Ambulance status -> AVAILABLE.
    """
    return DispatchService.respond_to_incident(
        driver_uid=current_uid,
        incident_id=incident_id,
        action=req.response,
    )

@router.get("/{incident_id}", status_code=status.HTTP_200_OK)
async def get_incident(
    incident_id: str,
    current_uid: str = Depends(get_current_user_uid),
):
    db = get_db()
    snap = db.collection("emergencies").document(incident_id).get()
    if not snap.exists:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Incident '{incident_id}' not found.",
        )
    return snap.to_dict()
