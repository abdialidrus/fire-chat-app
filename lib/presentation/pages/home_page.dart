import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/common/util/helper_functions.dart';
import 'package:flutter_chat_app/domain/model/room.dart';
import 'package:flutter_chat_app/domain/model/user.dart';
import 'package:flutter_chat_app/presentation/pages/chat_room_page.dart';

import 'package:flutter_chat_app/presentation/pages/select_recipient_page.dart';
import 'package:flutter_chat_app/presentation/providers/auth_provider.dart';
import 'package:flutter_chat_app/presentation/providers/chat_provider.dart';
import 'package:flutter_chat_app/presentation/routes/app_router.dart';
import 'package:flutter_chat_app/presentation/widgets/app_label.dart';
import 'package:flutter_chat_app/presentation/widgets/profile_button.dart';
import 'package:flutter_chat_app/presentation/widgets/user_avatar.dart';
import 'package:provider/provider.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? sender;

  void getCurrentUser() {
    sender = context.read<AuthProvider>().currentUser;
  }

  void getRooms(String selfId) {
    // context.read<ChatViewModel>().getRooms(selfId);
    context.read<ChatProvider>().listenToRoomListUpdate(selfId);
  }

  void _openChatRoom(String recipientId, String recipientFullName) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatRoomPage(
                  recipientId: recipientId,
                  recipientFullName: recipientFullName,
                ))).then((value) => loadData());
  }

  void openProfilePage() {
    context.router.push(const ProfileRoute());
  }

  void loadData() {
    getCurrentUser();
    if (sender != null) {
      getRooms(sender!.id);
    }
  }

  @override
  void initState() {
    super.initState();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppLabel(),
            ProfileButton(
              onTap: () {
                openProfilePage();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SelectRecipientPage()));
        },
        child: const Icon(Icons.chat_rounded),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, model, child) {
          if (model.chatRooms.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
              child: Column(
                children: [
                  ListView.builder(
                    itemCount: model.chatRooms.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return _roomListItemWidget(
                          model.chatRooms[index], sender!);
                    },
                  ),
                  Center(
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                          children: [
                            const TextSpan(text: 'Your personal messages are '),
                            TextSpan(
                              text: 'end-to-end-encrypted',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500),
                            ),
                          ]),
                    ),
                  )
                ],
              ),
            );
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: const [
                      TextSpan(
                          text: 'You haven\'t started any conversations.\n'),
                      TextSpan(
                          text:
                              'Tap the button on the bottom right corner \n to start a new chat.'),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _roomListItemWidget(Room room, User sender) {
    final isLatestMessageMine =
        room.lastMessageSenderName == sender.getFullName();

    final newMessageCount =
        (room.lastMessageSenderId == sender.id) ? 0 : room.newMessageTotal;

    String recipientName = room.recipient?.getFullName() ?? '...';
    return GestureDetector(
      onTap: () {
        String recipientId = sender.id;
        String recipientFullName = sender.getFullName();
        for (var userId in room.userIds) {
          if (userId != sender.id) {
            recipientId = userId;
          }
        }
        _openChatRoom(recipientId, recipientFullName);
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UserAvatar(url: room.recipient?.profilePicUrl, size: 40),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          recipientName,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            if (isLatestMessageMine)
                              Text(
                                'You: ',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.bold),
                              ),
                            Expanded(
                              child: Text(
                                room.lastMessageBody,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    getFormattedDateTime(room.lastMessageSentAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (newMessageCount > 0)
                    Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.red[800],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                          child: Text(
                        newMessageCount.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
