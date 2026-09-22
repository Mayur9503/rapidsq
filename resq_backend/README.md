# ResQ Emergency Dispatch — Real FastAPI Backend

College/Demo Emergency Ambulance Dispatch Backend for ResQ.

## Architecture

```text
USER PHONE (Flutter)
       ↓  POST /api/incidents
FASTAPI BACKEND
   ├── Verifies Auth ID Token (or dev bypass)
   ├── Writes Incident to Cloud Firestore (`emergencies/{id}`)
   ├── Updates Single Ambulance Status (`ambulances/main`)
   └── Sends Silent FCM Push Alert to Ambulance Device
       ↓
AMBULANCE PHONE (Flutter)
   ├── Driver reviews alert & GPS
   ├── Clicks "ACCEPT DISPATCH" (POST /api/incidents/{id}/respond)
   ├── Clicks "NAVIGATE TO PATIENT" (Launches native device navigation via geo: URI)
   └── Streams GPS updates (POST /api/ambulances/main/location)
```

> **Design Constraints Met:**
> * Single ambulance model (`ambulances/main`).
> * ZERO paid Map APIs (Google Maps API, Google Routes API, OSRM are NOT used or required).
> * Native turn-by-turn navigation is launched directly via external device GPS URI (`geo:lat,lng` / Google Maps web fallback).
> * Fully tested with unit/integration tests (`pytest`).

---

## 1. Installation & Environment Setup

### Prerequisites
* Python 3.10+
* (Optional) Firebase Service Account JSON file (e.g. `serviceAccountKey.json`)

### Install Dependencies
```bash
cd resq_backend
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate

pip install -r requirements.txt
```

### Configure Environment Variables
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

Contents of `.env`:
```env
PROJECT_NAME="ResQ Emergency Backend"
VERSION="1.0.0"
API_V1_STR="/api"
PORT=8000
HOST="0.0.0.0"

# Firebase Project Settings
FIREBASE_PROJECT_ID="rapidsq-firebase"
# Path to service account key json (optional in development / mock mode)
FIREBASE_CREDENTIALS_PATH=""

# Ambulance Configuration
AMBULANCE_DOCUMENT_ID="main"

# In dev/demo mode, set to true to allow dev-test tokens
ALLOW_DEV_TOKEN_AUTH=true
```

---

## 2. Running the Backend

Start the FastAPI server on port 8000:
```bash
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Once started:
* **Interactive API Documentation (Swagger UI):** [http://localhost:8000/docs](http://localhost:8000/docs)
* **Alternative API Docs (ReDoc):** [http://localhost:8000/redoc](http://localhost:8000/redoc)
* **Health Check:** [http://localhost:8000/health](http://localhost:8000/health)

---

## 3. API Endpoints Reference

### Incidents
* **`POST /api/incidents`**
  Creates an emergency incident and triggers ambulance dispatch.
  * Headers: `Authorization: Bearer <ID_TOKEN>`
  * Request Body:
    ```json
    {
      "latitude": 28.6280,
      "longitude": 77.3649,
      "description": "Severe chest pain",
      "category": "selfSOS",
      "locationTitle": "Sector 62, Noida"
    }
    ```
  * Response: `201 Created` with incident ID and assigned ambulance details.

* **`POST /api/incidents/{incident_id}/respond`**
  Driver responds to an offered emergency.
  * Headers: `Authorization: Bearer <ID_TOKEN>`
  * Request Body:
    ```json
    {
      "response": "ACCEPT"
    }
    ```
    *(Options: `"ACCEPT"` or `"REJECT"`)*

* **`GET /api/incidents/{incident_id}`**
  Fetches status and details of an active incident.

### Ambulance Status & Telemetry
* **`POST /api/ambulances/main/location`**
  Updates the real-time GPS location of the demo ambulance unit.
  * Request Body:
    ```json
    {
      "latitude": 28.6340,
      "longitude": 77.3710
    }
    ```

* **`GET /api/ambulances/main`**
  Returns current status (`AVAILABLE`, `OFFERED`, `BUSY`) and GPS telemetry.

### Device FCM Tokens
* **`POST /api/devices/fcm-token`**
  Registers the ambulance phone's FCM token for push dispatch notifications.
  * Request Body:
    ```json
    {
      "fcmToken": "c1x4...",
      "deviceType": "ambulance"
    }
    ```

---

## 4. Running Tests

Run the automated pytest test suite:
```bash
python -m pytest tests/test_api.py -v
```
All 8 test cases validate:
1. Health check endpoint.
2. Incident creation with valid GPS coordinates.
3. Coordinate boundary validation (-90 to 90 lat, -180 to 180 lng).
4. Driver acceptance workflow and state transition to `BUSY`.
5. Driver rejection workflow and state transition to `AVAILABLE`.
6. Unauthorized / invalid response rejection.
7. Ambulance live GPS coordinate telemetry updates.
8. FCM registration payload validation.

---

## 5. Two-Phone College Demo Testing Walkthrough

To demo the project with **Phone 1 (User)** and **Phone 2 (Ambulance)**:

1. **Start FastAPI Backend:**
   Run `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000` on your PC. Note your PC's local LAN IP (e.g. `192.168.1.15`).
2. **Launch Flutter App on Both Devices:**
   * In `resq_app`, point `baseUrl` in `fastapi_backend_service.dart` or via Dev Control Bar to `http://<your-pc-ip>:8000`.
3. **Setup Phone 2 (Ambulance Phone):**
   * Open the app on Phone 2.
   * Go to **Profile** > Tap **"Ambulance Driver Terminal"** (or use the Dev Control Bar > **"DRIVER TERMINAL"**).
   * Status displays **`AVAILABLE`** and **`STANDBY • READY FOR DISPATCH`**.
4. **Trigger Emergency on Phone 1 (User Phone):**
   * On Phone 1, tap or hold the red **SOS** button.
   * User phone creates an incident via `POST /api/incidents`.
5. **Receive & Respond on Phone 2 (Ambulance Phone):**
   * Ambulance phone status transitions to **`OFFERED`** and displays **`INCOMING EMERGENCY OFFER`** with patient GPS coordinates.
   * Driver taps **"ACCEPT DISPATCH"**.
   * Ambulance status transitions to **`BUSY`** (`ACTIVE EMERGENCY DISPATCH`).
   * Driver taps **"NAVIGATE TO PATIENT (EXTERNAL GPS)"** — opens the native Google Maps / Apple Maps app directly to the patient's coordinates without needing any paid APIs!
   * Driver taps **"Send GPS Ping"** to simulate moving closer to patient.
   * Once arrived and assisted, driver taps **"MARK PATIENT ONBOARD & COMPLETE"** to return the ambulance to `AVAILABLE`.
