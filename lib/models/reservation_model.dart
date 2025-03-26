enum ReservationStatus {
  pending,
  confirmed,
  cancelled,
  completed
}

extension ReservationStatusExtension on ReservationStatus {
  String get name {
    switch (this) {
      case ReservationStatus.pending:
        return 'Đang chờ';
      case ReservationStatus.confirmed:
        return 'Đã xác nhận';
      case ReservationStatus.cancelled:
        return 'Đã hủy';
      case ReservationStatus.completed:
        return 'Hoàn thành';
    }
  }
}

class Reservation {
  final String id;
  final String restaurantId;
  final String userId;
  final DateTime date;
  final String time;
  final int numberOfPeople;
  final String? notes;
  final ReservationStatus status;
  final DateTime createdAt;
  final String? paymentId;
  
  // Extra fields for UI convenience
  final String? restaurantName;
  final String? restaurantImageUrl;
  
  Reservation({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.date,
    required this.time,
    required this.numberOfPeople,
    this.notes,
    required this.status,
    required this.createdAt,
    this.paymentId,
    this.restaurantName,
    this.restaurantImageUrl,
  });
  
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      time: json['time'] ?? '',
      numberOfPeople: json['number_of_people'],
      notes: json['notes'],
      status: _statusFromString(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      paymentId: json['payment_id'],
      restaurantName: json['restaurant_name'],
      restaurantImageUrl: json['restaurant_image_url'],
    );
  }
  
  static ReservationStatus _statusFromString(String? status) {
    switch (status) {
      case 'confirmed':
        return ReservationStatus.confirmed;
      case 'cancelled':
        return ReservationStatus.cancelled;
      case 'completed':
        return ReservationStatus.completed;
      case 'pending':
      default:
        return ReservationStatus.pending;
    }
  }
  
  static String statusToString(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed:
        return 'confirmed';
      case ReservationStatus.cancelled:
        return 'cancelled';
      case ReservationStatus.completed:
        return 'completed';
      case ReservationStatus.pending:
        return 'pending';
    }
  }
  
  String getStatusDisplay() {
    switch (status) {
      case ReservationStatus.confirmed:
        return 'Đã xác nhận';
      case ReservationStatus.cancelled:
        return 'Đã hủy';
      case ReservationStatus.completed:
        return 'Hoàn thành';
      case ReservationStatus.pending:
        return 'Đang chờ';
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'time': time,
      'number_of_people': numberOfPeople,
      'notes': notes,
      'status': statusToString(status),
      'created_at': createdAt.toIso8601String(),
      'payment_id': paymentId,
    };
  }
  
  @override
  String toString() => 'Reservation(id: $id, date: $date, status: $status)';

  Reservation copyWith({
    String? id,
    String? restaurantId,
    String? userId,
    DateTime? date,
    String? time,
    int? numberOfPeople,
    String? notes,
    ReservationStatus? status,
    DateTime? createdAt,
    String? paymentId,
    String? restaurantName,
    String? restaurantImageUrl,
  }) {
    return Reservation(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      time: time ?? this.time,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      notes: notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paymentId: paymentId,
      restaurantName: restaurantName,
      restaurantImageUrl: restaurantImageUrl,
    );
  }
} 