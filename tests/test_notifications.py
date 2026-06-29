import pytest
from app.services.notification_service import notification_service

def test_notification_channels():
    # Test sending WhatsApp notification
    success = notification_service.send_notification(
        channel_name="whatsapp",
        recipient="+2348011112222",
        title="Mastitis Warning",
        body="Cow COW-002 has high risk of mastitis."
    )
    assert success is True

    # Test sending SMS notification
    success_sms = notification_service.send_notification(
        channel_name="sms",
        recipient="+2348011112222",
        title="Stock Warning",
        body="Dairy Feed Pellets below threshold."
    )
    assert success_sms is True

    # Test invalid channel
    success_invalid = notification_service.send_notification(
        channel_name="telepathy",
        recipient="+2348011112222",
        title="Hello",
        body="World"
    )
    assert success_invalid is False
