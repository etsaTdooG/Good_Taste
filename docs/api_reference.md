# Good Taste API Reference

This document provides reference information for the Supabase APIs used in the Good Taste application.

## Authentication API

### Sign Up with Email

```dart
Future<AuthResponse> signUpWithEmail(String email, String password) async {
  return await _supabase.auth.signUp(
    email: email,
    password: password,
  );
}
```

**Parameters:**
- `email`: User's email address
- `password`: User's password (must meet security requirements)

**Returns:**
- `AuthResponse` containing user information or error details

### Sign In with Email

```dart
Future<AuthResponse> signInWithEmail(String email, String password) async {
  return await _supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );
}
```

**Parameters:**
- `email`: User's email address
- `password`: User's password

**Returns:**
- `AuthResponse` containing user information or error details

### Sign In with Google

```dart
Future<AuthResponse> signInWithGoogle() async {
  return await _supabase.auth.signInWithOAuth(
    Provider.google,
    redirectTo: kIsWeb ? null : 'io.supabase.goodtaste://login-callback',
  );
}
```

**Returns:**
- `AuthResponse` containing user information or error details

### Sign Out

```dart
Future<void> signOut() async {
  await _supabase.auth.signOut();
}
```

## User API

### Get Current User

```dart
User? getCurrentUser() {
  return _supabase.auth.currentUser;
}
```

**Returns:**
- `User?` object or null if not authenticated

### Update User Profile

```dart
Future<void> updateUserProfile({
  required String id,
  String? name,
  String? phoneNumber,
  String? avatarUrl,
}) async {
  await _supabase.from('users').upsert({
    'id': id,
    'name': name,
    'phone_number': phoneNumber,
    'avatar_url': avatarUrl,
    'updated_at': DateTime.now().toIso8601String(),
  });
}
```

**Parameters:**
- `id`: User ID (from auth)
- `name`: User's full name (optional)
- `phoneNumber`: User's phone number (optional)
- `avatarUrl`: URL to user's avatar image (optional)

## Restaurant API

### Fetch Restaurants

```dart
Future<List<RestaurantModel>> fetchRestaurants({
  String? searchQuery,
  Map<String, dynamic>? filters,
}) async {
  var query = _supabase.from('restaurants').select('*');
  
  if (searchQuery != null && searchQuery.isNotEmpty) {
    query = query.ilike('name', '%$searchQuery%');
  }
  
  if (filters != null) {
    // Apply filters based on the filters map
  }
  
  final response = await query;
  return response.map((json) => RestaurantModel.fromJson(json)).toList();
}
```

**Parameters:**
- `searchQuery`: Optional search text to filter restaurants (optional)
- `filters`: Optional map of filter criteria (optional)

**Returns:**
- List of `RestaurantModel` objects

### Get Restaurant Details

```dart
Future<RestaurantModel?> getRestaurantById(String id) async {
  final response = await _supabase
      .from('restaurants')
      .select('*')
      .eq('id', id)
      .single();
  
  return response != null ? RestaurantModel.fromJson(response) : null;
}
```

**Parameters:**
- `id`: Restaurant ID

**Returns:**
- `RestaurantModel?` or null if not found

### Get Restaurant Dishes

```dart
Future<List<DishModel>> getRestaurantDishes(String restaurantId) async {
  final response = await _supabase
      .from('dishes')
      .select('*')
      .eq('restaurant_id', restaurantId);
  
  return response.map((json) => DishModel.fromJson(json)).toList();
}
```

**Parameters:**
- `restaurantId`: Restaurant ID

**Returns:**
- List of `DishModel` objects

### Get Restaurant Reviews

```dart
Future<List<ReviewModel>> getRestaurantReviews(String restaurantId) async {
  final response = await _supabase
      .from('reviews')
      .select('*, users(name)')
      .eq('restaurant_id', restaurantId)
      .order('created_at', ascending: false);
  
  return response.map((json) => ReviewModel.fromJson(json)).toList();
}
```

**Parameters:**
- `restaurantId`: Restaurant ID

**Returns:**
- List of `ReviewModel` objects with user information

## Reservation API

### Create Reservation

```dart
Future<String> createReservation({
  required String userId,
  required String restaurantId,
  required DateTime date,
  required String time,
  required int numberOfPeople,
  String? notes,
  required String restaurantName,
  required int amount,
}) async {
  final response = await _supabase.from('reservations').insert({
    'user_id': userId,
    'restaurant_id': restaurantId,
    'date': date.toIso8601String().split('T')[0],
    'time': time,
    'number_of_people': numberOfPeople,
    'notes': notes,
    'status': 'Pending',
    'created_at': DateTime.now().toIso8601String(),
  }).select('id').single();
  
  return response['id'];
}
```

