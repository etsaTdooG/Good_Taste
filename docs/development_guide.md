# Good Taste - Development Guide

This guide outlines the development practices, architecture, and conventions used in the Good Taste application.

## Table of Contents

1. [Project Architecture](#project-architecture)
2. [Code Style](#code-style)
3. [State Management](#state-management)
4. [Error Handling](#error-handling)
5. [Testing](#testing)
6. [Performance Considerations](#performance-considerations)
7. [Security Best Practices](#security-best-practices)
8. [Deployment Process](#deployment-process)
9. [Adding New Features](#adding-new-features)

## Project Architecture

The application follows a layered architecture pattern:

### Data Layer
- **Models**: Data classes representing application entities
- **Services**: Handle API communication and data operations
- **Repositories**: Combine multiple services when needed

### Business Logic Layer
- **Providers**: Manage state and business logic
- **Utils**: Helper functions and utilities

### Presentation Layer
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components

### Core Principles
- **Separation of Concerns**: Each class has a single responsibility
- **Dependency Injection**: Dependencies are injected rather than created internally
- **Immutability**: Models are immutable to prevent unexpected state changes

## Code Style

We follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style) and use the following conventions:

### Naming Conventions
- **Classes**: `PascalCase` (e.g., `RestaurantService`)
- **Variables/Functions**: `camelCase` (e.g., `fetchRestaurants`)
- **Constants**: `kConstantName` (e.g., `kPrimaryColor`)
- **Private Members**: Leading underscore (e.g., `_privateField`)
- **File Names**: `snake_case.dart` (e.g., `restaurant_service.dart`)

### File Organization
- One class per file (except for small related classes)
- Group related files in appropriate directories
- Import order: Dart SDK, External packages, Project imports (alphabetically)

### Documentation
- All public APIs should have dartdoc comments
- Include examples for complex functions
- Document parameters and return values

Example:
```dart
/// Fetches a list of restaurants based on search criteria
///
/// [query] is optional search text to filter restaurants by name
/// [filters] can include cuisine, price range, and rating
///
/// Returns a Future that completes with a list of [Restaurant] objects
/// Throws a [NetworkException] if the API request fails
Future<List<Restaurant>> fetchRestaurants({
  String? query,
  Map<String, dynamic>? filters,
}) async {
  // Implementation
}
```

## State Management

The application uses the Provider pattern for state management:

### Provider Guidelines
- Create a dedicated provider for each major feature
- Keep providers focused on specific functionality
- Use `ChangeNotifier` for simple cases
- Consider `StateNotifier` with `riverpod` for more complex state

### Provider Structure
- Define a clear state class
- Use immutable patterns when possible
- Provide methods to modify state
- Handle loading and error states consistently

Example:
```dart
class RestaurantState {
  final List<Restaurant> restaurants;
  final bool isLoading;
  final String? errorMessage;

  const RestaurantState({
    this.restaurants = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  RestaurantState copyWith({
    List<Restaurant>? restaurants,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RestaurantState(
      restaurants: restaurants ?? this.restaurants,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RestaurantProvider extends ChangeNotifier {
  RestaurantState _state = const RestaurantState();
  RestaurantState get state => _state;

  final RestaurantService _restaurantService;

  RestaurantProvider(this._restaurantService);

  Future<void> fetchRestaurants() async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final restaurants = await _restaurantService.fetchRestaurants();
      _state = _state.copyWith(restaurants: restaurants, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load restaurants: ${e.toString()}',
      );
    }
    
    notifyListeners();
  }
}
```

## Error Handling

### General Principles
- Handle errors at the appropriate level
- Provide meaningful error messages to users
- Log errors for debugging purposes
- Use typed exceptions when possible

### Exception Handling Pattern
- Catch specific exceptions first, then general ones
- Transform technical errors into user-friendly messages
- Always consider network failures and timeouts
- Use consistent UI patterns for error states

Example:
```dart
Future<void> makeReservation(Reservation reservation) async {
  try {
    await _reservationService.createReservation(reservation);
  } on AuthException catch (e) {
    // Handle authentication errors
    showErrorDialog('Please sign in again to continue');
  } on NetworkException catch (e) {
    // Handle network errors
    showErrorDialog('Network error. Please check your connection');
  } on ApiException catch (e) {
    // Handle API errors
    showErrorDialog('Could not complete reservation: ${e.message}');
  } catch (e) {
    // Handle unexpected errors
    showErrorDialog('An unexpected error occurred');
    logError(e); // Log for debugging
  }
}
```

### UI Error Presentation
- Use SnackBars for non-critical errors
- Use Dialog boxes for critical errors
- Provide retry options when appropriate
- Consider offline-first strategies for network errors

## Testing

### Test Types
- **Unit Tests**: Test individual classes and functions
- **Widget Tests**: Test UI components
- **Integration Tests**: Test feature workflows
- **Golden Tests**: Visual regression tests for widgets

### Test Organization
- Mirror the src directory structure in the test directory
- Name test files with `_test.dart` suffix
- Group related tests using the `group` function
- Use descriptive test names that explain the expected behavior

### Mocking
- Use `mockito` or `mocktail` for mocking dependencies
- Create mock classes for services and repositories
- Set up mocks in `setUp` blocks
- Verify important interactions with mocks

Example:
```dart
void main() {
  group('RestaurantProvider', () {
    late MockRestaurantService mockService;
    late RestaurantProvider provider;

    setUp(() {
      mockService = MockRestaurantService();
      provider = RestaurantProvider(mockService);
    });

    test('should load restaurants and update state', () async {
      // Arrange
      final restaurants = [
        Restaurant(id: '1', name: 'Test Restaurant'),
      ];
      when(mockService.fetchRestaurants())
          .thenAnswer((_) async => restaurants);

      // Act
      await provider.fetchRestaurants();

      // Assert
      expect(provider.state.isLoading, false);
      expect(provider.state.restaurants, restaurants);
      expect(provider.state.errorMessage, null);
      verify(mockService.fetchRestaurants()).called(1);
    });

    test('should handle errors when loading restaurants', () async {
      // Arrange
      when(mockService.fetchRestaurants())
          .thenThrow(Exception('Network error'));

      // Act
      await provider.fetchRestaurants();

      // Assert
      expect(provider.state.isLoading, false);
      expect(provider.state.restaurants, isEmpty);
      expect(provider.state.errorMessage, contains('Network error'));
      verify(mockService.fetchRestaurants()).called(1);
    });
  });
}
```

## Performance Considerations

### UI Performance
- Use `const` constructors whenever possible
- Implement pagination for long lists
- Use `ListView.builder` instead of `Column` for long lists
- Consider using `RepaintBoundary` to optimize repaints
- Minimize widget rebuilds (use selective updates with Provider)

### Network Optimization
- Implement caching strategies for API responses
- Use Supabase subscriptions for real-time updates rather than polling
- Consider batch operations for multiple updates
- Implement proper error retry strategies

### Image Optimization
- Use `CachedNetworkImage` for all remote images
- Implement proper image resizing and compression
- Use appropriate image formats (WebP when possible)
- Implement lazy loading for images

## Security Best Practices

### Authentication
- Always check authentication state before sensitive operations
- Implement proper token refresh mechanisms
- Don't store sensitive tokens in insecure storage
- Use secure storage for tokens (Flutter Secure Storage)

### Data Protection
- Never log sensitive information
- Validate all user inputs
- Use HTTPS for all API communication
- Implement proper Row Level Security in Supabase

### Supabase Security
- Follow the principle of least privilege for database roles
- Implement RLS policies for all tables
- Use parameterized queries to prevent SQL injection
- Regular security audits of RLS policies

### Payment Security
- Never store payment credentials in the app
- Use HTTPS for all payment-related communication
- Implement proper signature verification for callbacks
- Follow Momo security guidelines for payment processing

## Deployment Process

### Version Management
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Update version in `pubspec.yaml` for each release
- Create a git tag for each release
- Maintain a CHANGELOG.md file

### Release Process
1. Create a release branch from develop (e.g., `release/1.2.0`)
2. Update version numbers and finalize CHANGELOG.md
3. Perform final testing
4. Merge to main branch
5. Create a release tag
6. Merge back to develop branch

### App Store Submission
- Generate appropriate screenshots for stores
- Write compelling store descriptions
- Set up proper app signing
- Consider staged rollouts for major changes

## Adding New Features

### Feature Development Process
1. **Planning**: Define requirements and design
2. **Implementation**: Develop the feature in a feature branch
3. **Testing**: Add appropriate tests
4. **Code Review**: Submit a pull request for review
5. **Integration**: Merge to develop branch
6. **Release**: Include in the next release

### Example Workflow
For adding a new feature (e.g., restaurant favorites):

1. Create a feature branch: `git checkout -b feature/restaurant-favorites`
2. Create necessary models, services, and providers
3. Implement UI components
4. Add tests for each component
5. Submit a pull request
6. Address review comments
7. Merge when approved

### Feature Structure
A complete feature typically includes:
- Model classes for data representation
- Service class for API communication
- Provider for state management
- UI components (screens and widgets)
- Tests for all components

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Supabase Documentation](https://supabase.io/docs)
- [Provider Package Documentation](https://pub.dev/packages/provider)
- [Momo Payment Documentation](https://developers.momo.vn/) 