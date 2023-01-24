import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

@immutable
class AuthUser {
  final String id;
  final String email;
  final bool isEmailVerified;

  const AuthUser(
      {required this.id, required this.email, required this.isEmailVerified});

  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid,
        email: user.email!,
        isEmailVerified: user.emailVerified,
      );

// static AuthUser fromFirebase(User user){
//  return AuthUser(user.emailVerified);
// }

}
