/// Input validation and sanitization utilities
/// Provides validation methods for user inputs to ensure data integrity and security
class InputValidator {
  /// Validates if a string is not empty and not just whitespace
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validates if a string is a valid number
  static bool isValidNumber(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return double.tryParse(value.trim()) != null;
  }

  /// Validates if a string is a valid integer
  static bool isValidInteger(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return int.tryParse(value.trim()) != null;
  }

  /// Validates if a number is within a specific range
  static bool isInRange(double? value, double min, double max) {
    if (value == null) return false;
    return value >= min && value <= max;
  }

  /// Validates if a string length is within specified limits
  static bool isValidLength(String? value, {int? minLength, int? maxLength}) {
    if (value == null) return false;
    final length = value.trim().length;
    
    if (minLength != null && length < minLength) return false;
    if (maxLength != null && length > maxLength) return false;
    
    return true;
  }

  /// Validates if a string is a valid email format
  static bool isValidEmail(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    return emailRegex.hasMatch(value.trim());
  }

  /// Validates if a string is a valid phone number (basic validation)
  static bool isValidPhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(value.trim().replaceAll(RegExp(r'[\s-]'), ''));
  }

  /// Sanitizes a string by trimming and removing dangerous characters
  static String sanitize(String? value) {
    if (value == null) return '';
    
    // Trim whitespace
    String sanitized = value.trim();
    
    // Remove potentially dangerous characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>\"\'&]'), '');
    
    return sanitized;
  }

  /// Validates and sanitizes numeric input
  static double? parseAndValidateDouble(
    String? value, {
    double? min,
    double? max,
    double? defaultValue,
  }) {
    if (value == null || value.trim().isEmpty) return defaultValue;
    
    final parsedValue = double.tryParse(value.trim());
    if (parsedValue == null) return defaultValue;
    
    if (min != null && parsedValue < min) return defaultValue;
    if (max != null && parsedValue > max) return defaultValue;
    
    return parsedValue;
  }

  /// Validates and sanitizes integer input
  static int? parseAndValidateInt(
    String? value, {
    int? min,
    int? max,
    int? defaultValue,
  }) {
    if (value == null || value.trim().isEmpty) return defaultValue;
    
    final parsedValue = int.tryParse(value.trim());
    if (parsedValue == null) return defaultValue;
    
    if (min != null && parsedValue < min) return defaultValue;
    if (max != null && parsedValue > max) return defaultValue;
    
    return parsedValue;
  }

  /// Validates percentage value (0-100)
  static bool isValidPercentage(double? value) {
    return isInRange(value, 0, 100);
  }

  /// Validates time in hours (0-24)
  static bool isValidHours(int? value) {
    if (value == null) return false;
    return value >= 0 && value <= 24;
  }

  /// Validates time in minutes (0-59)
  static bool isValidMinutes(int? value) {
    if (value == null) return false;
    return value >= 0 && value <= 59;
  }

  /// Validates time in seconds (0-59)
  static bool isValidSeconds(int? value) {
    if (value == null) return false;
    return value >= 0 && value <= 59;
  }

  /// Validates if a date is not in the future
  static bool isNotFutureDate(DateTime? date) {
    if (date == null) return false;
    return !date.isAfter(DateTime.now());
  }

  /// Validates if a date is within a specific range
  static bool isDateInRange(DateTime? date, DateTime start, DateTime end) {
    if (date == null) return false;
    return date.isAfter(start.subtract(const Duration(days: 1))) && 
           date.isBefore(end.add(const Duration(days: 1)));
  }

  /// Generates error message for validation failures
  static String getErrorMessage(String fieldName, String validationType) {
    switch (validationType) {
      case 'required':
        return '$fieldName is required';
      case 'invalid_number':
        return '$fieldName must be a valid number';
      case 'invalid_email':
        return '$fieldName must be a valid email address';
      case 'out_of_range':
        return '$fieldName is out of valid range';
      case 'too_short':
        return '$fieldName is too short';
      case 'too_long':
        return '$fieldName is too long';
      case 'future_date':
        return '$fieldName cannot be a future date';
      default:
        return '$fieldName is invalid';
    }
  }
}
