-- Admin userni yaratish uchun boshlang'ich SQL

-- Categoriyalar
INSERT INTO categories (name, description) VALUES 
('Plomba', 'Tish plombalash xizmatlari'),
('Karonka', 'Tish karonka o''rnatish xizmatlari'),
('Implant', 'Tish implantatsiya xizmatlari'),
('Ortodontiya', 'Tish to''g''rilash xizmatlari'),
('Profilaktika', 'Tish profilaktika xizmatlari');

-- Sample itemlar
INSERT INTO items (name, price, description, duration, min_sessions, max_sessions, category_id, image_url) VALUES 
('Plastik plomba', 150000, 'Yuqori sifatli plastik plomba qo''yish xizmati', '1 soat', 1, 1, 1, '/static/images/plomba1.jpg'),
('Kompozit plomba', 200000, 'Zamonaviy kompozit materialdan plomba', '1.5 soat', 1, 1, 1, '/static/images/plomba2.jpg'),
('Metall-keramika karonka', 500000, 'Metall-keramika karonka o''rnatish', '2 hafta', 2, 3, 2, '/static/images/karonka1.jpg'),
('Sirkuloniy karonka', 800000, 'Eng zamonaviy sirkuloniy karonka', '2 hafta', 2, 3, 2, '/static/images/karonka2.jpg'),
('Titan implant', 2000000, 'Yuqori sifatli titan implant o''rnatish', '3-6 oy', 3, 5, 3, '/static/images/implant1.jpg');

-- Admin user (username: jahongir_stom, password: jahongir!@#)
-- Parol hash: $2b$12$hash_will_be_generated_here
-- Bu hash real dasturda backend orqali generate bo'ladi