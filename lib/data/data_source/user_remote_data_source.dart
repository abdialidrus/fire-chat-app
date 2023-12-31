import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_app/common/errors/exception.dart';
import 'package:flutter_chat_app/domain/model/user.dart';

abstract class UserRemoteDataSource {
  Future<User?> getUserById({required String id});
  Future<List<User>> getOtherUsers({required String selfId});
  Future<void> updateUserStatus(
      {required String userId, required bool isOnline});
  Future<User?> uploadProfilePicture(
      {required File imageFile, required String uid});
  Future<User?> updateUserFullName(
      {required String uid, required String fullName});
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final userCollection = 'users';

  UserRemoteDataSourceImpl({required this.firestore, required this.storage});

  @override
  Future<User?> getUserById({required String id}) async {
    try {
      final usersSnapshot = await firestore
          .collection(userCollection)
          .where('uid', isEqualTo: id)
          .get();

      return usersSnapshot.docs
          .map((doc) => User.fromDocumentMap(doc.data()))
          .toList()
          .firstOrNull;
    } on FirebaseException catch (e) {
      throw APIException(
        message: e.message ?? 'Unexpected error occurs',
        statusCode: e.code,
      );
    }
  }

  @override
  Future<List<User>> getOtherUsers({required selfId}) async {
    try {
      final usersSnapshot = await firestore
          .collection(userCollection)
          .where('uid', isNotEqualTo: selfId)
          .get();

      return usersSnapshot.docs
          .map((doc) => User.fromDocumentMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw APIException(
        message: e.message ?? 'Unexpected error occurs',
        statusCode: e.code,
      );
    }
  }

  @override
  Future<void> updateUserStatus(
      {required String userId, required bool isOnline}) async {
    try {
      final usersSnapshot = await firestore
          .collection(userCollection)
          .where('uid', isNotEqualTo: userId)
          .get()
          .then(
        (value) {
          for (var doc in value.docs) {
            doc.reference.update({
              'isOnline': isOnline,
            });
          }
        },
        onError: (e) => print('Error getting user document: $e'),
      );

      return usersSnapshot.docs
          .map((doc) => User.fromDocumentMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw APIException(
        message: e.message ?? 'Unexpected error occurs',
        statusCode: e.code,
      );
    }
  }

  @override
  Future<User?> uploadProfilePicture(
      {required File imageFile, required String uid}) async {
    try {
      // Create a storage reference from our app
      final storageRef = FirebaseStorage.instance.ref();
      // Create a reference to 'profile-images/{uid}.jpg'
      final profileImagesRef = storageRef.child("users/$uid/profile.jpg");

      print('upload image begin');
      await profileImagesRef.putFile(imageFile);
      final downloadUrl = await profileImagesRef.getDownloadURL();
      print('download URL => $downloadUrl');

      // update user profile pict url
      await firestore
          .collection(userCollection)
          .where('uid', isEqualTo: uid)
          .get()
          .then(
        (value) {
          for (var doc in value.docs) {
            doc.reference.update({
              'profilePicUrl': downloadUrl,
            });
          }
        },
        onError: (e) => print('Error getting user document: $e'),
      );

      return await getUserById(id: uid);
    } on FirebaseException catch (e) {
      print('error uploading image => $e');
      throw APIException(
        message: e.message ?? 'Unexpected error occurs',
        statusCode: e.code,
      );
    }
  }

  @override
  Future<User?> updateUserFullName(
      {required String uid, required String fullName}) async {
    try {
      // update user profile pict url
      await firestore
          .collection(userCollection)
          .where('uid', isEqualTo: uid)
          .get()
          .then(
        (value) {
          for (var doc in value.docs) {
            doc.reference.update({
              'fullName': fullName,
            });
          }
        },
        onError: (e) => print('Error updating user full name: $e'),
      );

      return await getUserById(id: uid);
    } on FirebaseException catch (e) {
      throw APIException(
        message: e.message ?? 'Unexpected error occurs',
        statusCode: e.code,
      );
    }
  }
}
