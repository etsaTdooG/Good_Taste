# Gota Restaurant - Mobile Reservation App

A Flutter mobile app for restaurant reservations with Supabase backend and Momo payment integration.

## Features

- **User Authentication**: Email-based login and registration
- **Restaurant Discovery**: Browse restaurants and view their details
- **Menu Exploration**: View dishes and menu items for each restaurant
- **Table Reservation**: Complete reservation flow with date, time, and party size selection
- **Online Payment**: Integrated Momo payment gateway for processing reservation payments
- **Reservation Management**: View, modify, and cancel reservations
- **Reviews & Ratings**: Submit and read reviews for restaurants

## Technologies

- **Flutter**: UI framework for building the mobile application
- **Supabase**: Backend as a Service for:
  - Authentication
  - Database (PostgreSQL)
  - Real-time updates
  - Storage for images
- **Momo Payment Gateway**: For processing payments (test environment)
- **Provider**: For state management

## Getting Started

For detailed setup instructions, please refer to the following documentation:

- [Setup Guide](lib/docs/setup_guide.md)
- [Supabase SQL Setup](lib/docs/supabase_sql_setup.md)
- [Momo Integration Guide](lib/docs/momo_integration_guide.md)
- [Implementation Summary](lib/docs/implementation_summary.md)

## App Structure

The app follows a structured architecture:

```
lib/
├── config/               # App configuration
├── docs/                 # Documentation
├── models/               # Data models
├── screens/              # App screens
├── services/             # Backend services
├── utils/                # Utility functions and themes
├── widgets/              # Reusable widgets
└── main.dart             # App entry point
```

## Screenshots

*Screenshots coming soon*

## Requirements

- Flutter 3.7.0 or higher
- Dart 3.0.0 or higher
- Android: minSdkVersion 21
- iOS: iOS 11.0 or higher

## Installation

1. Clone the repository:
```
git clone <repository-url>
```

2. Install dependencies:
```
cd gota
flutter pub get
```

3. Configure Supabase credentials in `lib/config/supabase_config.dart`

4. Run the app:
```
flutter run
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Supabase for providing an excellent backend service
- Momo for their payment gateway integration
