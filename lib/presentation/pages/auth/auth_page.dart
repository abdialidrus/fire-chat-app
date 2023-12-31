import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/presentation/pages/auth/sign_in_or_sign_up_page.dart';
import 'package:flutter_chat_app/presentation/pages/home_page.dart';
import 'package:flutter_chat_app/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

@RoutePage()
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, value, child) {
      if (value.currentUser != null) {
        return const HomePage();
      } else {
        return const SignInOrSignUpPage();
      }
    });
  }
}
