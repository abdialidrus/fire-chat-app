import 'package:dartz/dartz.dart';
import 'package:flutter_chat_app/common/errors/failure.dart';

typedef FutureResultData<T> = Future<Either<Failure, T>>;

typedef FutureResultVoid = FutureResultData<void>;
