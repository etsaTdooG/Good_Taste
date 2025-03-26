# Gota Restaurant App - Setup Guide

This guide will help you set up the Gota Restaurant App with Supabase backend and Momo payment integration.

## Prerequisites

- Flutter SDK (latest stable version)
- Supabase account
- Momo developer account (for payment integration)
- Git

## Project Setup

1. Clone the repository:

```
git clone <repository-url>
cd gota
```

2. Install dependencies:

```
flutter pub get
```

## Supabase Setup

1. Create a new Supabase project at [https://app.supabase.io/](https://app.supabase.io/)
2. Once your project is created, get your Supabase URL and anon key from the API section in the project dashboard.
3. Update the `lib/config/supabase_config.dart` file with your credentials:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

4. Set up your Supabase database schema by running the SQL commands provided in `lib/docs/supabase_sql_setup.md`. You can run these commands in the SQL Editor in your Supabase dashboard.

5. Enable email authentication in your Supabase Authentication settings.

6. Create a storage bucket for images:
   - Go to Storage in your Supabase dashboard
   - Create a new public bucket named "images"
   - Set the appropriate policies as mentioned in the SQL setup file

## Momo Payment Integration (Test Environment)

1. Register for a Momo developer account at [https://business.momo.vn/](https://business.momo.vn/)
2. Create a test merchant and get your test credentials (Partner Code, Access Key, Secret Key)
3. Update the `lib/config/supabase_config.dart` file with your Momo credentials:

```dart
static const String momoPartnerCode = 'YOUR_MOMO_PARTNER_CODE';
static const String momoAccessKey = 'YOUR_MOMO_ACCESS_KEY';
static const String momoSecretKey = 'YOUR_MOMO_SECRET_KEY';
```

4. Set up the redirect URL for your app. This is required for the payment flow:

```dart
static const String redirectUrl = 'YOUR_APP_SCHEME://payment-result';
```

5. Update your `android/app/src/main/AndroidManifest.xml` to handle the redirect URL:

```xml
<activity
    android:name=".MainActivity"
    android:launchMode="singleTask">
    <!-- ... other activity attributes ... -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="YOUR_APP_SCHEME" android:host="payment-result" />
    </intent-filter>
</activity>
```

6. For iOS, update `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>YOUR_BUNDLE_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_APP_SCHEME</string>
        </array>
    </dict>
</array>
```

## Loading Sample Data

1. Use the sample data provided in `lib/docs/supabase_sql_setup.md` to populate your database with test restaurants and dishes.

2. To add images for restaurants and dishes, you can use the Storage Upload feature in your Supabase dashboard:
   - Upload image files to the "images" bucket
   - Get the public URL for each image
   - Update the corresponding records in the database with the image URLs

## Running the App

1. Start the app:

```
flutter run
```

2. Use the following test credentials to log in:
   - Email: test@example.com
   - Password: password123

## Features Implementation

### Authentication
- The app uses Supabase Authentication for email sign-in.
- User profiles are stored in the `profiles` table.

### Real-time Updates
- Reservations and reviews are updated in real-time using Supabase's real-time subscriptions.
- To test, make updates to reservations or reviews through another device or the Supabase dashboard, and you'll see the changes reflected instantly in the app.

### Restaurant and Dish Management
- Restaurants and dishes are fetched from the Supabase database.
- Images are served from the Supabase Storage.

### Reservation System
- Users can make reservations at restaurants.
- Reservations go through different statuses (pending, confirmed, cancelled, finished).

### Payment Integration
- The app integrates with Momo for payment processing.
- In the test environment, all payments will be simulated without actual money transfer.

## Troubleshooting

- If you encounter authentication issues, make sure your Supabase project's JWT secret is properly configured.
- For payment integration issues, check that your Momo credentials are correctly set and that you're using the test environment URLs.
- If images are not loading, verify that your Storage bucket policies are correctly set up to allow public access.

## Next Steps

- Implement Google Sign-In for additional authentication options.
- Add more analytics and reporting features.
- Expand payment options to include other providers.
- Implement push notifications for reservation updates. 