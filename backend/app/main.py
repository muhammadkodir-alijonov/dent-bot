from fastapi import FastAPI, Depends, HTTPException, Request, Form, UploadFile, File
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List, Optional
import os
from dotenv import load_dotenv

from . import crud, schemas, database
from .telegram_bot import setup_bot

load_dotenv()

# Base URL for static files
def get_base_url(request: Request = None):
    # Agar request mavjud bo'lsa, host header'dan base URL olish
    if request:
        # Ngrok forwarded headers'ni tekshirish
        forwarded_host = request.headers.get("x-forwarded-host")
        forwarded_proto = request.headers.get("x-forwarded-proto", "https")
        
        if forwarded_host:
            # Ngrok yoki boshqa proxy orqali kelayotgan so'rov
            return f"{forwarded_proto}://{forwarded_host}"
        
        # Oddiy host header
        scheme = "https" if request.headers.get("x-forwarded-proto") == "https" else request.url.scheme
        host = request.headers.get("host", str(request.url.hostname or ""))
        
        if host:
            return f"{scheme}://{host}"
    
    # Fallback - environment variable
    webapp_url = os.getenv("WEBAPP_URL", "http://localhost:8000")
    return webapp_url

app = FastAPI(title="Stomatologiya Klinika", description="Dental Clinic Management System")

# Ngrok warning sahifasini o'tkazib yuborish uchun middleware
@app.middleware("http")
async def add_ngrok_skip_header(request: Request, call_next):
    response = await call_next(request)
    # Ngrok warning sahifasini o'tkazib yuborish
    response.headers["ngrok-skip-browser-warning"] = "true"
    return response

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Static files va templates
app.mount("/static", StaticFiles(directory="app/static"), name="static")
templates = Jinja2Templates(directory="app/templates")

# Database yaratish
@app.on_event("startup")
async def startup_event():
    database.create_tables()
    
    # Admin user yaratish (agar mavjud bo'lmasa)
    db = database.SessionLocal()
    try:
        admin = crud.get_admin_by_username(db, "jahongir_stom")
        if not admin:
            admin_create = schemas.AdminCreate(username="jahongir_stom", password="jahongir!@#")
            crud.create_admin(db, admin_create)
            print("Admin user created successfully!")
    finally:
        db.close()
    
    # Bot setup
    try:
        await setup_bot()
        print("Telegram bot setup completed!")
    except Exception as e:
        print(f"Bot setup error: {e}")
        print("Bot ishlamasa ham web app ishlaydi!")

# Webhook endpoint for Telegram bot (production uchun)
@app.post("/webhook")
async def webhook(request: Request):
    try:
        from .telegram_bot import webhook_handler
        json_data = await request.json()
        await webhook_handler(json_data)
        return {"status": "ok"}
    except Exception as e:
        print(f"Webhook error: {e}")
        return {"status": "error", "message": str(e)}

# Dependency
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Ngrok skip redirect
@app.get("/")
async def home_redirect(request: Request, db: Session = Depends(get_db), ngrok_skip_browser_warning: str = None):
    # Agar ngrok parametri yo'q bo'lsa va ngrok URL dan kelayotgan bo'lsa
    if not ngrok_skip_browser_warning and "ngrok" in str(request.url.hostname or ""):
        # Parametr bilan redirect qilish
        return RedirectResponse(url=f"{request.url}?ngrok-skip-browser-warning=true")
    
    # Oddiy sahifa
    categories = crud.get_categories(db)  
    items = crud.get_items(db, limit=50)
    return templates.TemplateResponse("index.html", {
        "request": request,
        "categories": categories,
        "items": items,
        "base_url": get_base_url(request)
    })

# SEARCH ITEMS
@app.get("/search", response_class=HTMLResponse)
async def search_items(request: Request, q: str = "", db: Session = Depends(get_db)):
    categories = crud.get_categories(db)
    if q:
        items = crud.search_items(db, q)
    else:
        items = crud.get_items(db, limit=50)
    return templates.TemplateResponse("index.html", {
        "request": request,
        "categories": categories,
        "items": items,
        "search_query": q,
        "base_url": get_base_url(request)
    })

# CATEGORY FILTER
@app.get("/category/{category_id}", response_class=HTMLResponse)
async def filter_by_category(request: Request, category_id: int, db: Session = Depends(get_db)):
    categories = crud.get_categories(db)
    items = crud.get_items(db, category_id=category_id, limit=50)
    selected_category = crud.get_category(db, category_id)
    return templates.TemplateResponse("index.html", {
        "request": request,
        "categories": categories,
        "items": items,
        "selected_category": selected_category,
        "base_url": get_base_url(request)
    })

