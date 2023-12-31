import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/domain/model/user.dart';
import 'package:flutter_chat_app/domain/repository/auth_repository.dart';
import 'package:flutter_chat_app/domain/repository/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  User? _user; // Store the current user
  User? get currentUser =>
      _user; // Add getter methods to access user-related information

  bool isSignInLoading = false;
  bool isSignUpLoading = false;

  String? signInErrorMessage;
  String? signUpErrorMessage;

  AuthProvider({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository {
    _auth.authStateChanges().listen((user) {
      _getCurrentUserData(user);
    });
  }

  void _getCurrentUserData(auth.User? authUser) async {
    if (authUser == null) {
      _user = null;
    } else {
      final result = await _userRepository.getUserDataById(id: authUser.uid);
      result.fold(
        (_) {
          _user = null;
        },
        (user) {
          _user = user;
        },
      );
    }

    notifyListeners();
  }

  Future<User?> getUserData(String id) async {
    final result = await _userRepository.getUserDataById(id: id);
    User? userData;
    result.fold((l) => null, (user) => userData = user);
    return userData;
  }

  void signOut() {
    _authRepository.signOut();
  }

  Future<String?> signIn(String email, String password) async {
    isSignInLoading = true;
    notifyListeners();

    final result =
        await _authRepository.signIn(email: email, password: password);

    result.fold(
      (failure) {
        signInErrorMessage = failure.message;
      },
      (_) => {},
    );

    isSignInLoading = false;
    notifyListeners();

    return signInErrorMessage;
  }

  Future<String?> signUp(String email, String password, String fullName) async {
    isSignUpLoading = true;
    notifyListeners();

    final result = await _authRepository.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );

    result.fold(
      (failure) {
        signUpErrorMessage = failure.message;
      },
      (_) => {},
    );

    isSignUpLoading = false;
    notifyListeners();

    return signUpErrorMessage;
  }

  Future<void> uploadProfileImage(File imageFile, String userId) async {
    print('upload image starting');
    final result = await _userRepository.uploadProfilePicture(
      imageFile: imageFile,
      uid: userId,
    );

    result.fold(
      (failure) => null,
      (user) {
        _user = user;
        notifyListeners();
      },
    );
  }

  Future updateUserFullName(String fullName) async {
    if (currentUser != null) {
      final result = await _userRepository.updateUserFullName(
        uid: currentUser!.id,
        fullName: fullName,
      );

      result.fold(
        (l) => null,
        (user) {
          _user = user;
          notifyListeners();
        },
      );
    }
  }
}
