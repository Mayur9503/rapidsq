from fastapi import APIRouter, Depends, status
from app.auth import get_current_user_uid
from app.models.device import FcmTokenRegistrationRequest
from app.services.dispatch_service import DispatchService

router = APIRouter(prefix="/api/devices", tags=["devices"])

@router.post("/fcm-token", status_code=status.HTTP_200_OK)
async def register_fcm_token(
    req: FcmTokenRegistrationRequest,
    current_uid: str = Depends(get_current_user_uid),
):
    """
    Registers the Ambulance/Rider phone FCM token for incoming emergency push alerts
    and binds the authenticated riderUid to the single ambulance document.
    """
    return DispatchService.register_fcm_token(
        fcm_token=req.fcmToken,
        device_type=req.deviceType,
        rider_uid=current_uid,
    )
