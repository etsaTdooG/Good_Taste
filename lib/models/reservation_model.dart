class ReservationModel {
  final String id;
  final String userId;
  final String restaurantId;
  final DateTime date;
  final String time;
  final int numberOfPeople;
  final String? notes;
  final String status; // Pending, Confirmed, Finished, Cancelled
  final String? restaurantName;
  
  ReservationModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.date,
    required this.time,
    required this.numberOfPeople,
    this.notes,
    required this.status,
    this.restaurantName,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'],
      userId: json['user_id'],
      restaurantId: json['restaurant_id'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      numberOfPeople: json['number_of_people'],
      notes: json['notes'],
      status: json['status'],
      restaurantName: json['restaurant_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'date': date.toIso8601String().split('T')[0],
      'time': time,
      'number_of_people': numberOfPeople,
      'notes': notes,
      'status': status,
    };
  }

  ReservationModel copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    DateTime? date,
    String? time,
    int? numberOfPeople,
    String? notes,
    String? status,
    String? restaurantName,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      date: date ?? this.date,
      time: time ?? this.time,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      restaurantName: restaurantName ?? this.restaurantName,
    );
  }
} 