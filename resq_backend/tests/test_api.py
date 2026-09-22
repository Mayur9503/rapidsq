import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

AUTH_HEADER = {"Authorization": "Bearer dev-test-token"}
DRIVER_HEADER = {"Authorization": "Bearer driver-token"}

# 1. Health endpoint
def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "HEALTHY"
    assert "singleAmbulanceId" in data

# 2. Valid incident creation
def test_create_incident_valid():
    payload = {
        "latitude": 28.6280,
        "longitude": 77.3649,
        "description": "Severe respiratory distress",
        "category": "cardiac",
        "locationTitle": "Sector 62, Noida",
    }
    response = client.post("/api/incidents", json=payload, headers=AUTH_HEADER)
    assert response.status_code == 201
    data = response.json()
    assert data["status"] == "OFFERED"
    assert data["incidentId"].startswith("RQ-")
    assert data["userId"] == "dev-test-uid"
    assert data["latitude"] == 28.6280
    assert data["longitude"] == 77.3649
    assert "offerExpiresAt" in data
    assert data["acceptanceTimeoutSeconds"] == 6

# 3. Invalid GPS coordinates rejected
def test_create_incident_invalid_coordinates():
    # Latitude > 90
    payload_bad_lat = {
        "latitude": 125.0,
        "longitude": 77.3649,
    }
    res1 = client.post("/api/incidents", json=payload_bad_lat, headers=AUTH_HEADER)
    assert res1.status_code == 422

    # Longitude > 180
    payload_bad_lng = {
        "latitude": 28.6280,
        "longitude": 200.0,
    }
    res2 = client.post("/api/incidents", json=payload_bad_lng, headers=AUTH_HEADER)
    assert res2.status_code == 422

# 4. Ambulance accept within 6 seconds
def test_ambulance_accept():
    # Create incident first
    res_create = client.post("/api/incidents", json={"latitude": 28.6280, "longitude": 77.3649}, headers=AUTH_HEADER)
    incident_id = res_create.json()["incidentId"]

    # Driver accepts immediately
    res_respond = client.post(
        f"/api/incidents/{incident_id}/respond",
        json={"response": "ACCEPT"},
        headers=DRIVER_HEADER,
    )
    assert res_respond.status_code == 200
    data = res_respond.json()
    assert data["status"] == "ASSIGNED"
    assert data["action"] == "ACCEPT"
    assert data["ambulanceId"] == "main"

# 5. Ambulance reject -> WAITING_FOR_RESPONDER
def test_ambulance_reject():
    # Create incident first
    res_create = client.post("/api/incidents", json={"latitude": 28.6280, "longitude": 77.3649}, headers=AUTH_HEADER)
    incident_id = res_create.json()["incidentId"]

    # Driver rejects
    res_respond = client.post(
        f"/api/incidents/{incident_id}/respond",
        json={"response": "REJECT"},
        headers=DRIVER_HEADER,
    )
    assert res_respond.status_code == 200
    data = res_respond.json()
    assert data["status"] == "WAITING_FOR_RESPONDER"
    assert data["action"] == "REJECT"

# 6. Unauthorized action rejected (No auth header -> 401)
def test_unauthorized_action_rejected():
    # No Authorization header
    response = client.post(
        "/api/incidents/RQ-TEST/respond",
        json={"response": "ACCEPT"},
    )
    assert response.status_code == 401
    assert "Authorization header missing" in response.json()["detail"]

# 6b. Unauthorized rider cannot accept (Different user UID -> 403)
def test_unauthorized_rider_cannot_accept():
    # Create an incident
    res_create = client.post("/api/incidents", json={"latitude": 28.6280, "longitude": 77.3649}, headers=AUTH_HEADER)
    incident_id = res_create.json()["incidentId"]

    # Attempt to accept with an unauthorized rider token (dev-user:imposter)
    imposter_header = {"Authorization": "Bearer dev-user:imposter"}
    response = client.post(
        f"/api/incidents/{incident_id}/respond",
        json={"response": "ACCEPT"},
        headers=imposter_header,
    )
    assert response.status_code == 403
    assert "Only the registered rider" in response.json()["detail"]

