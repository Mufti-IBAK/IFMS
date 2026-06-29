from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from pydantic import BaseModel
import jwt
import uuid

from app.core.database import get_db
from app.core.config import settings
from app.schemas.user import UserCreate, UserResponse, Token
from app.services.auth_service import (
    create_user,
    authenticate_user,
    get_current_active_user,
    get_user_by_id
)
from app.core.security import create_access_token, create_refresh_token
from app.models.user import User
from app.models.device import DeviceToken

router = APIRouter()

class RefreshTokenRequest(BaseModel):
    refresh_token: str

class FCMTokenRequest(BaseModel):
    token: str

@router.post("/fcm-token")
def register_fcm_token(
    payload: FCMTokenRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Upsert token
    token_entry = db.query(DeviceToken).filter(DeviceToken.fcm_token == payload.token).first()
    if token_entry:
        token_entry.user_id = current_user.id
    else:
        token_entry = DeviceToken(
            id=uuid.uuid4(),
            user_id=current_user.id,
            fcm_token=payload.token
        )
        db.add(token_entry)

    db.commit()
    return {"status": "success"}

@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    return create_user(db, user_in)

@router.post("/login", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = authenticate_user(db, phone=form_data.username, password=form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect phone number or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token = create_access_token(data={"sub": str(user.id), "role": user.role.value})
    refresh_token = create_refresh_token(data={"sub": str(user.id)})
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post("/refresh", response_model=Token)
def refresh_token_endpoint(payload: RefreshTokenRequest, db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate refresh token",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        jwt_payload = jwt.decode(payload.refresh_token, settings.SECRET_KEY, algorithms=["HS256"])
        user_id_str: str = jwt_payload.get("sub")
        if user_id_str is None:
            raise credentials_exception
        user_id = uuid.UUID(user_id_str)
    except (jwt.PyJWTError, ValueError):
        raise credentials_exception
        
    user = get_user_by_id(db, user_id)
    if user is None or not user.is_active:
        raise credentials_exception
        
    new_access_token = create_access_token(data={"sub": str(user.id), "role": user.role.value})
    new_refresh_token = create_refresh_token(data={"sub": str(user.id)})
    return {
        "access_token": new_access_token,
        "refresh_token": new_refresh_token,
        "token_type": "bearer"
    }

@router.get("/me", response_model=UserResponse)
def read_users_me(current_user: User = Depends(get_current_active_user)):
    return current_user
