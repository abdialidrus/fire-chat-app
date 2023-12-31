import 'dart:io';

import 'package:flutter_chat_app/common/util/typedef.dart';
import 'package:flutter_chat_app/domain/model/user.dart';

abstract class UserRepository {
  FutureResultData<User?> getUserDataById({required String id});
  FutureResultData<List<User>> getOtherUsers({required String selfId});
  FutureResultVoid updateUserStatus(
      {required String userId, required bool isOnline});
  FutureResultData<User?> uploadProfilePicture(
      {required File imageFile, required String uid});
  FutureResultData<User?> updateUserFullName(
      {required String uid, required String fullName});
}
