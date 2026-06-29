from fastapi import APIRouter
from app.api.v1 import auth, health, animals, dairy, breeding, poultry, hatchery, finance, alerts, inventory, tasks, imports

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(health.router, prefix="/health", tags=["health"])
api_router.include_router(animals.router, prefix="/animals", tags=["animals"])
api_router.include_router(dairy.router, prefix="/dairy", tags=["dairy"])
api_router.include_router(breeding.router, prefix="/breeding", tags=["breeding"])
api_router.include_router(poultry.router, prefix="/poultry", tags=["poultry"])
api_router.include_router(hatchery.router, prefix="/hatchery", tags=["hatchery"])
api_router.include_router(finance.router, prefix="/finance", tags=["finance"])
api_router.include_router(alerts.router, prefix="/alerts", tags=["alerts"])
api_router.include_router(inventory.router, prefix="/inventory", tags=["inventory"])
api_router.include_router(tasks.router, prefix="/tasks", tags=["tasks"])
api_router.include_router(imports.router, prefix="/import", tags=["import"])
