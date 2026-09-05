class AppValidators {
  AppValidators._();

  static String? required(
      String? value,
      String fieldName,
      ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  static String? minLength(
      String? value,
      String fieldName,
      int length,
      ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().length < length) {
      return '$fieldName must be at least $length characters';
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final pattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!pattern.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact number is required';
    }

    final cleaned = value.replaceAll(
      RegExp(r'[\s\-]'),
      '',
    );

    final pattern = RegExp(
      r'^(?:\+92|0092|0)3[0-9]{9}$',
    );

    if (!pattern.hasMatch(cleaned)) {
      return 'Enter a valid Pakistani phone number';
    }

    return null;
  }
}