import os
from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse

router = APIRouter()

# Current backend-reported latest version
LATEST_VERSION = "2.3.0+23"
APK_PATH = r"C:\Users\USER\Desktop\farm_works\mobile\build\app\outputs\flutter-apk\app-release.apk"

@router.get("/version")
def get_latest_version():
    return {
        "version": LATEST_VERSION,
        "release_notes": "Cloud sync improvements and new features.",
        "download_url": "/api/v1/system/download-apk"
    }

@router.get("/download-apk")
def download_apk():
    if not os.path.exists(APK_PATH):
        raise HTTPException(status_code=404, detail="Latest APK not found on server.")
    return FileResponse(
        path=APK_PATH,
        media_type='application/vnd.android.package-archive',
        filename="Namanzo IFMS.apk"
    )
