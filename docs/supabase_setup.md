# Supabase Setup Guide for Good Taste

This guide explains how to set up Supabase for the Good Taste restaurant reservation app.

## 1. Create a Supabase Project

1. Go to [Supabase](https://supabase.com/) and sign in or create an account.
2. Create a new project and choose a name (e.g., "good-taste").
3. Choose a strong password for the database.
4. Select a region closest to your users.
5. Wait for the new project to launch.

## 2. Configure Authentication

1. In your Supabase dashboard, go to **Authentication** > **Providers**.
2. Enable Email authentication.
3. Enable Google OAuth authentication:
   - Go to [Google Cloud Console](https://console.cloud.google.com/) and create a new project.
   - Set up OAuth consent screen with the necessary information.
   - Create OAuth credentials (Web application type).
   - Add authorized redirect URIs:
     ```
     https://<your-supabase-project-id>.supabase.co/auth/v1/callback
     ```
   - Copy the Client ID and Client Secret.
   - Paste these values in the Supabase Google Provider settings.

## 3. Database Setup

Run the following SQL commands in the Supabase SQL Editor to create the necessary tables:

```sql
-- Create users table (extends auth.users)
CREATE TABLE users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT NOT NULL,
  name TEXT,
  phone_number TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create restaurants table
CREATE TABLE restaurants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  phone TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create dishes table
CREATE TABLE dishes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create reservations table
CREATE TABLE reservations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  time TEXT NOT NULL,
  number_of_people INTEGER NOT NULL,
  notes TEXT,
  status TEXT NOT NULL DEFAULT 'Pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create reviews table
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
  rating DECIMAL(2,1) NOT NULL,
  comment TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 4. Row Level Security Policies

Set up Row Level Security (RLS) policies to secure your data:

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE dishes ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view their own data" 
ON users FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update their own data" 
ON users FOR UPDATE 
USING (auth.uid() = id);

-- Restaurants table policies (public read)
CREATE POLICY "Restaurants are viewable by everyone" 
ON restaurants FOR SELECT 
USING (true);

-- Dishes table policies (public read)
CREATE POLICY "Dishes are viewable by everyone" 
ON dishes FOR SELECT 
USING (true);

-- Reservations table policies
CREATE POLICY "Users can view their own reservations" 
ON reservations FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own reservations" 
ON reservations FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own reservations" 
ON reservations FOR UPDATE 
USING (auth.uid() = user_id);

-- Reviews table policies
CREATE POLICY "Reviews are viewable by everyone" 
ON reviews FOR SELECT 
USING (true);

CREATE POLICY "Users can insert their own reviews" 
ON reviews FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own reviews" 
ON reviews FOR UPDATE 
USING (auth.uid() = user_id);
```

## 5. Create Triggers and Functions

Create a trigger to update the `updated_at` field:

```sql
-- Function to update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for users table
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

-- Trigger for reservations table
CREATE TRIGGER update_reservations_updated_at
BEFORE UPDATE ON reservations
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();
```

## 6. Sample Data

Insert sample data to test the app:

```sql
-- Insert sample restaurants
INSERT INTO restaurants (name, address, phone, description, image_url)
VALUES 
('The Garden Bistro', '123 Main St, New York, NY 10001', '(212) 555-1234', 'A cozy bistro with garden-inspired decor serving fresh, seasonal dishes.', 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&h=600'),
('Sapphire Lounge', '456 Park Ave, New York, NY 10022', '(212) 555-5678', 'An elegant dining experience with modern cuisine and innovative cocktails.', 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&h=600'),
('Rustic Table', '789 Broadway, New York, NY 10003', '(212) 555-9012', 'Farm-to-table restaurant with rustic charm serving hearty, homestyle meals.', 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&h=600');

-- Insert sample dishes for The Garden Bistro
INSERT INTO dishes (restaurant_id, name, description, price, image_url)
VALUES 
((SELECT id FROM restaurants WHERE name = 'The Garden Bistro'), 'Garden Salad', 'Fresh greens with seasonal vegetables and house dressing', 12.99, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&h=600'),
((SELECT id FROM restaurants WHERE name = 'The Garden Bistro'), 'Herb Roasted Chicken', 'Free-range chicken with roasted vegetables and herbs', 24.99, 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=800&h=600'),
((SELECT id FROM restaurants WHERE name = 'The Garden Bistro'), 'Chocolate Lava Cake', 'Warm chocolate cake with molten center and vanilla ice cream', 9.99, 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=800&h=600');

-- Insert sample dishes for Sapphire Lounge
INSERT INTO dishes (restaurant_id, name, description, price, image_url)
VALUES 
((SELECT id FROM restaurants WHERE name = 'Sapphire Lounge'), 'Tuna Tartare', 'Fresh tuna with avocado, soy-ginger sauce, and wonton crisps', 18.99, 'https://images.unsplash.com/photo-1546549032-9571cd6b27df?w=800&h=600'),
((SELECT id FROM restaurants WHERE name = 'Sapphire Lounge'), 'Filet Mignon', 'Prime beef tenderloin with truffle mashed potatoes and asparagus', 42.99, 'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=800&h=600'),
((SELECT id FROM restaurants WHERE name = 'Sapphire Lounge'), 'Crème Brûlée', 'Classic French custard with caramelized sugar crust', 12.99, 'https://images.unsplash.com/photo-1470124182917-cc6e71b22ecc?w=800&h=600');

-- Insert sample dishes for Rustic Table
INSERT INTO dishes (restaurant_id, name, description, price, image_url)
VALUES 
((SELECT id FROM restaurants WHERE name = 'Rustic Table'), 'Farmhouse Platter', 'Selection of artisanal cheeses, cured meats, and house-made pickles', 19.99, 'https://images.unsplash.com/photo-1485963631004-f2f00b1d6606?w=800&h=600'),
((SELECT id FROM restaurants WHERE name = 'Rustic Table'), 'Slow-Cooked Short Ribs', 'Braised short ribs with root vegetables and red wine reduction', 28.99, 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&h=600'),
((SELECT id FROM restaurants WHERE name = 'Rustic Table'), 'Apple Pie', 'Homestyle apple pie with cinnamon ice cream', 10.99, 'https://images.unsplash.com/photo-1535920527002-b35e96722969?w=800&h=600');
```

## 7. Configure Flutter App

1. Go to the Supabase project settings to get your:
   - Project URL
   - Project API Key (anon key)

2. Update the `lib/constants/env.dart` file with your Supabase credentials:

```dart
class Env {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Momo Payment Configuration (Test Environment)
  static const String momoPartnerCode = 'MOMO_PARTNER_CODE';
  static const String momoAccessKey = 'MOMO_ACCESS_KEY';
  static const String momoSecretKey = 'MOMO_SECRET_KEY';
  static const String momoApiEndpoint = 'https://test-payment.momo.vn/v2/gateway/api/create';
  static const String momoIpnUrl = 'YOUR_IPN_URL';
  static const String momoRedirectUrl = 'YOUR_REDIRECT_URL';
}
```

## 8. Storage Setup

1. In the Supabase dashboard, go to **Storage** > **Create a new bucket**.
2. Create a bucket named `restaurant_images` for restaurant and dish images.
3. Set the bucket to public (for this demo) to easily access images.

## 9. Real-time Subscriptions

Make sure the Supabase real-time feature is enabled:

1. Go to **Database** > **Replication**.
2. Enable replication for the tables you want to subscribe to changes:
   - `reservations`
   - `reviews`

## 10. Testing

1. Run the Flutter app using `flutter run`.
2. Test the authentication flow using Google Sign-In.
3. Verify that you can see the sample restaurants and dishes.
4. Test making a reservation and submitting a review.
5. Verify that real-time updates work for reservations and reviews.

## Troubleshooting

- If you encounter authentication issues, check the Google OAuth configuration.
- For database access issues, verify your RLS policies are correct.
- For real-time subscription issues, ensure the replication is enabled for the relevant tables. 