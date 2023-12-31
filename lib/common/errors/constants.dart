class FirebaseAuthConstants {
  // error codes
  static const String errorCodeInvalidCredentials = 'INVALID_LOGIN_CREDENTIALS';
  static const String errorCodeInvalidCredentialsLower = 'invalid-credential';
  static const String errorCodeTooManyRequest = 'too-many-requests';
  static const String errorCodeEmailAlreadyInUse = 'email-already-in-use';

  // error messages
  static const String errorMessageDefault =
      'Something went wrong. Please try again later.';
  static const String errorMessageInvalidCredentials =
      'Invalid email or password. Please check your signin information and try again.';
  static const String errorMessageTooManyRequest =
      'Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later.';
  static const String errorMessageEmailAlreadyInUse =
      'The email address is already in use by another account. Please provide a different email.';

  static String getAuthErrorMessage(String code) {
    switch (code) {
      case errorCodeInvalidCredentials:
        return errorMessageInvalidCredentials;
      case errorCodeInvalidCredentialsLower:
        return errorMessageInvalidCredentials;
      case errorCodeTooManyRequest:
        return errorMessageTooManyRequest;
      case errorCodeEmailAlreadyInUse:
        return errorMessageEmailAlreadyInUse;
      default:
        return errorMessageDefault;
    }
  }
}
