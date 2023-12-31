import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.url,
    required this.size,
  });

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: url != null
          ? Image.network(
              url!,
              height: size,
              width: size,
              fit: BoxFit.cover,
            )
          : Image(
              height: size,
              width: size,
              image: const AssetImage(
                'assets/images/profile_picture_placeholder.jpeg',
              ),
            ),
    );
  }
}
