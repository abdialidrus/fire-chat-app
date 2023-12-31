import 'package:flutter_chat_app/common/util/typedef.dart';
import 'package:flutter_chat_app/domain/model/message.dart';
import 'package:flutter_chat_app/domain/model/room.dart';

abstract class ChatRepository {
  FutureResultData<Room> createRoom({
    required List<String> userIds,
    required List<String> userNames,
    required String lastMessageBody,
    required String lastMessageSenderName,
    required String lastSenderId,
    required DateTime lastMessageSentAt,
  });
  FutureResultData<List<Message>> getMessages(
      {required String roomId, required String selfId});
  FutureResultData<List<Message>> createMessage({
    required Message newMessage,
    required String senderFullName,
  });
  void updateUnreadMessagesToRead(
      {required String roomId, required String selfId});
}
