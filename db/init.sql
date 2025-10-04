-- Stomatologiya klinika database init SQL

-- Categories jadvali yaratish
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Items jadvali yaratish  
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL UNIQUE,
    price INTEGER NOT NULL,
    description TEXT,
    duration VARCHAR(50),
    min_sessions INTEGER DEFAULT 1,
    max_sessions INTEGER DEFAULT 1,
    category_id INTEGER REFERENCES categories(id),
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Appointments jadvali
CREATE TABLE IF NOT EXISTS appointments (
    id SERIAL PRIMARY KEY,
    patient_name VARCHAR(200) NOT NULL,
    patient_phone VARCHAR(20) NOT NULL,
    patient_telegram_id BIGINT,
    item_id INTEGER REFERENCES items(id),
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Admin users jadvali
CREATE TABLE IF NOT EXISTS admin_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categoriyalar qo'shish (duplicate bo'lsa ignore qilish)
INSERT INTO categories (name, description) VALUES 
('Plomba', 'Tish plombalash xizmatlari'),
('Karonka', 'Tish karonka o''rnatish xizmatlari'),
('Implant', 'Tish implantatsiya xizmatlari'),
('Ortodontiya', 'Tish to''g''rilash xizmatlari'),
('Profilaktika', 'Tish profilaktika xizmatlari')
ON CONFLICT (name) DO NOTHING;

-- Sample itemlar (duplicate bo'lsa ignore qilish)
INSERT INTO items (name, price, description, duration, min_sessions, max_sessions, category_id, image_url) VALUES 
('Plastik plomba', 150000, 'Yuqori sifatli plastik plomba qo''yish xizmati', '1 soat', 1, 1, 1, '/static/images/plomba1.jpg'),
('Kompozit plomba', 200000, 'Zamonaviy kompozit materialdan plomba', '1.5 soat', 1, 1, 1, '/static/images/plomba2.jpg'),
('Metall-keramika karonka', 500000, 'Metall-keramika karonka o''rnatish', '2 hafta', 2, 3, 2, '/static/images/karonka1.jpg'),
('Sirkuloniy karonka', 800000, 'Eng zamonaviy sirkuloniy karonka', '2 hafta', 2, 3, 2, '/static/images/karonka2.jpg'),
('Titan implant', 2000000, 'Yuqori sifatli titan implant o''rnatish', '3-6 oy', 3, 5, 3, '/static/images/implant1.jpg')
ON CONFLICT (name) DO NOTHING;

-- Default admin user qo'shish
-- Username: admin, Password: admin123 (development uchun)
-- Real production da bu backend orqali hash qilinadi
INSERT INTO admin_users (username, password_hash, email) VALUES 
('admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/lewdBdXzogKTQ4H2G', 'admin@dental.local')
ON CONFLICT (username) DO NOTHING;

-- Index'lar yaratish (performance uchun)
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_phone ON appointments(patient_phone);
CREATE INDEX IF NOT EXISTS idx_items_category ON items(category_id);
CREATE INDEX IF NOT EXISTS idx_items_active ON items(is_active);