import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_chat_app/common/errors/exception.dart';

abstract class AuthRemoteDataSource {
  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firebaseFirestore,
  });

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseException catch (e) {
      throw APIException(
        message: e.message ?? 'Unexpected error occurs',
        statusCode: e.code,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseException catch (e) {
      throw APIException(
        message: e.message ?? 'Unexpected error occurs',
        statusCode: e.code,
      );
    }
  }

  @override
  Future<void> signUp(
      {required String email,
      required String password,
      required String fullName}) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const APIException(
          message: 'User not found',
          statusCode: '505',
        );
      }

      final userMap = <String, dynamic>{
        'uid': userCredential.user!.uid,
        'fullName': fullName,
        'email': email,
        'isOnline': false,
        'createdAt': Timestamp.now(),
      };

      await firebaseFirestore.collection('users').add(userMap);
    } on FirebaseException catch (e) {
      throw APIException(
        message: e.message ?? 'Unexpected error occurs',
        statusCode: e.code,
      );
    }
  }
}
