import logging
from typing import Optional, Dict
from app.firebase import get_db, send_fcm_message
from app.config import settings

logger = logging.getLogger("resq_backend.notifications")

class NotificationService:
    @staticmethod
    def get_ambulance_fcm_token() -> Optional[str]:
        try:
            db = get_db()
            doc = db.collection("ambulances").document(settings.AMBULANCE_DOCUMENT_ID).get()
            if doc.exists:
                data = doc.to_dict()
                return data.get("fcmToken")
            return None
        except Exception as e:
            logger.warning(f"Error reading ambulance FCM token: {e}")
            return None

    @classmethod
    def notify_ambulance_of_incident(
        cls,
        incident_id: str,
        category: str,
        service_type: str = "ambulance",
        latitude: float = 0.0,
        longitude: float = 0.0,
        description: Optional[str] = None,
        offer_expires_at: Optional[str] = None,
    ) -> bool:
        """
        Sends high-priority push notification to the responder phone.
        Excludes all sensitive patient medical information per HIPAA / Civic privacy spec.
        """
        token = cls.get_ambulance_fcm_token()

        if service_type == "women_safety":
            title = "🚨 New Women Safety Emergency"
            body = "Personal safety alert triggered! Immediate Quick Response Patrol dispatch required."
        elif service_type == "fire_brigade":
            title = "🚨 New Fire Brigade Emergency"
            desc_text = f" ({description})" if description else ""
            body = f"Fire/rescue emergency reported{desc_text}. Immediate fire squad dispatch required."
        else:
            title = "🚨 New Ambulance Emergency"
            body = "Emergency request received. Tap to respond."

        data = {
            "incidentId": incident_id,
            "category": category,
            "serviceType": service_type,
            "latitude": str(latitude),
            "longitude": str(longitude),
            "type": "NEW_EMERGENCY_DISPATCH",
            "offerExpiresAt": str(offer_expires_at or ""),
            "acceptanceTimeoutSeconds": "6",
        }
        return send_fcm_message(token, title, body, data)
