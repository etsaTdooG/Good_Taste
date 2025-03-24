import 'package:intl/intl.dart';

class DateTimeUtils {
  // Format date to display (e.g., "May 15, 2023")
  static String formatDate(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }
  
  // Format time to display (e.g., "7:30 PM")
  static String formatTime(String time) {
    // Time is stored as HH:MM in 24-hour format
    try {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      final dateTime = DateTime(2023, 1, 1, hour, minute);
      return DateFormat.jm().format(dateTime);
    } catch (e) {
      return time;
    }
  }
  
  // Get available time slots for reservation
  static List<String> getAvailableTimeSlots() {
    // Restaurant operates from 10:00 AM to 10:00 PM with 30-minute intervals
    const openHour = 10; // 10:00 AM
    const closeHour = 22; // 10:00 PM
    
    final List<String> timeSlots = [];
    
    for (int hour = openHour; hour < closeHour; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final formattedHour = hour.toString().padLeft(2, '0');
        final formattedMinute = minute.toString().padLeft(2, '0');
        timeSlots.add('$formattedHour:$formattedMinute');
      }
    }
    
    return timeSlots;
  }
  
  // Format date for API (e.g., "2023-05-15")
  static String formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // Format relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
} 