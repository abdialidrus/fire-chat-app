import 'package:flutter/material.dart';
import 'package:flutter_chat_app/presentation/providers/auth_provider.dart';
import 'package:flutter_chat_app/presentation/widgets/user_avatar.dart';
import 'package:provider/provider.dart';

class ProfileButton extends StatelessWidget {
  final Function() onTap;
  const ProfileButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Consumer<AuthProvider>(
        builder: (context, data, child) {
          return UserAvatar(url: data.currentUser?.profilePicUrl, size: 40);
        },
      ),
    );
  }
}
