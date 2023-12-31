import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? profilePicUrl;
  final bool isOnline;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.profilePicUrl,
    required this.isOnline,
  });

  @override
  List<Object?> get props => [id, fullName, isOnline];

  User.fromDocumentMap(Map<String, dynamic> map)
      : this(
          id: map['uid'],
          fullName: map['fullName'],
          email: map['email'],
          profilePicUrl: map['profilePicUrl'],
          isOnline: map['isOnline'],
        );

  String getFullName() => fullName;

  User updateProfilePic(String? url) {
    return User(
      id: id,
      fullName: fullName,
      email: email,
      profilePicUrl: url,
      isOnline: isOnline,
    );
  }
}