# 7. Ambulance location update
def test_ambulance_location_update():
    payload = {
        "latitude": 28.6300,
        "longitude": 77.3680,
    }
    response = client.post("/api/ambulances/main/location", json=payload, headers=DRIVER_HEADER)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "OK"
    assert data["latitude"] == 28.6300
    assert data["longitude"] == 77.3680

# 8. FCM token registration validation and riderUid binding
def test_fcm_token_registration_validation():
    # Valid token
    valid_payload = {"fcmToken": "mock-fcm-device-token-1234567890", "deviceType": "ambulance"}
    res_valid = client.post("/api/devices/fcm-token", json=valid_payload, headers=DRIVER_HEADER)
    assert res_valid.status_code == 200
    assert res_valid.json()["ambulanceId"] == "main"
    assert res_valid.json()["riderUid"] == "driver-default"

    # Token too short (< 10 chars)
    invalid_payload = {"fcmToken": "short", "deviceType": "ambulance"}
    res_invalid = client.post("/api/devices/fcm-token", json=invalid_payload, headers=DRIVER_HEADER)
    assert res_invalid.status_code == 422

# 9. Women safety incident creation
def test_create_women_safety_incident():
    payload = {
        "latitude": 28.6295,
        "longitude": 77.3660,
        "serviceType": "women_safety",
        "description": "Suspicious pursuit reported - Need immediate patrol assistance",
        "priority": "CRITICAL",
        "locationTitle": "Near Metro Gate 2",
    }
    response = client.post("/api/incidents", json=payload, headers=AUTH_HEADER)
    assert response.status_code == 201
    data = response.json()
    assert data["status"] == "OFFERED"
    assert data["serviceType"] == "women_safety"
    assert data["priority"] == "CRITICAL"
    assert data["incidentId"].startswith("RQ-")

# 10. Fire brigade incident creation with fire subtype
def test_create_fire_brigade_incident():
    payload = {
        "latitude": 28.6310,
        "longitude": 77.3690,
        "serviceType": "fire_brigade",
        "description": "Building fire - Floor 3 commercial complex",
        "priority": "HIGH",
        "locationTitle": "Tech Zone Tower B",
    }
    response = client.post("/api/incidents", json=payload, headers=AUTH_HEADER)
    assert response.status_code == 201
    data = response.json()
    assert data["status"] == "OFFERED"
    assert data["serviceType"] == "fire_brigade"
    assert data["priority"] == "HIGH"
    assert data["incidentId"].startswith("RQ-")

# 11. Invalid serviceType rejected
def test_invalid_service_type_rejected():
    payload = {
        "latitude": 28.6280,
        "longitude": 77.3649,
        "serviceType": "military_defense", # Invalid service type
    }
    response = client.post("/api/incidents", json=payload, headers=AUTH_HEADER)
    assert response.status_code == 422

# 12. Acceptance after 6-second expiration rejected with 409 Conflict
def test_accept_after_expiry_rejected():
    from app.firebase import get_db
    from datetime import datetime, timezone, timedelta
    
    # Create incident
    res_create = client.post("/api/incidents", json={"latitude": 28.6280, "longitude": 77.3649}, headers=AUTH_HEADER)
    incident_id = res_create.json()["incidentId"]
    
    # Manually expire the offer in Firestore by setting offerExpiresAt to 10 seconds ago
    db = get_db()
    past_ts = (datetime.now(timezone.utc) - timedelta(seconds=10)).isoformat()
    db.collection("emergencies").document(incident_id).update({"offerExpiresAt": past_ts})
    
    # Attempt to accept expired offer
    res_respond = client.post(
        f"/api/incidents/{incident_id}/respond",
        json={"response": "ACCEPT"},
        headers=DRIVER_HEADER,
    )
    assert res_respond.status_code == 409
    assert "expired" in res_respond.json()["detail"].lower()
