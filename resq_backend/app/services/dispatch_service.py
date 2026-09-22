import uuid
import asyncio
import logging
from datetime import datetime, timezone, timedelta
from typing import Dict, Any, Optional
from fastapi import HTTPException, status
from app.firebase import get_db
from app.config import settings
from app.models.incident import IncidentCreateRequest, IncidentResponse
from app.services.notification_service import NotificationService

logger = logging.getLogger("resq_backend.dispatch")

class DispatchService:
    ACCEPTANCE_TIMEOUT_SECONDS: int = 6

    @staticmethod
    def _now_iso() -> str:
        return datetime.now(timezone.utc).isoformat()

    @classmethod
    def create_incident(cls, user_uid: str, req: IncidentCreateRequest) -> IncidentResponse:
        db = get_db()
        emergencies_col = db.collection("emergencies")

        # Generate unique incident ID e.g. RQ-A1B2C3
        unique_suffix = uuid.uuid4().hex[:6].upper()
        incident_id = f"RQ-{unique_suffix}"
        now_dt = datetime.now(timezone.utc)
        now_ts = now_dt.isoformat()
        expires_dt = now_dt + timedelta(seconds=cls.ACCEPTANCE_TIMEOUT_SECONDS)
        expires_ts = expires_dt.isoformat()

        # Build firestore payload with OFFERED status and 6-second expiration
        incident_doc = {
            "incidentId": incident_id,
            "userId": user_uid,
            "latitude": req.latitude,
            "longitude": req.longitude,
            "locationTitle": req.locationTitle,
            "locationSubtitle": req.locationSubtitle,
            "description": req.description or "Emergency SOS Alert",
            "category": req.category,
            "serviceType": req.serviceType,
            "priority": req.priority or "CRITICAL",
            "medicalProfileRef": req.medicalProfileRef,
            "status": "OFFERED",
            "assignedAmbulanceId": None,
            "offerExpiresAt": expires_ts,
            "acceptanceTimeoutSeconds": cls.ACCEPTANCE_TIMEOUT_SECONDS,
            "createdAt": now_ts,
            "updatedAt": now_ts,
        }

        # Store in Firestore
        emergencies_col.document(incident_id).set(incident_doc)

        # Update the single registered ambulance/rider status to OFFERED
        ambulance_ref = db.collection("ambulances").document(settings.AMBULANCE_DOCUMENT_ID)
        amb_doc = ambulance_ref.get()
        if amb_doc.exists:
            amb_data = amb_doc.to_dict()
            if amb_data.get("status") in ["AVAILABLE", "OFFERED", None]:
                ambulance_ref.update({
                    "status": "OFFERED",
                    "offeredIncidentId": incident_id,
                    "offeredServiceType": req.serviceType,
                    "offerExpiresAt": expires_ts,
                    "updatedAt": now_ts,
                })
        else:
            # Seed ambulance document if not yet initialized
            ambulance_ref.set({
                "ambulanceId": settings.AMBULANCE_DOCUMENT_ID,
                "riderUid": "rider-default",
                "driverId": "driver-default",
                "driverName": settings.AMBULANCE_DEFAULT_DRIVER,
                "vehicleNumber": settings.AMBULANCE_DEFAULT_VEHICLE,
                "phone": settings.AMBULANCE_DEFAULT_PHONE,
                "status": "OFFERED",
                "offeredIncidentId": incident_id,
                "offeredServiceType": req.serviceType,
                "offerExpiresAt": expires_ts,
                "latitude": 28.6340,
                "longitude": 77.3710,
                "lastLocationUpdate": now_ts,
                "fcmToken": None,
                "updatedAt": now_ts,
            })

        # Trigger FCM push notification to registered rider device
        NotificationService.notify_ambulance_of_incident(
            incident_id=incident_id,
            category=req.category or "selfSOS",
            service_type=req.serviceType,
            latitude=req.latitude,
            longitude=req.longitude,
            description=req.description,
            offer_expires_at=expires_ts,
        )

        # Asynchronous background task to auto-expire the offer after 6.0 seconds if unaccepted
        try:
            loop = asyncio.get_event_loop()
            if loop.is_running():
                asyncio.create_task(cls.auto_expire_incident_if_unaccepted(incident_id, delay=6.0))
        except Exception as e:
            logger.debug(f"Asyncio task schedule note: {e}")

        return IncidentResponse(
            incidentId=incident_id,
            status="OFFERED",
            userId=user_uid,
            latitude=req.latitude,
            longitude=req.longitude,
            serviceType=req.serviceType,
            priority=req.priority or "CRITICAL",
            assignedAmbulanceId=None,
            createdAt=now_ts,
            offerExpiresAt=expires_ts,
            acceptanceTimeoutSeconds=cls.ACCEPTANCE_TIMEOUT_SECONDS,
            message=f"Incident created and offered to registered rider for {req.serviceType} emergency response.",
        )

    @classmethod
    async def auto_expire_incident_if_unaccepted(cls, incident_id: str, delay: float = 6.0):
        """
        Background task: After 6 seconds, if the incident has not been accepted,
        automatically mark it WAITING_FOR_RESPONDER and release the ambulance to AVAILABLE.
        """
        await asyncio.sleep(delay)
        try:
            db = get_db()
            incident_ref = db.collection("emergencies").document(incident_id)
            incident_snap = incident_ref.get()
            if incident_snap.exists:
                data = incident_snap.to_dict()
                if data.get("status") == "OFFERED":
                    now_ts = cls._now_iso()
                    incident_ref.update({
                        "status": "WAITING_FOR_RESPONDER",
                        "rejectionReason": "No responder accepted the emergency.",
                        "updatedAt": now_ts,
                    })
                    ambulance_ref = db.collection("ambulances").document(settings.AMBULANCE_DOCUMENT_ID)
                    amb_snap = ambulance_ref.get()
                    if amb_snap.exists and amb_snap.to_dict().get("offeredIncidentId") == incident_id:
                        ambulance_ref.update({
                            "status": "AVAILABLE",
                            "offeredIncidentId": None,
                            "updatedAt": now_ts,
                        })
                    logger.info(f"Incident {incident_id} expired after {delay}s timeout -> WAITING_FOR_RESPONDER")
        except Exception as e:
            logger.warning(f"Error in auto_expire_incident_if_unaccepted: {e}")

    @classmethod
    def respond_to_incident(cls, driver_uid: str, incident_id: str, action: str) -> Dict[str, Any]:
        db = get_db()
        incident_ref = db.collection("emergencies").document(incident_id)
        incident_snap = incident_ref.get()

        if not incident_snap.exists:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Incident '{incident_id}' not found."
            )

        incident_data = incident_snap.to_dict()
        ambulance_ref = db.collection("ambulances").document(settings.AMBULANCE_DOCUMENT_ID)
        now_ts = cls._now_iso()

        # Enforce that only the registered rider for this ambulance can respond
        amb_snap = ambulance_ref.get()
        if amb_snap.exists:
            amb_data = amb_snap.to_dict()
            registered_rider = amb_data.get("riderUid") or amb_data.get("driverId")
            if registered_rider and registered_rider != driver_uid:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Forbidden: Only the registered rider for this ambulance can respond to dispatches."
                )

        # Enforce server-side 6-second acceptance expiry
        offer_expires_at = incident_data.get("offerExpiresAt")
        if offer_expires_at:
            try:
                expires_dt = datetime.fromisoformat(offer_expires_at)
                if datetime.now(timezone.utc) > expires_dt:
                    incident_ref.update({
                        "status": "WAITING_FOR_RESPONDER",
                        "rejectionReason": "No responder accepted the emergency.",
                        "updatedAt": now_ts,
                    })
                    ambulance_ref.update({
                        "status": "AVAILABLE",
                        "offeredIncidentId": None,
                        "updatedAt": now_ts,
                    })
                    raise HTTPException(
                        status_code=status.HTTP_409_CONFLICT,
                        detail="Emergency offer has expired. The 6-second acceptance window has elapsed."
                    )
            except HTTPException:
                raise
            except Exception as e:
                logger.warning(f"Error parsing offerExpiresAt: {e}")

        if action == "ACCEPT":
            if incident_data.get("status") not in ["OFFERED", "SEARCHING"]:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail=f"Incident is not offered for acceptance (current status: {incident_data.get('status')})."
                )

            # Update incident to ASSIGNED
            incident_ref.update({
                "status": "ASSIGNED",
                "assignedAmbulanceId": settings.AMBULANCE_DOCUMENT_ID,
                "assignedDriverId": driver_uid,
                "assignedRiderUid": driver_uid,
                "assignedAt": now_ts,
                "updatedAt": now_ts,
            })

            # Update ambulance status to BUSY
            ambulance_ref.update({
                "status": "BUSY",
                "activeIncidentId": incident_id,
                "driverId": driver_uid,
                "riderUid": driver_uid,
                "updatedAt": now_ts,
            })

            return {
                "incidentId": incident_id,
                "status": "ASSIGNED",
                "ambulanceId": settings.AMBULANCE_DOCUMENT_ID,
                "action": "ACCEPT",
                "message": "Rider accepted emergency dispatch. En route to patient.",
                "updatedAt": now_ts,
            }
        elif action == "REJECT":
            # Update incident to WAITING_FOR_RESPONDER for single-responder college project
            incident_ref.update({
                "status": "WAITING_FOR_RESPONDER",
                "rejectionReason": "No responder accepted the emergency.",
                "updatedAt": now_ts,
            })

            # Release ambulance back to AVAILABLE
            ambulance_ref.update({
                "status": "AVAILABLE",
                "offeredIncidentId": None,
                "activeIncidentId": None,
                "updatedAt": now_ts,
            })

            return {
                "incidentId": incident_id,
                "status": "WAITING_FOR_RESPONDER",
                "action": "REJECT",
                "message": "Incident offer rejected. No responder accepted the emergency.",
                "updatedAt": now_ts,
            }
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Action must be ACCEPT or REJECT."
            )

    @classmethod
    def update_ambulance_location(cls, driver_uid: str, latitude: float, longitude: float) -> Dict[str, Any]:
        db = get_db()
        ambulance_ref = db.collection("ambulances").document(settings.AMBULANCE_DOCUMENT_ID)
        now_ts = cls._now_iso()

        ambulance_ref.update({
            "latitude": latitude,
            "longitude": longitude,
            "lastLocationUpdate": now_ts,
            "driverId": driver_uid,
        })

        return {
            "ambulanceId": settings.AMBULANCE_DOCUMENT_ID,
            "latitude": latitude,
            "longitude": longitude,
            "lastLocationUpdate": now_ts,
            "status": "OK",
        }

    @classmethod
    def register_fcm_token(cls, fcm_token: str, device_type: str, rider_uid: Optional[str] = None) -> Dict[str, Any]:
        db = get_db()
        ambulance_ref = db.collection("ambulances").document(settings.AMBULANCE_DOCUMENT_ID)
        now_ts = cls._now_iso()

        payload = {
            "fcmToken": fcm_token,
            "lastTokenRegistration": now_ts,
            "deviceType": device_type,
            "status": "AVAILABLE",
            "updatedAt": now_ts,
        }
        if rider_uid:
            payload["riderUid"] = rider_uid
            payload["driverId"] = rider_uid

        ambulance_ref.set(payload, merge=True)

        return {
            "message": "FCM token registered and rider linked successfully.",
            "ambulanceId": settings.AMBULANCE_DOCUMENT_ID,
            "fcmToken": fcm_token,
            "riderUid": rider_uid,
            "registeredAt": now_ts,
        }
