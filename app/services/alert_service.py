import math
from datetime import date, datetime, timedelta
from uuid import UUID
from typing import Optional, List, Dict, Any
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.services import dairy_service, finance_service, notification_service
from app.models.device import DeviceToken
from app.models.user import User
from app.core.roles import UserRole
from app.models.rule import Rule
from app.models.alert import Alert
from app.models.animal import Animal, AnimalSpecies, AnimalStatus
from app.models.poultry_batch import PoultryBatch
from app.models.hatchery_batch import HatcheryBatch
from app.models.milk_record import MilkRecord
from app.models.animal_event import AnimalEvent
from app.schemas.alert import RuleCreate

def calculate_std_dev(values: List[float]) -> tuple:
    if len(values) < 2:
        return 0.0, 0.0
    mean = sum(values) / len(values)
    variance = sum((x - mean) ** 2 for x in values) / (len(values) - 1)
    std_dev = math.sqrt(variance)
    return mean, std_dev

def create_rule(db: Session, rule_in: RuleCreate) -> Rule:
    db_rule = Rule(
        name=rule_in.name,
        entity_type=rule_in.entity_type,
        condition_json=rule_in.condition_json,
        severity=rule_in.severity,
        action_type=rule_in.action_type,
        active=rule_in.active
    )
    db.add(db_rule)
    db.commit()
    db.refresh(db_rule)
    return db_rule

def get_rules(db: Session) -> List[Rule]:
    return db.query(Rule).all()

def get_alerts(
    db: Session,
    severity: Optional[str] = None,
    status_filter: Optional[str] = None,
    entity_type: Optional[str] = None
) -> List[Alert]:
    query = db.query(Alert)
    if severity:
        query = query.filter(Alert.severity == severity)
    if status_filter:
        query = query.filter(Alert.status == status_filter)
    if entity_type:
        query = query.filter(Alert.entity_type == entity_type)
    return query.order_by(Alert.created_at.desc()).all()

def resolve_alert(db: Session, alert_id: UUID) -> Alert:
    alert = db.query(Alert).filter(Alert.id == alert_id).first()
    if not alert:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Alert not found."
        )
    alert.status = "resolved"
    alert.resolved_at = datetime.utcnow()
    db.commit()
    db.refresh(alert)
    return alert

def trigger_alert_if_new(
    db: Session,
    entity_type: str,
    entity_id: Optional[UUID],
    alert_type: str,
    severity: str,
    message: str
) -> Optional[Alert]:
    # Check if an open alert of the same type already exists
    existing = db.query(Alert).filter(
        Alert.entity_type == entity_type,
        Alert.entity_id == entity_id,
        Alert.alert_type == alert_type,
        Alert.severity == severity,
        Alert.status == "open"
    ).first()
    
    if existing:
        return None
        
    db_alert = Alert(
        entity_type=entity_type,
        entity_id=entity_id,
        alert_type=alert_type,
        severity=severity,
        message=message,
        status="open"
    )
    db.add(db_alert)
    db.commit()
    db.refresh(db_alert)

    # Push Notification Logic
    if severity in ["high", "critical"]:
        # Find all Owners and Managers
        target_users = db.query(User).filter(User.role.in_([UserRole.OWNER, UserRole.MANAGER])).all()
        user_ids = [u.id for u in target_users]

        # Get their device tokens
        tokens = db.query(DeviceToken.fcm_token).filter(DeviceToken.user_id.in_(user_ids)).all()
        token_list = [t[0] for t in tokens]

        if token_list:
            notification_service.send_multicast_notification(
                tokens=token_list,
                title=f"🚨 {severity.upper()} ALERT: {alert_type.replace('_', ' ').title()}",
                body=message,
                data={"alert_id": str(db_alert.id), "type": "alert"}
            )

    return db_alert

