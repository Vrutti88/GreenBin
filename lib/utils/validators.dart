/// Centralized form field validation utilities for GreenBin.
class AppValidators {
  /// Validates an email address.
  ///
  /// Requirements:
  /// - Must not be empty.
  /// - Must not start with a number/digit (0-9).
  /// - Must start with an alphabet letter (a-z, A-Z).
  /// - Must follow standard email format (local@domain.tld).
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email.';
    }

    final trimmed = value.trim();

    // Disallow emails starting with a digit/number
    if (RegExp(r'^[0-9]').hasMatch(trimmed)) {
      return 'Email address cannot start with a number.';
    }

    // Must start with an alphabet letter
    if (!RegExp(r'^[a-zA-Z]').hasMatch(trimmed)) {
      return 'Email address must start with a letter.';
    }

    // Valid email pattern:
    // - Starts with a letter
    // - Allowed characters in local part: letters, digits, dots, underscores, percents, plus, hyphens
    // - Valid domain and top-level domain of at least 2 characters
    final emailRegex = RegExp(
      r'^[a-zA-Z][a-zA-Z0-9._%+-]*@[a-zA-Z0-9]+([.-][a-zA-Z0-9]+)*\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  /// Validates a user's full name.
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long.';
    }
    return null;
  }

  /// Validates a phone number.
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number.';
    }
    return null;
  }

  /// Validates a password.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }
}
