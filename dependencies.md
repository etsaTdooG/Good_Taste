# Gota Restaurant App Dependencies

## Overview
This document lists all dependencies and their versions used in the Gota Restaurant App project. These libraries provide various functionalities from authentication, database management, to UI components.

## Environment
- Flutter SDK: >=3.0.0 <4.0.0
- Dart SDK: Implicit with Flutter SDK version

## Core Dependencies

### Flutter Base
- `flutter`: Flutter framework
- `cupertino_icons`: ^1.0.8 - iOS style icons

### Backend and Authentication
- `supabase_flutter`: ^2.3.4 - Supabase client library for Flutter
- `crypto`: ^3.0.3 - Cryptographic hashing functions

### State Management
- `provider`: ^6.1.2 - State management solution

### UI Components and Styling
- `flutter_rating_bar`: ^4.0.1 - Rating widget
- `intl`: ^0.19.0 - Internationalization and formatting
- `cached_network_image`: ^3.3.1 - Caching network images for better performance

### Navigation and Web Integration
- `url_launcher`: ^6.2.5 - Opening URLs in browsers
- `http`: ^1.2.0 - HTTP requests
- `webview_flutter`: ^4.7.0 - Embedded web content

### Utilities
- `uuid`: ^4.2.2 - Generating unique identifiers
- `shared_preferences`: ^2.2.2 - Persistent storage
- `image_picker`: ^1.0.7 - Selecting images from gallery or camera

## Development Dependencies
- `flutter_test`: Testing utilities
- `flutter_lints`: ^3.0.1 - Linting rules for code quality

## Libraries Identified in Code
The following libraries are referenced in the codebase but may not be explicitly defined in the pubspec.yaml:

- `dotenv`: Environment variable management (referred to in supabase_service.dart but may not be properly installed)
- `convert`: Data conversion utilities (referred to in supabase_service.dart but may not be properly installed)

## Note on Missing Libraries
Some libraries that appear in the code imports may need to be added to the pubspec.yaml file:

```yaml
dependencies:
  # Add these if they're missing
  flutter_dotenv: ^5.1.0  # Instead of the "dotenv" package
  # The "convert" package is part of the Dart SDK, no need to add it separately
```

## Current Version Status
Based on the output of `flutter pub outdated`:

- **Outdated Direct Dependencies:**
  - `intl`: Current version 0.19.0, latest version 0.20.2

- **Outdated Dev Dependencies:**
  - `flutter_lints`: Current version 3.0.2, latest version 5.0.0

- **Outdated Transitive Dependencies:**
  - `async`: Current version 2.12.0, latest version 2.13.0
  - `material_color_utilities`: Current version 0.11.1, latest version 0.12.0 