def evaluate_all_alerts(db: Session, reference_date: Optional[date] = None) -> List[Alert]:
    if not reference_date:
        reference_date = date.today()
        
    triggered_alerts = []
    
    # 1. Evaluate Dairy Rules: Milk Drop and Anomaly
    active_cows = db.query(Animal).filter(
        Animal.status == AnimalStatus.ACTIVE,
        Animal.species == AnimalSpecies.COW,
        Animal.sex == "female"
    ).all()
    
    for cow in active_cows:
        # A. Deterministic Milk Drop
        try:
            kpi = dairy_service.get_animal_dairy_kpis(db, cow.id, reference_date)
            if kpi.get("alerts", {}).get("milk_drop_detected"):
                # Retrieve actual values
                record = db.query(MilkRecord).filter(
                    MilkRecord.animal_id == cow.id,
                    MilkRecord.record_date == reference_date
                ).first()
                if record:
                    avg_7d = kpi.get("rolling_average_7d", 0.0)
                    msg = f"Milk drop detected for cow {cow.tag_id}: Today's yield {record.quantity_liters}L is below 20% drop from 7-day average ({avg_7d:.2f}L)."
                    alert = trigger_alert_if_new(db, "animal", cow.id, "production_alert", "medium", msg)
                    if alert:
                        triggered_alerts.append(alert)
        except Exception:
            pass
            
        # B. Statistical Standard Deviation Anomaly
        # Fetch last 14 completed daily records
        history_records = db.query(MilkRecord).filter(
            MilkRecord.animal_id == cow.id,
            MilkRecord.record_date < reference_date
        ).order_by(MilkRecord.record_date.desc()).limit(14).all()
        
        if len(history_records) >= 5:
            yields = [r.quantity_liters for r in history_records]
            mean, std_dev = calculate_std_dev(yields)
            
            # Fetch today's record
            today_record = db.query(MilkRecord).filter(
                MilkRecord.animal_id == cow.id,
                MilkRecord.record_date == reference_date
            ).first()
            
            if today_record and std_dev > 0.1:
                threshold = mean - (2 * std_dev)
                if today_record.quantity_liters < threshold:
                    msg = f"Statistical Anomaly: Cow {cow.tag_id} milk yield ({today_record.quantity_liters}L) is more than 2 std dev below mean ({mean:.2f}L, std dev {std_dev:.2f}L)."
                    alert = trigger_alert_if_new(db, "animal", cow.id, "production_alert", "high", msg)
                    if alert:
                        triggered_alerts.append(alert)
                        
    # 2. Evaluate Chronic Illness: Treatment Count > 2 in last 7 days
    seven_days_ago = reference_date - timedelta(days=7)
    for animal in db.query(Animal).filter(Animal.status == AnimalStatus.ACTIVE).all():
        treatments_count = db.query(AnimalEvent).filter(
            AnimalEvent.animal_id == animal.id,
            AnimalEvent.event_type.ilike("%treatment%"),
            AnimalEvent.event_timestamp >= datetime.combine(seven_days_ago, datetime.min.time()),
            AnimalEvent.event_timestamp <= datetime.combine(reference_date, datetime.max.time())
        ).count()
        
        if treatments_count > 2:
            msg = f"Chronic Illness Risk: Animal {animal.tag_id} had {treatments_count} treatments in the last 7 days."
            alert = trigger_alert_if_new(db, "animal", animal.id, "health_alert", "medium", msg)
            if alert:
                triggered_alerts.append(alert)
                
    # 3. Evaluate Poultry Rule: Mortality spike > 2% in 24h
    active_poultry = db.query(PoultryBatch).filter(PoultryBatch.status == "active").all()
    for batch in active_poultry:
        from app.models.poultry_event import PoultryEvent
        mortality_today = db.query(func.sum(PoultryEvent.quantity)).filter(
            PoultryEvent.batch_id == batch.id,
            PoultryEvent.event_type == "mortality",
            PoultryEvent.event_date == reference_date
        ).scalar() or 0.0
        
        if batch.initial_count > 0:
            rate_today = (mortality_today / batch.initial_count) * 100.0
            if rate_today > 2.0:
                msg = f"Poultry Mortality Spike: Batch {batch.breed} (ID: {batch.id}) mortality today is {rate_today:.2f}% (exceeds critical 2.0% threshold)."
                alert = trigger_alert_if_new(db, "poultry_batch", batch.id, "health_alert", "critical", msg)
                if alert:
                    triggered_alerts.append(alert)
                    
    # 4. Evaluate Financial loss detection: 30-day net loss
    # Evaluate animals
    for animal in db.query(Animal).filter(Animal.status == AnimalStatus.ACTIVE).all():
        try:
            fin = finance_service.get_animal_financial_summary(db, animal.id, reference_date)
            # Fetch last 30 days transactions for net profit calculation
            thirty_days_ago = reference_date - timedelta(days=30)
            from app.models.transaction import Transaction
            direct_txns = db.query(Transaction).filter(
                Transaction.related_entity_type == "animal",
                Transaction.related_entity_id == animal.id,
                Transaction.transaction_date >= thirty_days_ago,
                Transaction.transaction_date <= reference_date
            ).all()
            
            rev_30d = sum(t.amount for t in direct_txns if t.transaction_type == "income")
            cost_30d = sum(t.amount for t in direct_txns if t.transaction_type == "expense")
            
            # Simple direct 30-day trailing check
            net_30d = rev_30d - cost_30d
            if net_30d < 0.0 and cost_30d > 0.0:
                msg = f"Consistent Loss Detected: Animal {animal.tag_id} is running at a trailing net loss of {net_30d:.2f} NGN over the last 30 days."
                alert = trigger_alert_if_new(db, "animal", animal.id, "financial_alert", "medium", msg)
                if alert:
                    triggered_alerts.append(alert)
        except Exception:
            pass
            
    return triggered_alerts

