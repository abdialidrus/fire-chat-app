import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/presentation/pages/auth/sign_in_page.dart';
import 'package:flutter_chat_app/presentation/pages/auth/sign_up_page.dart';

@RoutePage()
class SignInOrSignUpPage extends StatefulWidget {
  const SignInOrSignUpPage({super.key});

  @override
  State<SignInOrSignUpPage> createState() => _SignInOrSignUpPageState();
}

class _SignInOrSignUpPageState extends State<SignInOrSignUpPage> {
  bool showSignInPage = true;

  void togglePages() {
    setState(() {
      showSignInPage = !showSignInPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSignInPage) {
      return SignInPage(onSignUpNow: togglePages);
    } else {
      return SignUpPage(onSignInNow: togglePages);
    }
  }
}
