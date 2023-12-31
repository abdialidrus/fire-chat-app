import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/common/util/helper_functions.dart';
import 'package:flutter_chat_app/common/util/image_helper.dart';
import 'package:flutter_chat_app/domain/model/user.dart';
import 'package:flutter_chat_app/presentation/providers/auth_provider.dart';
import 'package:flutter_chat_app/presentation/widgets/my_button.dart';
import 'package:flutter_chat_app/presentation/widgets/my_text_form_field.dart';
import 'package:flutter_chat_app/presentation/widgets/user_avatar.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();
  final imageHelper = ImageHelper();
  TextEditingController fullNameController = TextEditingController();
  User? currentUser;

  void showImagePickePopUp() {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text("Confirmation"),
        content: const Text("Choose your image source"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              pickImageFromCamera();
            },
            child: const Text("Camera"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              pickImageFromGallery();
            },
            child: const Text("Gallery"),
          ),
        ],
      ),
    );
  }

  void pickImageFromGallery() async {
    final files = await imageHelper.pickImage();
    if (files.isNotEmpty) {
      cropFile(files.first);
    }
  }

  void uploadImage(File image) {
    context.read<AuthProvider>().uploadProfileImage(image, currentUser!.id);
  }

  void pickImageFromCamera() async {
    final files = await imageHelper.pickImage(source: ImageSource.camera);

    if (files.isNotEmpty) {
      cropFile(files.first);
    }
  }

  void cropFile(XFile file) async {
    final croppedFile = await imageHelper.crop(
      file: file,
      cropStyle: CropStyle.circle,
    );

    if (croppedFile != null) {
      uploadImage(File(croppedFile.path));
    }
  }

  void updateFullName() {
    context.read<AuthProvider>().updateUserFullName(fullNameController.text);
  }

  Future showEditNameDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Full Name'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyTextFormField(
                  hintText: 'Your full name',
                  inputType: TextInputType.text,
                  inputAction: TextInputAction.done,
                  autoFocus: true,
                  controller: fullNameController,
                  validator: (value) {
                    return validateFullName(value!);
                  },
                ),
                const SizedBox(height: 10),
                MyButton(
                    label: 'Save',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        updateFullName();
                      }
                    }),
              ],
            ),
          ),
        ),
      );

  @override
  void initState() {
    super.initState();

    currentUser = context.read<AuthProvider>().currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Consumer<AuthProvider>(
            builder: (context, data, child) {
              return Column(
                children: [
                  const SizedBox(height: 30),

                  Stack(
                    children: [
                      UserAvatar(
                        url: data.currentUser?.profilePicUrl,
                        size: 160,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () => showImagePickePopUp(),
                          child: Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(Icons.edit),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Full name',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            Text(data.currentUser?.fullName ?? ''),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            fullNameController.text = currentUser!.fullName;
                            showEditNameDialog();
                          },
                          child: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Divider(),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.email),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            Text(
                              data.currentUser?.email ?? '',
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),

                  // sign out button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<AuthProvider>().signOut();
                              context.router.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              elevation: 0,
                            ),
                            child: const Text(
                              'Sign out',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
