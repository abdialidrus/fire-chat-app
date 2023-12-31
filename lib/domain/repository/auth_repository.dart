import 'package:flutter_chat_app/common/util/typedef.dart';

abstract class AuthRepository {
  const AuthRepository();

  FutureResultVoid signIn({
    required String email,
    required String password,
  });

  FutureResultVoid signOut();

  FutureResultVoid signUp({
    required String email,
    required String password,
    required String fullName,
  });
}
