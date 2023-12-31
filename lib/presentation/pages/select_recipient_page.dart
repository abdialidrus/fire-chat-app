import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/domain/model/user.dart';
import 'package:flutter_chat_app/presentation/pages/chat_room_page.dart';
import 'package:flutter_chat_app/presentation/providers/auth_provider.dart';
import 'package:flutter_chat_app/presentation/providers/chat_provider.dart';
import 'package:flutter_chat_app/presentation/widgets/user_avatar.dart';
import 'package:provider/provider.dart';

@RoutePage()
class SelectRecipientPage extends StatefulWidget {
  const SelectRecipientPage({super.key});

  @override
  State<SelectRecipientPage> createState() => _SelectRecipientPageState();
}

class _SelectRecipientPageState extends State<SelectRecipientPage> {
  void _openChatRoom(User recipient) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatRoomPage(
                  recipientId: recipient.id,
                  recipientFullName: recipient.getFullName(),
                )));
  }

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      context.read<ChatProvider>().getAvailableUsers(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Start a conversation',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, model, child) {
          if (model.availableUsers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'No user available',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            );
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Select recipient to continue or start a new conversation.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                ListView.builder(
                  itemCount: model.availableUsers.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _openChatRoom(model.availableUsers[index]);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        margin:
                            const EdgeInsets.only(left: 15, top: 5, right: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                UserAvatar(
                                    url: model
                                        .availableUsers[index].profilePicUrl,
                                    size: 40),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      model.availableUsers[index].getFullName(),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
