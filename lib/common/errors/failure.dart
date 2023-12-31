import 'package:equatable/equatable.dart';
import 'package:flutter_chat_app/common/errors/constants.dart';
import 'package:flutter_chat_app/common/errors/exception.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message, required this.statusCode});

  final String message;
  final String statusCode;

  String get errorMessage => '$statusCode Error: $message';

  @override
  List<Object> get props => [message, statusCode];
}

class APIFailure extends Failure {
  const APIFailure({required super.message, required super.statusCode});

  APIFailure.fromException(APIException exception)
      : this(
          message:
              FirebaseAuthConstants.getAuthErrorMessage(exception.statusCode),
          statusCode: exception.statusCode,
        );
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, required super.statusCode});

  CacheFailure.fromException(CacheException exception)
      : this(
          message: exception.message,
          statusCode: 'cache-error',
        );
}
