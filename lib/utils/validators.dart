class Validators {
  // Email validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  // Name validator
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }
  
  // Phone number validator
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  // Reservation date validator
  static String? validateReservationDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(value.year, value.month, value.day);
    
    if (selectedDate.isBefore(today)) {
      return 'Cannot select a past date';
    }
    
    if (selectedDate.isAfter(today.add(const Duration(days: 30)))) {
      return 'Cannot book more than 30 days in advance';
    }
    
    return null;
  }
  
  // Number of people validator
  static String? validateNumberOfPeople(String? value) {
    if (value == null || value.isEmpty) {
      return 'Number of people is required';
    }
    
    final numberOfPeople = int.tryParse(value);
    if (numberOfPeople == null) {
      return 'Please enter a valid number';
    }
    
    if (numberOfPeople < 1) {
      return 'Number of people must be at least 1';
    }
    
    if (numberOfPeople > 20) {
      return 'Number of people cannot exceed 20';
    }
    
    return null;
  }
  
  // Review rating validator
  static String? validateRating(double? value) {
    if (value == null || value <= 0) {
      return 'Please provide a rating';
    }
    
    return null;
  }
  
  // Review comment validator
  static String? validateComment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Comment is required';
    }
    
    if (value.length < 5) {
      return 'Comment must be at least 5 characters';
    }
    
    return null;
  }
} 