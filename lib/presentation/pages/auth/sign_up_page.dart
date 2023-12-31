import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/common/util/helper_functions.dart';
import 'package:flutter_chat_app/presentation/providers/auth_provider.dart';
import 'package:flutter_chat_app/presentation/widgets/app_label.dart';
import 'package:flutter_chat_app/presentation/widgets/my_button.dart';
import 'package:flutter_chat_app/presentation/widgets/my_text_form_field.dart';
import 'package:provider/provider.dart';

@RoutePage()
class SignUpPage extends StatefulWidget {
  final Function() onSignInNow;
  const SignUpPage({super.key, required this.onSignInNow});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();

  String? email;
  String? fullName;
  String? password;

  void signUp() {
    Provider.of<AuthProvider>(context, listen: false)
        .signUp(
      email!,
      password!,
      fullName!,
    )
        .then((error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Text(
                        'Sign up to ',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                            ),
                      ),
                      const AppLabel(),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Connect with friends and family with the most secure and enjoyable way. Are you ready?',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        MyTextFormField(
                          hintText: 'Enter your email',
                          inputType: TextInputType.emailAddress,
                          inputAction: TextInputAction.next,
                          autoFocus: false,
                          validator: (value) {
                            email = value;
                            return validateEmail(value!);
                          },
                        ),
                        const SizedBox(height: 15),
                        MyTextFormField(
                          hintText: 'Enter your full name',
                          inputType: TextInputType.name,
                          inputAction: TextInputAction.next,
                          autoFocus: false,
                          validator: (value) {
                            fullName = value;
                            return validateFullName(value!);
                          },
                        ),
                        const SizedBox(height: 15),
                        MyTextFormField(
                          hintText: 'Enter your password',
                          inputType: TextInputType.visiblePassword,
                          inputAction: TextInputAction.next,
                          autoFocus: false,
                          validator: (value) {
                            password = value;
                            return validatePassword(value);
                          },
                        ),
                        const SizedBox(height: 15),
                        MyTextFormField(
                          hintText: 'Re-enter your password',
                          inputType: TextInputType.visiblePassword,
                          inputAction: TextInputAction.done,
                          autoFocus: false,
                          validator: (value) {
                            return validateConfirmPassword(value, password);
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Consumer<AuthProvider>(
                    builder: (context, model, child) {
                      if (model.isSignUpLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MyButton(
                            label: 'Sign Up',
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                signUp();
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                  children: [
                                    const TextSpan(
                                        text: 'Already have an account? '),
                                    TextSpan(
                                      text: 'Sign In Here',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => widget.onSignInNow(),
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
