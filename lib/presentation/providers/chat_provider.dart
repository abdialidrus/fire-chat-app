import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/common/util/helper_functions.dart';
import 'package:flutter_chat_app/domain/model/message.dart';
import 'package:flutter_chat_app/domain/model/room.dart';
import 'package:flutter_chat_app/domain/model/user.dart';
import 'package:flutter_chat_app/domain/repository/chat_repository.dart';
import 'package:flutter_chat_app/domain/repository/user_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository;
  final UserRepository _userRepository;
  final FirebaseFirestore _firestore;

  ChatProvider(
      {required ChatRepository chatRepository,
      required UserRepository userRepository,
      required FirebaseFirestore firestore})
      : _chatRepository = chatRepository,
        _userRepository = userRepository,
        _firestore = firestore;

  List<User> availableUsers = [];

  List<Message> messages = [];
  List<Room> chatRooms = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _roomListener;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _chatListener;

  void listenToRoomListUpdate(String userId) async {
    _roomListener = _firestore
        .collection('rooms')
        .where('userIds', arrayContains: userId)
        .orderBy('lastMessageSentAt', descending: true)
        .snapshots()
        .listen(
      (event) async {
        final roomDocs = event.docs;
        final List<Room> availableRooms = [];
        for (var doc in roomDocs) {
          final roomDataMap = doc.data();
          User? roomRecipient;

          roomRecipient = await getRoomRecipientData(userId, roomDataMap);
          print('room recipient => $roomRecipient');

          final room =
              Room.fromFirestore(doc.id, roomDataMap, roomRecipient, null);
          availableRooms.add(room);
        }

        chatRooms = availableRooms;

        notifyListeners();
      },
      onError: (error) => print('room changes listen failed -> $error'),
    );
  }

  Future<User?> getRoomRecipientData(
      String userId, Map<String, dynamic> roomDataMap) async {
    final userRefs = roomDataMap['userRefs'];
    if (userRefs != null) {
      final userRefsList = List<DocumentReference>.from(userRefs);

      for (var ref in userRefsList) {
        final user = await ref.get();
        final userData = user.data() as Map<String, dynamic>;
        final id = userData['uid'];

        if (id != userId) {
          final roomRecipient = User.fromDocumentMap(userData);
          return roomRecipient;
        }
      }
    }

    return null;
  }

  void listenToMessageListUpdate(String roomId, String selfId) async {
    _chatListener = _firestore
        .collection('messages')
        .where('roomId', isEqualTo: roomId)
        .orderBy('sentAt', descending: false)
        .snapshots()
        .listen(
      (event) {
        final messageList =
            event.docs.map((doc) => Message.fromFirestore(doc, null)).toList();
        messages = messageList;

        notifyListeners();

        _chatRepository.updateUnreadMessagesToRead(
            roomId: roomId, selfId: selfId);
      },
      onError: (error) => print('message changes listen failed -> $error'),
    );
  }

  Room? getRoom(String selfId, String recipientId) {
    if (chatRooms.isNotEmpty) {
      final List<String> userIds = [selfId, recipientId];
      for (var room in chatRooms) {
        bool containsAllIds =
            userIds.every((element) => room.userIds.contains(element));

        if (containsAllIds) return room;
      }
    }

    return null;
  }

  void createRoomAndSendMessage(
    Message message,
    String senderId,
    String senderFullName,
    String recipientId,
    String recipientFullName,
  ) async {
    final userIds = [senderId, recipientId];
    final userNames = [senderFullName, recipientFullName];
    final result = await _chatRepository.createRoom(
      userIds: userIds,
      userNames: userNames,
      lastMessageBody: message.body,
      lastMessageSenderName: senderFullName,
      lastMessageSentAt: message.sentAt,
      lastSenderId: recipientId,
    );

    Room? newRoom;
    result.fold(
      (l) => null,
      (room) => newRoom = room,
    );

    if (newRoom != null) {
      final newMessage = Message(
          body: message.body,
          roomId: newRoom!.id,
          senderId: senderId,
          sentAt: message.sentAt,
          sentAtFormatted: message.sentAtFormatted,
          deliveryStatus: 'pending');
      sendMessageAndUpdateRoom(senderId, senderFullName, newMessage, newRoom!);
    }
  }

  void sendMessageAndUpdateRoom(String senderId, String senderFullName,
      Message message, Room room) async {
    final result = await _chatRepository.createMessage(
      newMessage: message,
      senderFullName: senderFullName,
    );

    result.fold(
      (l) => null,
      (newMessages) => messages = newMessages,
    );

    notifyListeners();
  }

  void sendMessage(String body, String senderId, String senderFullName,
      String recipientId, String recipientFullName, Room? room) {
    final messageSentAt = DateTime.now();
    Message newMessage = Message(
        body: body,
        roomId: room?.id ?? 'null',
        senderId: senderId,
        sentAt: messageSentAt,
        sentAtFormatted: getFormattedDateTime(messageSentAt),
        deliveryStatus: 'pending');

    if (room == null) {
      createRoomAndSendMessage(
          newMessage, senderId, senderFullName, recipientId, recipientFullName);
    } else {
      sendMessageAndUpdateRoom(senderId, senderFullName, newMessage, room);
    }

    messages.add(newMessage);
    notifyListeners();
  }

  void getMessages(String roomId, String selfId) async {
    final result =
        await _chatRepository.getMessages(roomId: roomId, selfId: selfId);

    messages.clear();
    result.fold(
      (l) => null,
      (newMessages) => messages = newMessages,
    );

    notifyListeners();
  }

  void clearMessages() {
    messages.clear();
  }

  void cancelRoomListener() {
    if (_roomListener != null) {
      _roomListener!.cancel();
    }
  }

  void cancelChatListener() {
    if (_chatListener != null) {
      _chatListener!.cancel();
    }
  }

  void getAvailableUsers(String currentUserId) async {
    final result = await _userRepository.getOtherUsers(selfId: currentUserId);

    result.fold(
      (failure) => null,
      (users) => availableUsers = users,
    );

    notifyListeners();
  }
}
