class ValidationService {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (name.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    return null;
  }

  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[^0-9]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required';
    }
    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (username.length > 20) {
      return 'Username must not exceed 20 characters';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  static String? validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'URL is required';
    }
    try {
      Uri.parse(url);
      return null;
    } catch (e) {
      return 'Please enter a valid URL';
    }
  }

  static String? validateTamilText(String? text) {
    if (text == null || text.isEmpty) {
      return 'Text is required';
    }
    final tamilRegex = RegExp(r'[\u0B80-\u0BFF]');
    if (!tamilRegex.hasMatch(text)) {
      return 'Please enter valid Tamil text';
    }
    return null;
  }

  static String? validateAge(int? age) {
    if (age == null) {
      return 'Age is required';
    }
    if (age < 4) {
      return 'Age must be at least 4 years';
    }
    if (age > 120) {
      return 'Please enter a valid age';
    }
    return null;
  }

  static String? validateClassroomName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Classroom name is required';
    }
    if (name.length < 3) {
      return 'Classroom name must be at least 3 characters';
    }
    if (name.length > 50) {
      return 'Classroom name must not exceed 50 characters';
    }
    return null;
  }

  static String? validateDescription(String? description) {
    if (description == null || description.isEmpty) {
      return 'Description is required';
    }
    if (description.length < 10) {
      return 'Description must be at least 10 characters';
    }
    if (description.length > 500) {
      return 'Description must not exceed 500 characters';
    }
    return null;
  }

  static bool isStrongPassword(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasDigits && hasSpecialChar;
  }

  static String getPasswordStrength(String password) {
    if (password.length < 6) return 'Weak';
    if (isStrongPassword(password)) return 'Strong';
    return 'Medium';
  }

  static bool isValidTamilWord(String word) {
    final tamilRegex = RegExp(r'^[\u0B80-\u0BFF]+$');
    return tamilRegex.hasMatch(word);
  }

  static String? validateScore(int? score) {
    if (score == null) {
      return 'Score is required';
    }
    if (score < 0 || score > 100) {
      return 'Score must be between 0 and 100';
    }
    return null;
  }

  static String? validateLevel(int? level) {
    if (level == null) {
      return 'Level is required';
    }
    if (level < 1 || level > 100) {
      return 'Level must be between 1 and 100';
    }
    return null;
  }
}
