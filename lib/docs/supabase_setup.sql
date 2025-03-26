-- Enable Extensions
BEGIN;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search optimization

-- Create Tables

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  phone_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Set up Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies (drop first if they exist)
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
CREATE POLICY "Users can view their own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
CREATE POLICY "Users can update their own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Service role can manage all profiles" ON profiles;
CREATE POLICY "Service role can manage all profiles" ON profiles
  USING (auth.role() = 'service_role' OR auth.role() = 'supabase_admin');

-- Trigger to set updated_at on update
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF to_jsonb(NEW) ? 'updated_at' THEN
      NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- Trigger to create profile when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, created_at, updated_at)
  VALUES (NEW.id, NEW.email, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create restaurants table
CREATE TABLE IF NOT EXISTS restaurants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  phone TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT,
  opening_hours TEXT,
  average_rating DECIMAL(3, 1) DEFAULT 0,
  total_reviews INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add trigger to update the updated_at column
DROP TRIGGER IF EXISTS update_restaurants_updated_at ON restaurants;
CREATE TRIGGER update_restaurants_updated_at
  BEFORE UPDATE ON restaurants
  FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- Đảm bảo cột opening_hours tồn tại
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'restaurants' AND column_name = 'opening_hours'
    ) THEN
        ALTER TABLE restaurants ADD COLUMN opening_hours TEXT;
    END IF;
END
$$;

-- Đảm bảo các cột average_rating và total_reviews tồn tại trong bảng restaurants
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'restaurants' AND column_name = 'average_rating'
    ) THEN
        ALTER TABLE restaurants ADD COLUMN average_rating DECIMAL(3, 1) DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'restaurants' AND column_name = 'total_reviews'
    ) THEN
        ALTER TABLE restaurants ADD COLUMN total_reviews INTEGER DEFAULT 0;
    END IF;
END
$$;

-- Set up Row Level Security (RLS)
ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;

-- Create policies
DROP POLICY IF EXISTS "Restaurants are viewable by everyone" ON restaurants;
CREATE POLICY "Restaurants are viewable by everyone" ON restaurants
  FOR SELECT USING (true);

-- Create dishes table
CREATE TABLE IF NOT EXISTS dishes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  image_url TEXT,
  category TEXT,
  is_available BOOLEAN DEFAULT true,
  is_popular BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Đảm bảo cột is_popular tồn tại
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'dishes' AND column_name = 'is_popular'
    ) THEN
        ALTER TABLE dishes ADD COLUMN is_popular BOOLEAN DEFAULT false;
    END IF;
END
$$;

-- Set up Row Level Security (RLS)
ALTER TABLE dishes ENABLE ROW LEVEL SECURITY;

-- Create policies
DROP POLICY IF EXISTS "Dishes are viewable by everyone" ON dishes;
CREATE POLICY "Dishes are viewable by everyone" ON dishes
  FOR SELECT USING (true);

DROP TRIGGER IF EXISTS update_dishes_updated_at ON dishes;
CREATE TRIGGER update_dishes_updated_at
  BEFORE UPDATE ON dishes
  FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- Create reservations table
CREATE TABLE IF NOT EXISTS reservations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE NOT NULL,
  date DATE NOT NULL,
  time TEXT NOT NULL,
  number_of_people INTEGER NOT NULL,
  notes TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  payment_id TEXT,
  restaurant_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Đảm bảo cột time tồn tại với tên đúng
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'reservations' AND column_name = 'time_slot'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'reservations' AND column_name = 'time'
    ) THEN
        ALTER TABLE reservations RENAME COLUMN time_slot TO time;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'reservations' AND column_name = 'time'
    ) THEN
        ALTER TABLE reservations ADD COLUMN time TEXT;
    END IF;
END
$$;

-- Set up Row Level Security (RLS)
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;

-- Create policies
DROP POLICY IF EXISTS "Users can view their own reservations" ON reservations;
CREATE POLICY "Users can view their own reservations" ON reservations
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own reservations" ON reservations;
CREATE POLICY "Users can insert their own reservations" ON reservations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own reservations" ON reservations;
CREATE POLICY "Users can update their own reservations" ON reservations
  FOR UPDATE 
  USING (auth.uid() = user_id AND (status = 'pending' OR status = 'confirmed'))
  WITH CHECK (auth.uid() = user_id AND (
    status = 'pending' OR 
    (status = 'confirmed' AND NEW.status = 'cancelled')
  ));

DROP POLICY IF EXISTS "Users can delete their pending reservations" ON reservations;
CREATE POLICY "Users can delete their pending reservations" ON reservations
  FOR DELETE USING (auth.uid() = user_id AND status = 'pending');

