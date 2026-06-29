from sqlalchemy.orm import Session
from app.events.base import Event

def dispatch_event(db: Session, entity_type: str, entity_id: str, event_type: str, payload: dict) -> Event:
    db_event = Event(
        entity_type=entity_type,
        entity_id=str(entity_id),
        event_type=event_type,
        payload=payload
    )
    db.add(db_event)
    db.commit()
    db.refresh(db_event)
    return db_event
