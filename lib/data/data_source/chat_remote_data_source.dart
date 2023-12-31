import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/common/errors/exception.dart';
import 'package:flutter_chat_app/domain/model/message.dart';
import 'package:flutter_chat_app/domain/model/room.dart';

abstract class ChatRemoteDataSouce {
  Future<Room> createRoom({
    required List<String> userIds,
    required List<String> userNames,
    required String lastMessageBody,
    required String lastMessageSenderName,
    required String lastSenderId,
    required DateTime lastMessageSentAt,
  });
  Future<List<Message>> getMessages(
      {required String roomId, required String selfId});
  Future<List<Message>> createNewAndGetMessages({
    required Message message,
    required String senderFullName,
  });
  Future<void> updateUnreadMessagesToRead(
      {required String roomId, required String selfId});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSouce {
  final FirebaseFirestore firestore;
  final roomCollection = 'rooms';
  final messageCollection = 'messages';
  final userCollection = 'users';

  ChatRemoteDataSourceImpl({required this.firestore});

  @override
  Future<Room> createRoom({
    required List<String> userIds,
    required List<String> userNames,
    required String lastMessageBody,
    required String lastMessageSenderName,
    required String lastSenderId,
    required DateTime lastMessageSentAt,
  }) async {
    try {
      // get users document ref
      final List<DocumentReference> userRefs = [];
      for (var id in userIds) {
        final usersSnapshot = await firestore
            .collection(userCollection)
            .where('uid', isEqualTo: id)
            .get();

        final userRef = usersSnapshot.docs.firstOrNull;
        if (userRef != null) {
          userRefs.add(userRef.reference);
        }
      }

      final roomMap = <String, dynamic>{
        'userIds': userIds,
        'userNames': userNames,
        'userRefs': userRefs,
        'lastMessageBody': lastMessageBody,
        'lastMessageSenderName': lastMessageSenderName,
        'lastMessageSentAt': lastMessageSentAt,
        'lastMessageSenderId': lastSenderId,
        'createdAt': FieldValue.serverTimestamp(),
        'newMessageTotal': 0,
      };

      final docSnapshot =
          await firestore.collection(roomCollection).add(roomMap);
      final roomDoc =
          await firestore.collection(roomCollection).doc(docSnapshot.id).get();
      return Room.fromFirestore(docSnapshot.id, roomDoc.data(), null, null);
    } on FirebaseException catch (e) {
      throw APIException(
        message: e.message ?? 'Unexpected error occurs',
        statusCode: e.code,
      );
    }
  }

  @override
  Future<List<Message>> createNewAndGetMessages(
      {required Message message, required String senderFullName}) async {
    try {
      await firestore
          .collection(messageCollection)
          .add(message.toFirestore())
          .then((docRef) {
        docRef.update({'deliveryStatus': 'sent'});
      }, onError: (e) => print('Error submitting chat document: $e'));

      // update the room
      final roomRef = firestore.collection(roomCollection).doc(message.roomId);
      final updateCountNewMessage = await countUnReadMessage(
          roomId: message.roomId, selfId: message.senderId);
      await roomRef.update({
        'lastMessageBody': message.body,
        'lastMessageSenderName': senderFullName,
        'lastMessageSenderId': message.senderId,
        'lastMessageSentAt': message.sentAt,
        'newMessageTotal': updateCountNewMessage,
      });

      final messages =
          await getMessagesByRoomId(message.roomId, message.senderId);

      final messageList =
          messages.docs.map((doc) => Message.fromFirestore(doc, null)).toList();

      return messageList;
    } on FirebaseException catch (e) {
      throw APIException(
        message: e.message ?? 'Unexpected error occurs',
        statusCode: e.code,
      );
    }
  }

  @override
  Future<List<Message>> getMessages(
      {required String roomId, required String selfId}) async {
    try {
      final messages = await getMessagesByRoomId(roomId, selfId);

      final messageList =
          messages.docs.map((doc) => Message.fromFirestore(doc, null)).toList();

      return messageList;
    } on FirebaseException catch (e) {
      throw APIException(
        message: e.message ?? 'Unexpected error occurs',
        statusCode: e.code,
      );
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMessagesByRoomId(
    String roomId,
    String selfId,
  ) async {
    final messages = firestore
        .collection(messageCollection)
        .where('roomId', isEqualTo: roomId)
        .orderBy('sentAt', descending: false)
        .get();

    updateUnreadMessagesToRead(roomId: roomId, selfId: selfId);

    return messages;
  }

  @override
  Future<void> updateUnreadMessagesToRead(
      {required String roomId, required String selfId}) async {
    await firestore
        .collection(messageCollection)
        .where('roomId', isEqualTo: roomId)
        .where('senderId', isNotEqualTo: selfId)
        .where(Filter.or(
          Filter('deliveryStatus', isEqualTo: 'pending'),
          Filter('deliveryStatus', isEqualTo: 'sent'),
        ))
        .get()
        .then(
      (value) {
        for (var doc in value.docs) {
          doc.reference.update({
            'deliveryStatus': 'read',
          });
        }
      },
      onError: (e) => print('Error getting document: $e'),
    );

    // update the room
    final roomRef = firestore.collection(roomCollection).doc(roomId);
    roomRef.get().then((DocumentSnapshot doc) async {
      final data = doc.data() as Map<String, dynamic>;
      final updateCountNewMessage = await countUnReadMessage(
          roomId: roomId, selfId: data['lastMessageSenderId']);
      await roomRef.update({
        'newMessageTotal': updateCountNewMessage,
      });
    });
  }

  Future<int> countUnReadMessage(
      {required String roomId, required String selfId}) async {
    final newMessageCount = await firestore
        .collection(messageCollection)
        .where('roomId', isEqualTo: roomId)
        .where('senderId', isEqualTo: selfId)
        .where('deliveryStatus', isEqualTo: 'sent')
        .get()
        .then(
      (value) {
        return value.docs.length;
      },
      onError: (e) => print('Error countUnReadMessage: $e'),
    );

    return newMessageCount;
  }
}
