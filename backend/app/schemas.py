from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class AdminBase(BaseModel):
    username: str

class AdminCreate(AdminBase):
    password: str

class Admin(AdminBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True

class CategoryBase(BaseModel):
    name: str
    description: Optional[str] = None

class CategoryCreate(CategoryBase):
    pass

class CategoryUpdate(CategoryBase):
    pass

class Category(CategoryBase):
    id: int
    created_at: datetime
    items: List["Item"] = []
    
    class Config:
        from_attributes = True

class ItemBase(BaseModel):
    name: str
    price: float
    description: str
    duration: str
    min_sessions: int
    max_sessions: int
    image_url: Optional[str] = None
    category_id: int

class ItemCreate(ItemBase):
    pass

class ItemUpdate(ItemBase):
    pass

class Item(ItemBase):
    id: int
    created_at: datetime
    category: Optional[Category] = None
    
    class Config:
        from_attributes = True

# Forward reference
Category.model_rebuild()