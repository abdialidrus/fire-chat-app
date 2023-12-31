import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_chat_app/common/errors/exception.dart';
import 'package:flutter_chat_app/common/errors/failure.dart';
import 'package:flutter_chat_app/common/util/typedef.dart';
import 'package:flutter_chat_app/data/data_source/user_remote_data_source.dart';
import 'package:flutter_chat_app/domain/model/user.dart';
import 'package:flutter_chat_app/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  FutureResultData<User?> getUserDataById({required String id}) async {
    try {
      final user = await remoteDataSource.getUserById(id: id);
      return Right(user);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    }
  }

  @override
  FutureResultData<List<User>> getOtherUsers({required String selfId}) async {
    try {
      final users = await remoteDataSource.getOtherUsers(selfId: selfId);
      return Right(users);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    }
  }

  @override
  FutureResultVoid updateUserStatus({
    required String userId,
    required bool isOnline,
  }) async {
    try {
      await remoteDataSource.updateUserStatus(
          userId: userId, isOnline: isOnline);
      return const Right(null);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    }
  }

  @override
  FutureResultData<User?> uploadProfilePicture({
    required File imageFile,
    required String uid,
  }) async {
    try {
      final result = await remoteDataSource.uploadProfilePicture(
          imageFile: imageFile, uid: uid);

      return Right(result);
    } on APIException catch (e) {
      print('upload image failure');
      return Left(APIFailure.fromException(e));
    }
  }

  @override
  FutureResultData<User?> updateUserFullName({
    required String uid,
    required String fullName,
  }) async {
    try {
      final result = await remoteDataSource.updateUserFullName(
          uid: uid, fullName: fullName);
      return Right(result);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    }
  }
}
