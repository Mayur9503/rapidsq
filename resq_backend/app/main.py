from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.firebase import init_firebase_admin
from app.routes import incidents, ambulance, devices

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    init_firebase_admin()
    yield
    # Shutdown

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="FastAPI Backend for ResQ Emergency Ambulance Dispatch College Demo",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS Middleware to support Flutter web, emulator, and local device IP connections
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API Routers
app.include_router(incidents.router)
app.include_router(ambulance.router)
app.include_router(devices.router)

@app.get("/health", tags=["system"])
@app.get("/", tags=["system"])
async def health_check():
    return {
        "status": "HEALTHY",
        "service": settings.PROJECT_NAME,
        "environment": settings.ENVIRONMENT,
        "singleAmbulanceId": settings.AMBULANCE_DOCUMENT_ID,
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host=settings.HOST, port=settings.PORT, reload=True)
