# Good Taste

A Flutter mobile application for restaurant reservations with Supabase backend and Momo payment integration.

## Features

- **Authentication**: Email and Google sign-in using Supabase Auth
- **Restaurant Browsing**: Browse restaurants with detailed information and photos
- **Menu Viewing**: See restaurant menus with dish descriptions and prices
- **Reservation Management**: Make, view, and cancel restaurant reservations
- **Real-time Updates**: Get instant updates on reservation status
- **Review System**: Leave reviews and ratings for restaurants
- **Payment Integration**: Secure payments via Momo payment gateway
- **User Profiles**: Manage user information and preferences

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL database, Auth, Storage, Realtime)
- **Payment**: Momo Payment Gateway
- **State Management**: Provider pattern
- **UI Components**: Material Design and custom widgets

## Project Structure

```
lib/
├── constants/           # App constants (colors, themes, env)
├── models/              # Data models
├── providers/           # State management providers
├── screens/             # App screens
├── services/            # Service classes for API calls
├── utils/               # Utility functions
├── widgets/             # Reusable UI components
└── main.dart            # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (2.10.0 or higher)
- Dart SDK (2.16.0 or higher)
- Android Studio / VS Code with Flutter plugins
- A Supabase account
- A Momo Business account (for payment integration)

### Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/good_taste.git
cd good_taste
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Supabase:
   - Follow the instructions in [docs/supabase_setup.md](docs/supabase_setup.md)
   - Update the Supabase URL and key in `lib/constants/env.dart`

4. Configure Momo Payment:
   - Follow the instructions in [docs/momo_payment_setup.md](docs/momo_payment_setup.md)
   - Update the Momo credentials in `lib/constants/env.dart`

5. Run the app:
```bash
flutter run
```

## Usage

### Authentication

Users can sign in using:
- Email and password
- Google account

### Restaurant Search and Booking

1. Browse the list of restaurants on the home screen
2. View restaurant details, including menu and reviews
3. Select a date and time for reservation
4. Enter guest information
5. Confirm reservation details
6. Make payment via Momo
7. Receive confirmation

### Reservation Management

1. View all reservations on the "Your Reservations" screen
2. See reservation status (Pending, Confirmed, Finished, Cancelled)
3. Cancel reservations if needed
4. Leave reviews for completed reservations

## Environment Configuration

Create a file named `env.dart` in `lib/constants/` with the following structure:

```dart
class Env {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Momo Payment Configuration
  static const String momoPartnerCode = 'YOUR_MOMO_PARTNER_CODE';
  static const String momoAccessKey = 'YOUR_MOMO_ACCESS_KEY';
  static const String momoSecretKey = 'YOUR_MOMO_SECRET_KEY';
  static const String momoApiEndpoint = 'YOUR_MOMO_API_ENDPOINT';
  static const String momoIpnUrl = 'YOUR_MOMO_IPN_URL';
  static const String momoRedirectUrl = 'YOUR_MOMO_REDIRECT_URL';
}
```

## Documentation

- [Supabase Setup Guide](docs/supabase_setup.md)
- [Momo Payment Integration Guide](docs/momo_payment_setup.md)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Flutter](https://flutter.dev/)
- [Supabase](https://supabase.io/)
- [Momo Payment](https://developers.momo.vn/)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Rating Bar](https://pub.dev/packages/flutter_rating_bar)
- [Cached Network Image](https://pub.dev/packages/cached_network_image)
- All the contributors who have helped this project
