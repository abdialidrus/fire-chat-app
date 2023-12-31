import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat_app/domain/model/user.dart';

class Room extends Equatable {
  final String id;
  final List<String> userIds;
  final List<String> userNames;
  final User? recipient;
  final String lastMessageBody;
  final String lastMessageSenderName;
  final String lastMessageSenderId;
  final DateTime lastMessageSentAt;
  final int newMessageTotal;

  const Room({
    required this.id,
    required this.userIds,
    required this.userNames,
    required this.recipient,
    required this.lastMessageBody,
    required this.lastMessageSenderName,
    required this.lastMessageSenderId,
    required this.lastMessageSentAt,
    required this.newMessageTotal,
  });

  factory Room.fromFirestore(
    String docId,
    Map<String, dynamic>? data,
    User? recipient,
    SnapshotOptions? options,
  ) {
    final sentAtTimestamp = data?['lastMessageSentAt'] as Timestamp;
    final sentAtDateTime = sentAtTimestamp.toDate();

    return Room(
      id: docId,
      userIds: List<String>.from(data?['userIds']),
      userNames: List<String>.from(data?['userNames']),
      recipient: recipient,
      lastMessageBody: data?['lastMessageBody'],
      lastMessageSenderName: data?['lastMessageSenderName'],
      lastMessageSenderId: data?['lastMessageSenderId'],
      lastMessageSentAt: sentAtDateTime,
      newMessageTotal: data?['newMessageTotal'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        userIds,
        userNames,
        lastMessageBody,
        lastMessageSenderName,
        lastMessageSenderId,
        lastMessageSentAt,
        newMessageTotal,
      ];
}