**Parameters:**
- `userId`: User ID
- `restaurantId`: Restaurant ID
- `date`: Reservation date
- `time`: Reservation time
- `numberOfPeople`: Number of people for the reservation
- `notes`: Optional notes for the reservation (optional)
- `restaurantName`: Name of the restaurant (for payment description)
- `amount`: Payment amount in smallest currency unit

**Returns:**
- Reservation ID

### Get User Reservations

```dart
Future<List<ReservationModel>> getUserReservations(String userId) async {
  final response = await _supabase
      .from('reservations')
      .select('*, restaurants(name)')
      .eq('user_id', userId)
      .order('date', ascending: true)
      .order('time', ascending: true);
  
  return response.map((json) => ReservationModel.fromJson(json)).toList();
}
```

**Parameters:**
- `userId`: User ID

**Returns:**
- List of `ReservationModel` objects with restaurant information

### Cancel Reservation

```dart
Future<bool> cancelReservation(String reservationId) async {
  await _supabase
      .from('reservations')
      .update({'status': 'Cancelled'})
      .eq('id', reservationId);
  
  return true;
}
```

**Parameters:**
- `reservationId`: Reservation ID

**Returns:**
- `true` if successful

## Review API

### Add Review

```dart
Future<bool> addReview({
  required String userId,
  required String restaurantId,
  required double rating,
  required String comment,
}) async {
  await _supabase.from('reviews').insert({
    'user_id': userId,
    'restaurant_id': restaurantId,
    'rating': rating,
    'comment': comment,
    'created_at': DateTime.now().toIso8601String(),
  });
  
  return true;
}
```

**Parameters:**
- `userId`: User ID
- `restaurantId`: Restaurant ID
- `rating`: Rating value (1-5)
- `comment`: Review comment text

**Returns:**
- `true` if successful

## Payment API

### Process Momo Payment

```dart
Future<Map<String, dynamic>> processMomoPayment({
  required String reservationId,
  required String restaurantName,
  required double amount,
}) async {
  // Generate order info
  final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
  final requestId = 'RQ_${DateTime.now().millisecondsSinceEpoch}';
  final orderInfo = 'Reservation at $restaurantName';
  
  // Generate signature and payment request
  // ... implementation details ...
  
  // Store payment information
  await _storePaymentInfo(reservationId, orderId, requestId, amount);
  
  return {
    'payUrl': paymentUrl,
    'orderId': orderId,
    'requestId': requestId,
  };
}
```

**Parameters:**
- `reservationId`: Reservation ID
- `restaurantName`: Restaurant name
- `amount`: Payment amount

**Returns:**
- Map containing payment URL and IDs

### Update Payment Status

```dart
Future<void> updatePaymentStatus({
  required String orderId,
  required String status,
  String? transactionId,
}) async {
  await _supabase
      .from('payments')
      .update({
        'status': status,
        'transaction_id': transactionId,
        'updated_at': DateTime.now().toIso8601String(),
      })
      .eq('order_id', orderId);
}
```

**Parameters:**
- `orderId`: Order ID
- `status`: Payment status ('completed', 'failed', etc.)
- `transactionId`: Transaction ID from payment provider (optional)

## Realtime Subscriptions

### Subscribe to Reservation Changes

```dart
RealtimeChannel subscribeToReservations(String userId, Function(List<ReservationModel>) callback) {
  final channel = _supabase
      .channel('reservations_channel')
      .on(
        RealtimeListenTypes.postgresChanges,
        SupabaseRealtimePayload(
          schema: 'public',
          table: 'reservations',
          filter: 'user_id=eq.$userId',
        ),
        (payload, [ref]) async {
          final reservations = await getUserReservations(userId);
          callback(reservations);
        },
      )
      .subscribe();
  
  return channel;
}
```

**Parameters:**
- `userId`: User ID
- `callback`: Function to call when reservations change

**Returns:**
- `RealtimeChannel` object that can be used to unsubscribe

### Unsubscribe from Channel

```dart
Future<void> unsubscribeFromChannel(RealtimeChannel channel) async {
  await _supabase.removeChannel(channel);
}
```

**Parameters:**
- `channel`: Channel to unsubscribe from

## Storage API

### Upload Image

```dart
Future<String> uploadImage(String bucket, String path, Uint8List fileBytes) async {
  await _supabase.storage.from(bucket).uploadBinary(path, fileBytes);
  return _supabase.storage.from(bucket).getPublicUrl(path);
}
```

**Parameters:**
- `bucket`: Storage bucket name
- `path`: File path within bucket
- `fileBytes`: File data as bytes

**Returns:**
- Public URL of the uploaded image

### Delete Image

```dart
Future<void> deleteImage(String bucket, String path) async {
  await _supabase.storage.from(bucket).remove([path]);
}
```

**Parameters:**
- `bucket`: Storage bucket name
- `path`: File path within bucket 