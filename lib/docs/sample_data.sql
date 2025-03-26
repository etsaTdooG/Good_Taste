-- This script creates a test user and sample data for development
-- IMPORTANT: Execute this script after setting up your database schema with supabase_setup.sql

BEGIN;

-- Create Test Users
-- IMPORTANT: Run this in the Authentication SQL Editor
-- Use these test users to login:
-- 1. test@gota.com / Test@123456 (Regular user)
-- 2. admin@gota.com / Admin@123456 (Admin user - for future admin features)

-- Regular test user
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  role,
  confirmation_token
) VALUES (
  '11111111-1111-1111-1111-111111111111',
  'test@gota.com',
  crypt('Test@123456', gen_salt('bf')),
  current_timestamp,
  current_timestamp,
  current_timestamp,
  'authenticated',
  ''
) ON CONFLICT (id) DO NOTHING;

-- Admin test user (for future admin features)
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  role,
  confirmation_token
) VALUES (
  '22222222-2222-2222-2222-222222222222',
  'admin@gota.com',
  crypt('Admin@123456', gen_salt('bf')),
  current_timestamp,
  current_timestamp,
  current_timestamp,
  'authenticated',
  ''
) ON CONFLICT (id) DO NOTHING;

-- Insert sample profiles
INSERT INTO public.profiles (
  id,
  email,
  name,
  phone_number,
  created_at,
  updated_at
) VALUES (
  '11111111-1111-1111-1111-111111111111',
  'test@gota.com',
  'Người Dùng Thử Nghiệm',
  '0903123456',
  current_timestamp,
  current_timestamp
) ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  phone_number = EXCLUDED.phone_number,
  updated_at = current_timestamp;

INSERT INTO public.profiles (
  id,
  email,
  name,
  phone_number,
  created_at,
  updated_at
) VALUES (
  '22222222-2222-2222-2222-222222222222',
  'admin@gota.com',
  'Quản Trị Viên',
  '0901234567',
  current_timestamp,
  current_timestamp
) ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  phone_number = EXCLUDED.phone_number,
  updated_at = current_timestamp;

-- Insert Sample Restaurants with updated image URLs and opening hours
INSERT INTO restaurants (
  id, 
  name, 
  address, 
  phone, 
  description, 
  image_url,
  opening_hours,
  created_at
) VALUES 
  (
    '00000000-0000-0000-0000-000000000001', 
    'Nhà hàng Hải Sản Biển Đông', 
    '123 Đường Nguyễn Huệ, Quận 1, TP HCM', 
    '0901234567', 
    'Nhà hàng hải sản tươi sống với các món ăn đặc trưng của vùng biển miền Trung.',
    'https://images.unsplash.com/photo-1579173235899-a597b8a68aa9?auto=format&fit=crop&w=800&q=80',
    '11:00 - 23:00',
    current_timestamp
  ),
  (
    '00000000-0000-0000-0000-000000000002', 
    'Phở Hà Nội Truyền Thống', 
    '45 Đường Lê Lợi, Quận 1, TP HCM', 
    '0909876543', 
    'Phở bò truyền thống với nước dùng đậm đà, thơm ngon chuẩn vị Hà Nội.',
    'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?auto=format&fit=crop&w=800&q=80',
    '6:00 - 22:00',
    current_timestamp
  ),
  (
    '00000000-0000-0000-0000-000000000003', 
    'Quán Cơm Niêu Mẹ Làm', 
    '78 Đường Cách Mạng Tháng 8, Quận 3, TP HCM', 
    '0908765432', 
    'Quán cơm niêu với hương vị đậm đà của các món ăn dân dã miền Nam.',
    'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?auto=format&fit=crop&w=800&q=80',
    '10:00 - 21:00',
    current_timestamp
  ),
  (
    '00000000-0000-0000-0000-000000000004', 
    'Bánh Mì Sài Gòn Express', 
    '22 Đường Nguyễn Du, Quận 1, TP HCM', 
    '0907654321', 
    'Tiệm bánh mì nổi tiếng với công thức độc đáo kết hợp giữa truyền thống và hiện đại.',
    'https://images.unsplash.com/photo-1523403887511-1963e33e1cf3?auto=format&fit=crop&w=800&q=80',
    '6:00 - 20:00',
    current_timestamp
  ),
  (
    '00000000-0000-0000-0000-000000000005', 
    'Quán Ốc Đêm Sài Gòn', 
    '150 Đường Nguyễn Thị Minh Khai, Quận 3, TP HCM', 
    '0903333333', 
    'Quán ốc đa dạng với nhiều món ốc tươi ngon, chế biến đặc sắc theo phong cách đường phố.',
    'https://images.unsplash.com/photo-1553625069-ef56c2e76b8f?auto=format&fit=crop&w=800&q=80',
    '16:00 - 1:00',
    current_timestamp
  )
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  description = EXCLUDED.description,
  image_url = EXCLUDED.image_url,
  opening_hours = EXCLUDED.opening_hours;

