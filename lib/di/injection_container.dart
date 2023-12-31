import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_app/data/data_source/auth_remote_data_source.dart';
import 'package:flutter_chat_app/data/data_source/chat_remote_data_source.dart';
import 'package:flutter_chat_app/data/data_source/user_remote_data_source.dart';
import 'package:flutter_chat_app/data/repository/auth_repository_impl.dart';
import 'package:flutter_chat_app/data/repository/chat_repository_impl.dart';
import 'package:flutter_chat_app/data/repository/user_repository_impl.dart';
import 'package:flutter_chat_app/domain/repository/auth_repository.dart';
import 'package:flutter_chat_app/domain/repository/chat_repository.dart';
import 'package:flutter_chat_app/domain/repository/user_repository.dart';
import 'package:flutter_chat_app/presentation/providers/auth_provider.dart';
import 'package:flutter_chat_app/presentation/providers/chat_provider.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl
    // -- App logic [ViewModels, Provider, Bloc, etd] --
    ..registerFactory(() => AuthProvider(
          authRepository: sl(),
          userRepository: sl(),
        ))
    ..registerFactory(() => ChatProvider(
          chatRepository: sl(),
          userRepository: sl(),
          firestore: sl(),
        ))
    // -- App logic [ViewModels, Provider, Bloc, etd] --

    // -- Repositories --
    ..registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remoteDataSource: sl()))
    ..registerLazySingleton<ChatRepository>(
        () => ChatRepositoryImpl(remoteDataSource: sl()))
    ..registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(remoteDataSource: sl()))
    // -- Repositories --

    // -- Data sources --
    ..registerLazySingleton<AuthRemoteDataSource>(() =>
        AuthRemoteDataSourceImpl(firebaseAuth: sl(), firebaseFirestore: sl()))
    ..registerLazySingleton<ChatRemoteDataSouce>(
        () => ChatRemoteDataSourceImpl(firestore: sl()))
    ..registerLazySingleton<UserRemoteDataSource>(
        () => UserRemoteDataSourceImpl(firestore: sl(), storage: sl()))
    // -- Data sources --

    // -- Externals --
    ..registerSingleton(auth.FirebaseAuth.instance)
    ..registerSingleton(FirebaseFirestore.instance)
    ..registerSingleton(FirebaseStorage.instance);
  // -- Externals --
}
