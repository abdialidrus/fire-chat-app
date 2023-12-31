import 'package:dartz/dartz.dart';
import 'package:flutter_chat_app/common/errors/exception.dart';
import 'package:flutter_chat_app/common/errors/failure.dart';
import 'package:flutter_chat_app/common/util/typedef.dart';
import 'package:flutter_chat_app/data/data_source/auth_remote_data_source.dart';
import 'package:flutter_chat_app/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  FutureResultVoid signIn(
      {required String email, required String password}) async {
    try {
      await remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return const Right(null);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    }
  }

  @override
  FutureResultVoid signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    }
  }

  @override
  FutureResultVoid signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      await remoteDataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      return const Right(null);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    }
  }
}