-- Insert Sample Dishes with updated image URLs and is_popular flag
INSERT INTO dishes (
  restaurant_id, 
  name, 
  description, 
  price, 
  category, 
  image_url, 
  is_available,
  is_popular,
  created_at
) VALUES 
  ('00000000-0000-0000-0000-000000000001', 'Cua Rang Me', 'Cua biển tươi sống rang với sốt me chua ngọt', 250000, 'Hải sản', 'https://images.unsplash.com/photo-1583775528559-eca5b2933deb?auto=format&fit=crop&w=800&q=80', true, true, current_timestamp),
  ('00000000-0000-0000-0000-000000000001', 'Tôm Hùm Nướng Phô Mai', 'Tôm hùm nướng với phô mai béo ngậy', 450000, 'Hải sản', 'https://images.unsplash.com/photo-1565680018160-64b74a87a114?auto=format&fit=crop&w=800&q=80', true, true, current_timestamp),
  ('00000000-0000-0000-0000-000000000001', 'Ốc Hương Sốt Tỏi', 'Ốc hương xào với tỏi thơm', 180000, 'Hải sản', 'https://images.unsplash.com/photo-1505253468034-514d2507d914?auto=format&fit=crop&w=800&q=80', true, false, current_timestamp),
  ('00000000-0000-0000-0000-000000000001', 'Cá Hấp Hồng Kông', 'Cá tươi hấp theo phong cách Hồng Kông', 220000, 'Hải sản', 'https://images.unsplash.com/photo-1556611832-c5f358b0057e?auto=format&fit=crop&w=800&q=80', true, false, current_timestamp),
  
  ('00000000-0000-0000-0000-000000000002', 'Phở Bò Tái', 'Phở với thịt bò tái, nước dùng đậm đà', 65000, 'Phở', 'https://images.unsplash.com/photo-1623341214825-9f4f963727da?auto=format&fit=crop&w=800&q=80', true, true, current_timestamp),
  ('00000000-0000-0000-0000-000000000002', 'Phở Gà', 'Phở với thịt gà, nước dùng thanh ngọt', 60000, 'Phở', 'https://images.unsplash.com/photo-1568096889942-6eedde686635?auto=format&fit=crop&w=800&q=80', true, false, current_timestamp),
  ('00000000-0000-0000-0000-000000000002', 'Bún Chả', 'Bún ăn kèm với chả viên và chả miếng nướng', 75000, 'Bún', 'https://images.unsplash.com/photo-1627308595171-d1b5d67129c4?auto=format&fit=crop&w=800&q=80', true, true, current_timestamp),
  ('00000000-0000-0000-0000-000000000002', 'Bánh Cuốn', 'Bánh cuốn nhân thịt, mộc nhĩ thơm ngon', 55000, 'Bánh', 'https://images.unsplash.com/photo-1619872882406-f9596163d25a?auto=format&fit=crop&w=800&q=80', true, false, current_timestamp),
  
  ('00000000-0000-0000-0000-000000000003', 'Cơm Niêu Sườn', 'Cơm niêu với sườn nướng mật ong', 85000, 'Cơm', 'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?auto=format&fit=crop&w=800&q=80', true, true, current_timestamp),
  ('00000000-0000-0000-0000-000000000003', 'Cơm Chiên Hải Sản', 'Cơm chiên với các loại hải sản tươi ngon', 95000, 'Cơm', 'https://images.unsplash.com/photo-1520175480921-4edfa2983e0f?auto=format&fit=crop&w=800&q=80', true, false, current_timestamp),
  ('00000000-0000-0000-0000-000000000003', 'Canh Chua Cá Lóc', 'Canh chua với cá lóc đồng tươi', 65000, 'Canh', 'https://images.unsplash.com/photo-1578020190497-fc581a7f46e9?auto=format&fit=crop&w=800&q=80', true, true, current_timestamp),
  ('00000000-0000-0000-0000-000000000003', 'Lẩu Mắm', 'Lẩu mắm đặc sản miền Tây đậm đà', 250000, 'Lẩu', 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=800&q=80', true, false, current_timestamp),
  
  ('00000000-0000-0000-0000-000000000004', 'Bánh Mì Thịt', 'Bánh mì với thịt heo quay, pate, rau sống', 35000, 'Bánh mì', 'https://images.unsplash.com/photo-1600336153113-d66c79de3e91?auto=format&fit=crop&w=800&q=80', true, true, current_timestamp),
  ('00000000-0000-0000-0000-000000000004', 'Bánh Mì Gà', 'Bánh mì với thịt gà xé, sốt mayo', 30000, 'Bánh mì', 'https://images.unsplash.com/photo-1573821663912-569905455b1c?auto=format&fit=crop&w=800&q=80', true, false, current_timestamp),
  ('00000000-0000-0000-0000-000000000004', 'Bánh Mì Chảo', 'Bánh mì nướng ăn kèm với trứng, pate, thịt chiên', 45000, 'Bánh mì', 'https://images.unsplash.com/photo-1580959375944-abd7e991f971?auto=format&fit=crop&w=800&q=80', true, true, current_timestamp),
  
  ('00000000-0000-0000-0000-000000000005', 'Ốc Hương Xào Tỏi', 'Ốc hương xào với tỏi và ớt', 120000, 'Ốc', 'https://images.unsplash.com/photo-1558651000-64ee14239b3b?auto=format&fit=crop&w=800&q=80', true, true, current_timestamp),
  ('00000000-0000-0000-0000-000000000005', 'Nghêu Hấp Sả', 'Nghêu hấp với sả và ớt', 95000, 'Ốc', 'https://images.unsplash.com/photo-1625944525533-473dc8a2a4d8?auto=format&fit=crop&w=800&q=80', true, false, current_timestamp),
  ('00000000-0000-0000-0000-000000000005', 'Sò Điệp Nướng Mỡ Hành', 'Sò điệp nướng với mỡ hành thơm béo', 150000, 'Ốc', 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=800&q=80', true, true, current_timestamp);

-- Insert Sample Reviews
INSERT INTO reviews (
  id, 
  user_id, 
  restaurant_id, 
  rating, 
  comment, 
  user_name, 
  created_at
) VALUES
  (uuid_generate_v4(), '11111111-1111-1111-1111-111111111111'::UUID, '00000000-0000-0000-0000-000000000001'::UUID, 4.5, 'Hải sản rất tươi, dịch vụ tốt!', 'Người Dùng Thử Nghiệm', current_timestamp - interval '5 days'),
  (uuid_generate_v4(), '11111111-1111-1111-1111-111111111111'::UUID, '00000000-0000-0000-0000-000000000002'::UUID, 5.0, 'Phở ngon chuẩn vị Hà Nội, sẽ quay lại lần sau!', 'Người Dùng Thử Nghiệm', current_timestamp - interval '10 days'),
  (uuid_generate_v4(), '22222222-2222-2222-2222-222222222222'::UUID, '00000000-0000-0000-0000-000000000001'::UUID, 4.0, 'Món ăn ngon, giá hơi cao', 'Quản Trị Viên', current_timestamp - interval '3 days'),
  (uuid_generate_v4(), '22222222-2222-2222-2222-222222222222'::UUID, '00000000-0000-0000-0000-000000000003'::UUID, 4.8, 'Cơm niêu rất thơm, không gian thoáng mát', 'Quản Trị Viên', current_timestamp - interval '7 days'),
  (uuid_generate_v4(), '11111111-1111-1111-1111-111111111111'::UUID, '00000000-0000-0000-0000-000000000004'::UUID, 4.6, 'Bánh mì giòn ngon, nhân đầy đặn', 'Người Dùng Thử Nghiệm', current_timestamp - interval '2 days'),
  (uuid_generate_v4(), '22222222-2222-2222-2222-222222222222'::UUID, '00000000-0000-0000-0000-000000000005'::UUID, 4.3, 'Ốc tươi ngon, sốt đậm đà, giá hợp lý', 'Quản Trị Viên', current_timestamp - interval '1 day'),
  (uuid_generate_v4(), '11111111-1111-1111-1111-111111111111'::UUID, '00000000-0000-0000-0000-000000000005'::UUID, 3.8, 'Đồ ăn ngon nhưng phục vụ hơi chậm', 'Người Dùng Thử Nghiệm', current_timestamp - interval '15 days');

-- Thêm dữ liệu mẫu để có nhiều đánh giá hơn
INSERT INTO reviews (
  id, 
  user_id, 
  restaurant_id, 
  rating, 
  comment, 
  user_name, 
  created_at
)
SELECT 
  uuid_generate_v4(), 
  CASE WHEN random() > 0.5 
       THEN '11111111-1111-1111-1111-111111111111'::UUID 
       ELSE '22222222-2222-2222-2222-222222222222'::UUID 
  END,
  CONCAT('00000000-0000-0000-0000-00000000000', floor(random() * 5) + 1)::UUID,
  3.0 + floor(random() * 20) / 10.0,
  CASE floor(random() * 5)
    WHEN 0 THEN 'Đồ ăn rất ngon, nhân viên phục vụ chuyên nghiệp.'
    WHEN 1 THEN 'Không gian thoáng mát, sạch sẽ. Sẽ quay lại lần sau.'
    WHEN 2 THEN 'Món ăn mang hương vị truyền thống, rất hợp khẩu vị.'
    WHEN 3 THEN 'Giá cả hợp lý, phần ăn đầy đặn.'
    ELSE 'Nơi lý tưởng để gặp gỡ bạn bè và gia đình.'
  END,
  CASE WHEN random() > 0.5 THEN 'Người Dùng Thử Nghiệm' ELSE 'Quản Trị Viên' END,
  current_timestamp - (random() * interval '30 days')
FROM generate_series(1, 20); -- Thêm 20 đánh giá ngẫu nhiên

-- Insert Sample Reservations
INSERT INTO reservations (
  user_id, 
  restaurant_id, 
  date, 
  time, 
  number_of_people, 
  notes, 
  status, 
  restaurant_name, 
  created_at
) VALUES
  ('11111111-1111-1111-1111-111111111111'::UUID, '00000000-0000-0000-0000-000000000001'::UUID, CURRENT_DATE + INTERVAL '1 day', '19:00', 4, 'Bàn với view đẹp, nếu được', 'confirmed', 'Nhà hàng Hải Sản Biển Đông', current_timestamp - interval '2 days'),
  ('11111111-1111-1111-1111-111111111111'::UUID, '00000000-0000-0000-0000-000000000002'::UUID, CURRENT_DATE + INTERVAL '2 day', '18:30', 2, 'Bàn gần cửa sổ', 'pending', 'Phở Hà Nội Truyền Thống', current_timestamp - interval '1 day'),
  ('22222222-2222-2222-2222-222222222222'::UUID, '00000000-0000-0000-0000-000000000003'::UUID, CURRENT_DATE + INTERVAL '3 day', '12:00', 6, 'Đặt tiệc sinh nhật nhỏ', 'confirmed', 'Quán Cơm Niêu Mẹ Làm', current_timestamp - interval '3 days'),
  ('11111111-1111-1111-1111-111111111111'::UUID, '00000000-0000-0000-0000-000000000004'::UUID, CURRENT_DATE - INTERVAL '2 day', '18:00', 2, 'Không có ghi chú', 'completed', 'Bánh Mì Sài Gòn Express', current_timestamp - interval '5 days'),
  ('22222222-2222-2222-2222-222222222222'::UUID, '00000000-0000-0000-0000-000000000005'::UUID, CURRENT_DATE - INTERVAL '1 day', '20:00', 4, 'Không ăn cay', 'cancelled', 'Quán Ốc Đêm Sài Gòn', current_timestamp - interval '4 days'),
  ('11111111-1111-1111-1111-111111111111'::UUID, '00000000-0000-0000-0000-000000000003'::UUID, CURRENT_DATE + INTERVAL '5 day', '19:30', 3, 'Không ngồi gần quầy bar', 'pending', 'Quán Cơm Niêu Mẹ Làm', current_timestamp);

-- Cập nhật average_rating và total_reviews cho các nhà hàng dựa trên đánh giá
UPDATE restaurants r
SET 
    average_rating = (SELECT COALESCE(AVG(rating), 0) FROM reviews rv WHERE rv.restaurant_id = r.id),
    total_reviews = (SELECT COUNT(*) FROM reviews rv WHERE rv.restaurant_id = r.id);

-- Create bucket folders if not exists
-- Note: This section is commented out as the storage.objects table structure may not be compatible
-- Uncomment and modify as needed based on your actual schema
/*
INSERT INTO storage.buckets (id, name)
VALUES ('images', 'Images Bucket')
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.objects (id, bucket_id, name)
VALUES 
  (uuid_generate_v4(), 'images', 'restaurants/.gitkeep'),
  (uuid_generate_v4(), 'images', 'dishes/.gitkeep')
ON CONFLICT (bucket_id, name) DO NOTHING;
*/

COMMIT; 

-- Important Note: Make sure you run the supabase_setup.sql script BEFORE running this sample_data.sql script
-- to ensure all the necessary table structures, triggers, and functions are in place.