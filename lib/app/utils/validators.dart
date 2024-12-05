class Validator {
  /// Validates an email address.
  /// Returns `null` if valid, otherwise an error message.
  static String? validateEmail(String email) {
    const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (email.isEmpty) {
      return "Email can't be empty";
    } else if (!RegExp(emailRegex).hasMatch(email)) {
      return "Enter a valid email address";
    }
    return null;
  }

  /// Validates a password.
  /// Returns `null` if valid, otherwise an error message.
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return "Password can't be empty";
    } else if (password.length < 8) {
      return "Password must be at least 8 characters long";
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "Password must contain at least one uppercase letter";
    } else if (!RegExp(r'[a-z]').hasMatch(password)) {
      return "Password must contain at least one lowercase letter";
    } else if (!RegExp(r'\d').hasMatch(password)) {
      return "Password must contain at least one digit";
    }
    return null;
  }
}
