import 'package:intl/intl.dart';

String getFormattedDateTime(DateTime dateTime) {
  return DateFormat.jm().format(dateTime);
}

String? validateEmail(String? value) {
  // Regular expression for email validation
  final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

  if (value == null || value.isEmpty) {
    return 'Email is required';
  }

  if (!emailRegExp.hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? validatePassword(String? value) {
  final passwordRegExp = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$');
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }

  if (!passwordRegExp.hasMatch(value)) {
    return 'Password must be at least 6 characters\ninclude an uppercase letter and number';
  }

  return null;
}

String? validateConfirmPassword(String? value, String? password) {
  if (value == null || value.isEmpty) {
    return 'Please re-enter your password';
  }

  if (value != password) {
    return 'Your password don\'t match';
  }

  return null;
}

String? validateFullName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Your full name is required';
  }

  return null;
}
