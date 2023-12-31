import 'package:flutter/material.dart';

class AppLabel extends StatelessWidget {
  const AppLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
        children: const [
          TextSpan(
            text: 'Fire🔥',
            style: TextStyle(
              color: Colors.deepOrangeAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: 'Chat',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
