from sqlalchemy.orm import Session
from . import database, schemas
import hashlib
from typing import List, Optional

def verify_password(plain_password, hashed_password):
    """Parolni tekshirish - oddiy hash usuli"""
    return get_password_hash(plain_password) == hashed_password

def get_password_hash(password):
    """Parolni hash qilish - oddiy SHA-256"""
    return hashlib.sha256(password.encode()).hexdigest()

# Admin CRUD
def get_admin_by_username(db: Session, username: str):
    return db.query(database.Admin).filter(database.Admin.username == username).first()

def create_admin(db: Session, admin: schemas.AdminCreate):
    hashed_password = get_password_hash(admin.password)
    db_admin = database.Admin(username=admin.username, hashed_password=hashed_password)
    db.add(db_admin)
    db.commit()
    db.refresh(db_admin)
    return db_admin

def authenticate_admin(db: Session, username: str, password: str):
    admin = get_admin_by_username(db, username)
    if not admin:
        return False
    if not verify_password(password, admin.hashed_password):
        return False
    return admin

# Category CRUD
def get_categories(db: Session, skip: int = 0, limit: int = 100):
    return db.query(database.Category).offset(skip).limit(limit).all()

def get_category(db: Session, category_id: int):
    return db.query(database.Category).filter(database.Category.id == category_id).first()

def create_category(db: Session, category: schemas.CategoryCreate):
    db_category = database.Category(**category.dict())
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return db_category

def update_category(db: Session, category_id: int, category: schemas.CategoryUpdate):
    db_category = db.query(database.Category).filter(database.Category.id == category_id).first()
    if db_category:
        for key, value in category.dict().items():
            setattr(db_category, key, value)
        db.commit()
        db.refresh(db_category)
    return db_category

def delete_category(db: Session, category_id: int):
    db_category = db.query(database.Category).filter(database.Category.id == category_id).first()
    if db_category:
        db.delete(db_category)
        db.commit()
    return db_category

# Item CRUD
def get_items(db: Session, skip: int = 0, limit: int = 100, category_id: Optional[int] = None):
    query = db.query(database.Item)
    if category_id:
        query = query.filter(database.Item.category_id == category_id)
    return query.offset(skip).limit(limit).all()

def get_item(db: Session, item_id: int):
    return db.query(database.Item).filter(database.Item.id == item_id).first()

def create_item(db: Session, item: schemas.ItemCreate):
    db_item = database.Item(**item.dict())
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item

def update_item(db: Session, item_id: int, item: schemas.ItemUpdate):
    db_item = db.query(database.Item).filter(database.Item.id == item_id).first()
    if db_item:
        for key, value in item.dict().items():
            setattr(db_item, key, value)
        db.commit()
        db.refresh(db_item)
    return db_item

def delete_item(db: Session, item_id: int):
    db_item = db.query(database.Item).filter(database.Item.id == item_id).first()
    if db_item:
        db.delete(db_item)
        db.commit()
    return db_item

def search_items(db: Session, query: str):
    return db.query(database.Item).filter(
        database.Item.name.contains(query) | 
        database.Item.description.contains(query)
    ).all()