def get_optimization_insights(db: Session) -> List[Dict[str, Any]]:
    # Fetch all open alerts
    open_alerts = db.query(Alert).filter(Alert.status == "open").all()
    
    recommendations = []
    for alert in open_alerts:
        entity_name = "System"
        if alert.entity_id:
            if alert.entity_type == "animal":
                ent = db.query(Animal).filter(Animal.id == alert.entity_id).first()
                entity_name = ent.tag_id if ent else str(alert.entity_id)
            elif alert.entity_type == "poultry_batch":
                ent = db.query(PoultryBatch).filter(PoultryBatch.id == alert.entity_id).first()
                entity_name = f"Poultry Batch {ent.breed}" if ent else str(alert.entity_id)
            elif alert.entity_type == "hatchery_batch":
                ent = db.query(HatcheryBatch).filter(HatcheryBatch.id == alert.entity_id).first()
                entity_name = f"Hatchery cohort {ent.breed}" if ent else str(alert.entity_id)
                
        recs = []
        if alert.alert_type == "production_alert":
            recs = [
                "Isolate the animal to assess individual feed and water consumption.",
                "Perform a physical check on the udders for swelling, redness, or heat.",
                "Review daily feed quality and check for somatic cell count markers."
            ]
        elif alert.alert_type == "health_alert":
            if alert.severity == "critical":
                recs = [
                    "Immediately increase biosecurity protocols and restrict access to the coop.",
                    "Verify the poultry water line pressure and check feed for contamination.",
                    "Isolate the affected batch and consult the chief veterinarian immediately."
                ]
            else:
                recs = [
                    "Check treatment records and review the animal's vaccine cards.",
                    "Conduct a comprehensive diagnostic screen.",
                    "Move the animal to the quarantine pen if contagion is suspected."
                ]
        elif alert.alert_type == "financial_alert":
            recs = [
                "Review the culling board for animal productivity ranking.",
                "Analyze feed-to-production efficiency and feed costs.",
                "Adjust overhead cost allocation markers or consider selling underperforming stock."
            ]
        else:
            recs = ["Monitor entity metrics and consult the farm manager."]
            
        recommendations.append({
            "alert_id": alert.id,
            "entity": entity_name,
            "issue": alert.message,
            "severity": alert.severity,
            "recommendations": recs
        })
        
    return recommendations
