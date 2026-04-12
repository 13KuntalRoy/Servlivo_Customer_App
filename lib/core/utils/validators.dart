class Validators {
  Validators._();

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 13) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) return 'OTP is required';
    if (value.length != 6) return 'OTP must be 6 digits';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'OTP must contain only digits';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    if (value.trim().length > 50) return 'Name too long';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null; // email is optional
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? requiredEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    return email(value);
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final err = password(value);
    if (err != null) return err;
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? pinCode(String? value) {
    if (value == null || value.isEmpty) return 'PIN code is required';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'Enter a valid 6-digit PIN code';
    return null;
  }

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.isEmpty) return 'Amount is required';
    final n = double.tryParse(value);
    if (n == null || n <= 0) return 'Enter a valid amount';
    return null;
  }
}
