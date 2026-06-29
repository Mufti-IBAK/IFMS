import firebase_admin
from firebase_admin import credentials, messaging
import os
from typing import List, Optional

# Path to your Firebase Service Account JSON
# You can download this from Firebase Console -> Project Settings -> Service Accounts
FIREBASE_CREDENTIALS_PATH = "firebase-adminsdk.json"

if os.path.exists(FIREBASE_CREDENTIALS_PATH):
    cred = credentials.Certificate(FIREBASE_CREDENTIALS_PATH)
    firebase_admin.initialize_app(cred)
    _firebase_initialized = True
else:
    print(f"Warning: {FIREBASE_CREDENTIALS_PATH} not found. Push notifications will be disabled.")
    _firebase_initialized = False

def send_push_notification(token: str, title: str, body: str, data: Optional[dict] = None):
    """Sends a push notification to a single device."""
    if not _firebase_initialized:
        return

    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},
        token=token,
    )

    try:
        response = messaging.send(message)
        print(f"Successfully sent message: {response}")
    except Exception as e:
        print(f"Error sending push notification: {e}")

def send_multicast_notification(tokens: List[str], title: str, body: str, data: Optional[dict] = None):
    """Sends a push notification to multiple devices."""
    if not _firebase_initialized or not tokens:
        return

    message = messaging.MulticastMessage(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},
        tokens=tokens,
    )

    try:
        response = messaging.send_multicast(message)
        print(f"{response.success_count} messages were sent successfully")
    except Exception as e:
        print(f"Error sending multicast notification: {e}")


class NotificationService:
    def send_notification(self, channel_name: str, recipient: str, title: str, body: str) -> bool:
        if channel_name in ["whatsapp", "sms"]:
            return True
        return False

notification_service = NotificationService()
