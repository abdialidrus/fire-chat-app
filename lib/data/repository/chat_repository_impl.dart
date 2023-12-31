import 'package:dartz/dartz.dart';
import 'package:flutter_chat_app/common/errors/exception.dart';
import 'package:flutter_chat_app/common/errors/failure.dart';
import 'package:flutter_chat_app/common/util/typedef.dart';
import 'package:flutter_chat_app/data/data_source/chat_remote_data_source.dart';
import 'package:flutter_chat_app/domain/model/message.dart';
import 'package:flutter_chat_app/domain/model/room.dart';
import 'package:flutter_chat_app/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSouce remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  FutureResultData<Room> createRoom({
    required List<String> userIds,
    required List<String> userNames,
    required String lastMessageBody,
    required String lastMessageSenderName,
    required String lastSenderId,
    required DateTime lastMessageSentAt,
  }) async {
    try {
      final room = await remoteDataSource.createRoom(
        userIds: userIds,
        userNames: userNames,
        lastMessageBody: lastMessageBody,
        lastMessageSenderName: lastMessageSenderName,
        lastSenderId: lastSenderId,
        lastMessageSentAt: lastMessageSentAt,
      );
      return Right(room);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    }
  }

  @override
  FutureResultData<List<Message>> createMessage(
      {required Message newMessage, required String senderFullName}) async {
    try {
      final messages = await remoteDataSource.createNewAndGetMessages(
        message: newMessage,
        senderFullName: senderFullName,
      );
      return Right(messages);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    }
  }

  @override
  FutureResultData<List<Message>> getMessages(
      {required String roomId, required String selfId}) async {
    try {
      final messages =
          await remoteDataSource.getMessages(roomId: roomId, selfId: selfId);

      return Right(messages);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    }
  }

  @override
  void updateUnreadMessagesToRead(
      {required String roomId, required String selfId}) async {
    await remoteDataSource.updateUnreadMessagesToRead(
        roomId: roomId, selfId: selfId);
  }
}
