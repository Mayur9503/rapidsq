import os
import logging
from typing import Optional, Dict, Any
from app.config import settings

logger = logging.getLogger("resq_backend.firebase")

_firebase_initialized = False
_db_client = None

# In-memory mock store used when Firebase Admin is not connected or in test mode
class InMemoryFirestore:
    def __init__(self):
        self.collections: Dict[str, Dict[str, Dict[str, Any]]] = {
            "emergencies": {},
            "ambulances": {
                settings.AMBULANCE_DOCUMENT_ID: {
                    "ambulanceId": settings.AMBULANCE_DOCUMENT_ID,
                    "driverId": "driver-default",
                    "driverName": settings.AMBULANCE_DEFAULT_DRIVER,
                    "vehicleNumber": settings.AMBULANCE_DEFAULT_VEHICLE,
                    "phone": settings.AMBULANCE_DEFAULT_PHONE,
                    "status": "AVAILABLE",
                    "latitude": 28.6340,
                    "longitude": 77.3710,
                    "lastLocationUpdate": None,
                    "fcmToken": None,
                }
            },
            "incident_events": {}
        }

    def collection(self, name: str):
        if name not in self.collections:
            self.collections[name] = {}
        return InMemoryCollection(self.collections[name])

class InMemoryCollection:
    def __init__(self, store: Dict[str, Dict[str, Any]]):
        self._store = store

    def document(self, doc_id: Optional[str] = None):
        import uuid
        actual_id = doc_id or f"doc_{uuid.uuid4().hex[:8]}"
        return InMemoryDocument(self._store, actual_id)

    def doc(self, doc_id: str):
        return self.document(doc_id)

class InMemoryDocument:
    def __init__(self, store: Dict[str, Dict[str, Any]], doc_id: str):
        self._store = store
        self.id = doc_id

    def get(self):
        data = self._store.get(self.id)
        return InMemorySnapshot(self.id, data)

    def set(self, data: Dict[str, Any], merge: bool = False):
        if merge and self.id in self._store:
            self._store[self.id].update(data)
        else:
            self._store[self.id] = data

    def update(self, data: Dict[str, Any]):
        if self.id not in self._store:
            self._store[self.id] = {}
        self._store[self.id].update(data)

class InMemorySnapshot:
    def __init__(self, doc_id: str, data: Optional[Dict[str, Any]]):
        self.id = doc_id
        self._data = data
        self.exists = data is not None

    def to_dict(self):
        return self._data or {}

_in_memory_db = InMemoryFirestore()

def init_firebase_admin():
    global _firebase_initialized, _db_client
    if _firebase_initialized:
        return

    cred_path = settings.FIREBASE_CREDENTIALS_PATH
    try:
        import firebase_admin
        from firebase_admin import credentials, firestore

        service_account_raw = settings.FIREBASE_SERVICE_ACCOUNT_JSON or os.environ.get("FIREBASE_SERVICE_ACCOUNT_JSON") or os.environ.get("FIREBASE_CREDENTIALS_JSON")
        if service_account_raw:
            import json
            cred_dict = json.loads(service_account_raw)
            cred = credentials.Certificate(cred_dict)
            firebase_admin.initialize_app(cred, {
                "projectId": settings.FIREBASE_PROJECT_ID,
            })
            _db_client = firestore.client()
            logger.info("Firebase Admin SDK initialized using environment variable JSON credentials")
            _firebase_initialized = True
        elif cred_path and os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred, {
                "projectId": settings.FIREBASE_PROJECT_ID,
            })
            _db_client = firestore.client()
            logger.info(f"Firebase Admin SDK initialized with certificate: {cred_path}")
            _firebase_initialized = True
        elif os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
            firebase_admin.initialize_app()
            _db_client = firestore.client()
            logger.info("Firebase Admin SDK initialized using GOOGLE_APPLICATION_CREDENTIALS")
            _firebase_initialized = True
        else:
            logger.warning("No Firebase service account key found. Using memory-backed Firestore fallback for development.")
            _db_client = _in_memory_db
            _firebase_initialized = True
    except Exception as e:
        logger.warning(f"Firebase Admin initialization fallback: {e}. Using memory-backed Firestore.")
        _db_client = _in_memory_db
        _firebase_initialized = True

def get_db():
    global _db_client
    if not _firebase_initialized or _db_client is None:
        init_firebase_admin()
    return _db_client

def send_fcm_message(fcm_token: Optional[str], title: str, body: str, data: Dict[str, str]) -> bool:
    if not fcm_token:
        logger.info(f"[Mock FCM] No token registered. Skipping push notification: {title} - {body}")
        return False

    try:
        from firebase_admin import messaging
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            android=messaging.AndroidConfig(
                priority="high",
                notification=messaging.AndroidNotification(
                    channel_id="emergency_alerts",
                    priority="max",
                    default_sound=True,
                    default_vibrate_timings=True,
                ),
            ),
            data=data,
            token=fcm_token,
        )
        response = messaging.send(message)
        logger.info(f"FCM notification sent successfully: {response}")
        return True
    except Exception as e:
        logger.warning(f"[Mock FCM] Simulated push notification to {fcm_token}: {title} | Error: {e}")
        return False
