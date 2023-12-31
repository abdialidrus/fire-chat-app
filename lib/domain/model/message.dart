import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat_app/common/util/helper_functions.dart';

class Message extends Equatable {
  final String body;
  final String roomId;
  final String senderId;
  final DateTime sentAt;
  final String sentAtFormatted;
  final String deliveryStatus;

  const Message({
    required this.body,
    required this.roomId,
    required this.senderId,
    required this.sentAt,
    required this.sentAtFormatted,
    required this.deliveryStatus,
  });

  factory Message.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    final sentAtTimestamp = data?['sentAt'] as Timestamp;
    final sentAtString = getFormattedDateTime(sentAtTimestamp.toDate());
    return Message(
      body: data?['body'],
      roomId: data?['roomId'],
      senderId: data?['senderId'],
      sentAt: sentAtTimestamp.toDate(),
      sentAtFormatted: sentAtString,
      deliveryStatus: data?['deliveryStatus'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'body': body,
      'roomId': roomId,
      'senderId': senderId,
      'sentAt': FieldValue.serverTimestamp(),
      'deliveryStatus': deliveryStatus,
    };
  }

  @override
  List<Object?> get props => [
        body,
        roomId,
        senderId,
        sentAt,
        sentAtFormatted,
        deliveryStatus,
      ];
}
