from enum import Enum

class UserRole(str, Enum):
    OWNER = "owner"
    VET = "vet"
    MANAGER = "manager"
    WORKER = "worker"
    PHARMACIST = "pharmacist"