DROP TRIGGER IF EXISTS update_reservations_updated_at ON reservations;
CREATE TRIGGER update_reservations_updated_at
  BEFORE UPDATE ON reservations
  FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE NOT NULL,
  rating DECIMAL(2, 1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT NOT NULL,
  user_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Set up Row Level Security (RLS)
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Create policies
DROP POLICY IF EXISTS "Reviews are viewable by everyone" ON reviews;
CREATE POLICY "Reviews are viewable by everyone" ON reviews
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert their own reviews" ON reviews;
CREATE POLICY "Users can insert their own reviews" ON reviews
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own reviews" ON reviews;
CREATE POLICY "Users can update their own reviews" ON reviews
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own reviews" ON reviews;
CREATE POLICY "Users can delete their own reviews" ON reviews
  FOR DELETE USING (auth.uid() = user_id);

DROP TRIGGER IF EXISTS update_reviews_updated_at ON reviews;
CREATE TRIGGER update_reviews_updated_at
  BEFORE UPDATE ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- Add trigger to update restaurant ratings when reviews change
CREATE OR REPLACE FUNCTION update_restaurant_ratings(p_restaurant_id UUID)
RETURNS TRIGGER AS $$
BEGIN
  -- Update the restaurant's average rating and total reviews
  UPDATE restaurants
  SET 
    average_rating = (SELECT COALESCE(AVG(rating), 0) FROM reviews WHERE restaurant_id = p_restaurant_id),
    total_reviews = (SELECT COUNT(*) FROM reviews WHERE restaurant_id = p_restaurant_id),
    updated_at = CURRENT_TIMESTAMP
  WHERE id = p_restaurant_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create or replace the trigger for INSERT operations
DROP TRIGGER IF EXISTS update_restaurant_ratings_insert ON reviews;
CREATE TRIGGER update_restaurant_ratings_insert
  AFTER INSERT ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_restaurant_ratings(NEW.restaurant_id);

-- Create or replace the trigger for UPDATE operations
DROP TRIGGER IF EXISTS update_restaurant_ratings_update ON reviews;
CREATE TRIGGER update_restaurant_ratings_update
  AFTER UPDATE ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_restaurant_ratings(NEW.restaurant_id);

-- Create or replace the trigger for DELETE operations
DROP TRIGGER IF EXISTS update_restaurant_ratings_delete ON reviews;
CREATE TRIGGER update_restaurant_ratings_delete
  AFTER DELETE ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_restaurant_ratings(OLD.restaurant_id);

-- Storage Setup
-- Create bucket for images if not exists
INSERT INTO storage.buckets (id, name, public) 
VALUES ('images', 'images', true)
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies
DROP POLICY IF EXISTS "Images are publicly accessible" ON storage.objects;
CREATE POLICY "Images are publicly accessible" ON storage.objects
  FOR SELECT USING (bucket_id = 'images');

DROP POLICY IF EXISTS "Authenticated users can upload images" ON storage.objects;
CREATE POLICY "Authenticated users can upload images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'images' AND
    auth.role() = 'authenticated'
  );

DROP POLICY IF EXISTS "Users can update their own uploads" ON storage.objects;
CREATE POLICY "Users can update their own uploads" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "Users can delete their own uploads" ON storage.objects;
CREATE POLICY "Users can delete their own uploads" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS dishes_restaurant_id_idx ON dishes(restaurant_id);
CREATE INDEX IF NOT EXISTS dishes_category_idx ON dishes(category);
CREATE INDEX IF NOT EXISTS dishes_price_idx ON dishes(price);
CREATE INDEX IF NOT EXISTS dishes_is_available_idx ON dishes(is_available);
CREATE INDEX IF NOT EXISTS dishes_is_popular_idx ON dishes(is_popular);

CREATE INDEX IF NOT EXISTS reservations_user_id_idx ON reservations(user_id);
CREATE INDEX IF NOT EXISTS reservations_restaurant_id_idx ON reservations(restaurant_id);
CREATE INDEX IF NOT EXISTS reservations_date_idx ON reservations(date);
CREATE INDEX IF NOT EXISTS reservations_status_idx ON reservations(status);

CREATE INDEX IF NOT EXISTS reviews_restaurant_id_idx ON reviews(restaurant_id);
CREATE INDEX IF NOT EXISTS reviews_user_id_idx ON reviews(user_id);
CREATE INDEX IF NOT EXISTS reviews_rating_idx ON reviews(rating);

CREATE INDEX IF NOT EXISTS restaurants_name_idx ON restaurants USING gin(name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS restaurants_address_idx ON restaurants USING gin(address gin_trgm_ops);
CREATE INDEX IF NOT EXISTS restaurants_rating_idx ON restaurants(average_rating);

-- Function to get recent reviews for a restaurant
CREATE OR REPLACE FUNCTION get_recent_reviews(p_restaurant_id UUID, limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  restaurant_id UUID,
  rating DECIMAL,
  comment TEXT,
  user_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT r.id, r.user_id, r.restaurant_id, r.rating, r.comment, r.user_name, r.created_at
  FROM reviews r
  WHERE r.restaurant_id = p_restaurant_id
  ORDER BY r.created_at DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate average rating for a restaurant
CREATE OR REPLACE FUNCTION get_restaurant_rating(p_restaurant_id UUID)
RETURNS TABLE (
  average_rating DECIMAL,
  review_count INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COALESCE(AVG(r.rating), 0) as average_rating,
    COUNT(r.id) as review_count
  FROM reviews r
  WHERE r.restaurant_id = p_restaurant_id;
END;
$$ LANGUAGE plpgsql;

-- Create cancellation_requests table
CREATE TABLE IF NOT EXISTS cancellation_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reservation_id UUID REFERENCES reservations(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  processed_at TIMESTAMP WITH TIME ZONE,
  processed_by UUID REFERENCES auth.users(id),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Set up Row Level Security (RLS)
ALTER TABLE cancellation_requests ENABLE ROW LEVEL SECURITY;

-- Create policies
DROP POLICY IF EXISTS "Users can view their own cancellation requests" ON cancellation_requests;
CREATE POLICY "Users can view their own cancellation requests" ON cancellation_requests
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own cancellation requests" ON cancellation_requests;
CREATE POLICY "Users can insert their own cancellation requests" ON cancellation_requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Đảm bảo transaction được commit
COMMIT; 