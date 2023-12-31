import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/domain/model/message.dart';
import 'package:flutter_chat_app/domain/model/room.dart';
import 'package:flutter_chat_app/domain/model/user.dart';
import 'package:flutter_chat_app/presentation/providers/auth_provider.dart';
import 'package:flutter_chat_app/presentation/providers/chat_provider.dart';
import 'package:flutter_chat_app/presentation/widgets/user_avatar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    super.key,
    required this.recipientId,
    required this.recipientFullName,
  });

  final String recipientId;
  final String recipientFullName;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  Room? chatRoom;
  User? sender;
  User? recipient;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void getCurrentUser() {
    sender = context.read<AuthProvider>().currentUser;
  }

  Future<void> getRecipientData() async {
    final userRecipient =
        await context.read<AuthProvider>().getUserData(widget.recipientId);
    setState(() {
      recipient = userRecipient;
    });
  }

  void getCurrentRoom() {
    chatRoom =
        context.read<ChatProvider>().getRoom(sender!.id, widget.recipientId);
  }

  void listenToMessageChanges() {
    if (chatRoom != null) {
      context
          .read<ChatProvider>()
          .listenToMessageListUpdate(chatRoom!.id, sender!.id);
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration:
              const Duration(milliseconds: 300), // You can adjust the duration
          curve: Curves.easeOut, // You can choose a different easing curve
        );
      }
    });
  }

  void sendMessage() {
    final messageBody = _messageController.text;
    context.read<ChatProvider>().sendMessage(
          messageBody,
          sender!.id,
          sender!.getFullName(),
          widget.recipientId,
          widget.recipientFullName,
          chatRoom,
        );

    _messageController.clear();
  }

  void clearMessages() {
    context.read<ChatProvider>().clearMessages();
  }

  @override
  void initState() {
    super.initState();
    clearMessages();
    getCurrentUser();
    getRecipientData();
    if (sender != null) {
      getCurrentRoom();
      listenToMessageChanges();
    }
  }

  @override
  void deactivate() {
    context.read<ChatProvider>().cancelChatListener();
    super.deactivate();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Consumer<AuthProvider>(
              builder: (context, data, child) {
                return UserAvatar(
                  url: recipient?.profilePicUrl,
                  size: 40,
                );
              },
            ),
            const SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipient?.getFullName() ?? '...',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (recipient != null && recipient!.isOnline)
                  const SizedBox(height: 5),
                if (recipient != null && recipient!.isOnline)
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              color: Colors.grey[100],
              child:
                  Consumer<ChatProvider>(builder: (context, model, snapshot) {
                scrollToBottom();
                if (sender != null) {
                  if (chatRoom == null) {
                    getCurrentRoom();
                    listenToMessageChanges();
                  }
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: model.messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    bool isFirstChat = index == 0;
                    bool isLastMessage = index == model.messages.length - 1;
                    bool isOutgoingChat =
                        model.messages[index].senderId == sender!.id;
                    bool isNextChatHaveSameTime = false;

                    if (isOutgoingChat) {
                      if (!isLastMessage) {
                        bool isNextChatOutgoing =
                            model.messages[index + 1].senderId == sender!.id;
                        if (isNextChatOutgoing) {
                          isNextChatHaveSameTime =
                              model.messages[index + 1].sentAtFormatted ==
                                  model.messages[index].sentAtFormatted;
                        }
                      }
                      return _chatBubbleOutWidget(
                        model.messages[index],
                        isNextChatHaveSameTime,
                        isLastMessage,
                        isFirstChat,
                      );
                    } else {
                      if (!isLastMessage) {
                        bool isNextChatIncoming =
                            model.messages[index + 1].senderId != sender!.id;
                        if (isNextChatIncoming) {
                          isNextChatHaveSameTime =
                              model.messages[index + 1].sentAtFormatted ==
                                  model.messages[index].sentAtFormatted;
                        }
                      }
                      return _chatBubbleInWidget(
                        model.messages[index],
                        isNextChatHaveSameTime,
                        isLastMessage,
                        isFirstChat,
                      );
                    }
                  },
                );
              }),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 15,
              bottom: 50,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.only(left: 25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type here...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    icon: const Icon(Icons.send_rounded),
                    color: Colors.grey[500],
                    onPressed: () => sendMessage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatBubbleInWidget(Message chat, bool isNextChatHaveSameTime,
      bool isLastMessage, bool isFirstChat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isFirstChat) const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomRight: const Radius.circular(12),
              bottomLeft: !isNextChatHaveSameTime
                  ? Radius.zero
                  : const Radius.circular(12),
            ),
          ),
          child: Text(chat.body),
        ),
        const SizedBox(height: 4),
        if (!isNextChatHaveSameTime)
          Text(
            chat.sentAtFormatted.toString(),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        if (!isNextChatHaveSameTime) const SizedBox(height: 15),
        if (isLastMessage) const SizedBox(height: 30),
      ],
    );
  }

  Widget _chatBubbleOutWidget(Message chat, bool isNextChatHaveSameTime,
      bool isLastMessage, bool isFirstChat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isFirstChat) const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.only(
              bottomLeft: const Radius.circular(12),
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomRight: !isNextChatHaveSameTime
                  ? Radius.zero
                  : const Radius.circular(12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  chat.body,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chat.sentAtFormatted,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (chat.deliveryStatus == 'pending')
                    FaIcon(
                      FontAwesomeIcons.clock,
                      size: 14,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    )
                  else if (chat.deliveryStatus == 'sent')
                    FaIcon(
                      FontAwesomeIcons.check,
                      size: 14,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    )
                  else
                    FaIcon(
                      FontAwesomeIcons.checkDouble,
                      size: 14,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    )
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (isLastMessage) const SizedBox(height: 30),
      ],
    );
  }
}