# ITEM DETAIL
@app.get("/item/{item_id}", response_class=HTMLResponse)
async def item_detail(request: Request, item_id: int, db: Session = Depends(get_db)):
    item = crud.get_item(db, item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return templates.TemplateResponse("item_detail.html", {
        "request": request,
        "item": item,
        "base_url": get_base_url(request)
    })

# ADMIN LOGIN
@app.get("/admin", response_class=HTMLResponse)
async def admin_login_page(request: Request):
    return templates.TemplateResponse("admin_login.html", {"request": request, "base_url": get_base_url(request)})

@app.post("/admin/login")
async def admin_login(request: Request, username: str = Form(...), password: str = Form(...), db: Session = Depends(get_db)):
    admin = crud.authenticate_admin(db, username, password)
    if not admin:
        return templates.TemplateResponse("admin_login.html", {
            "request": request,
            "error": "Noto'g'ri login yoki parol",
            "base_url": get_base_url(request)
        })
    
    # Simple session management (production da JWT ishlating)
    response = RedirectResponse(url="/admin/dashboard", status_code=302)
    response.set_cookie(key="admin_session", value="authenticated")
    return response

# ADMIN DASHBOARD
@app.get("/admin/dashboard", response_class=HTMLResponse)
async def admin_dashboard(request: Request, db: Session = Depends(get_db)):
    # Simple session check
    admin_session = request.cookies.get("admin_session")
    if admin_session != "authenticated":
        return RedirectResponse(url="/admin")
    
    categories = crud.get_categories(db)
    items = crud.get_items(db, limit=100)
    return templates.TemplateResponse("admin_dashboard.html", {
        "request": request,
        "categories": categories,
        "items": items,
        "base_url": get_base_url(request)
    })

# ADMIN - Category CRUD
@app.post("/admin/categories")
async def create_category(
    request: Request,
    name: str = Form(...),
    description: str = Form(""),
    db: Session = Depends(get_db)
):
    category_data = schemas.CategoryCreate(name=name, description=description)
    crud.create_category(db, category_data)
    return RedirectResponse(url="/admin/dashboard", status_code=302)

@app.post("/admin/categories/{category_id}/delete")
async def delete_category_admin(category_id: int, db: Session = Depends(get_db)):
    crud.delete_category(db, category_id)
    return RedirectResponse(url="/admin/dashboard", status_code=302)

# ADMIN - Item CRUD
@app.post("/admin/items")
async def create_item(
    request: Request,
    name: str = Form(...),
    price: float = Form(...),
    description: str = Form(...),
    duration: str = Form(...),
    min_sessions: int = Form(...),
    max_sessions: int = Form(...),
    category_id: int = Form(...),
    image: UploadFile = File(None),
    db: Session = Depends(get_db)
):
    image_url = None
    if image and image.filename:
        # Image upload logic
        os.makedirs("app/static/images", exist_ok=True)
        image_url = f"/static/images/{image.filename}"
        file_path = f"app/static/images/{image.filename}"
        with open(file_path, "wb") as f:
            content = await image.read()
            f.write(content)
    
    item_data = schemas.ItemCreate(
        name=name,
        price=price,
        description=description,
        duration=duration,
        min_sessions=min_sessions,
        max_sessions=max_sessions,
        category_id=category_id,
        image_url=image_url
    )
    crud.create_item(db, item_data)
    return RedirectResponse(url="/admin/dashboard", status_code=302)

@app.post("/admin/items/{item_id}/delete")
async def delete_item_admin(item_id: int, db: Session = Depends(get_db)):
    crud.delete_item(db, item_id)
    return RedirectResponse(url="/admin/dashboard", status_code=302)

# API Endpoints (JSON responses)
@app.get("/api/categories", response_model=List[schemas.Category])
def read_categories(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return crud.get_categories(db, skip=skip, limit=limit)

@app.get("/api/items", response_model=List[schemas.Item])
def read_items(skip: int = 0, limit: int = 100, category_id: Optional[int] = None, db: Session = Depends(get_db)):
    return crud.get_items(db, skip=skip, limit=limit, category_id=category_id)

@app.get("/api/items/{item_id}", response_model=schemas.Item)
def read_item(item_id: int, db: Session = Depends(get_db)):
    item = crud.get_item(db, item_id=item_id)
    if item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    return item

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)