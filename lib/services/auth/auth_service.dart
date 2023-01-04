import 'package:vandad_flutter_project/services/auth/auth_provider.dart';
import 'package:vandad_flutter_project/services/auth/auth_user.dart';
import 'package:vandad_flutter_project/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  // static AuthService firebase() {
  // FirebaseAuthProvider firebaseAuthProvider=FirebaseAuthProvider();
  //   return AuthService(firebaseAuthProvider);
  // }

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<AuthUser> createUser(
          {required String email, required String password}) =>
      provider.createUser(email: email, password: password);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({required String email, required String password}) =>
      provider.logIn(email: email, password: password);

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
}
//tozihe dependency injection
// class A {
//   void sum(){
//
//   }
// }
//
// class B {
//   final A a;
//   //instance a be B inject shode
//   //dependency injection:hame kelassha bayad dependeny khod ra az birun
//   //                     daryaft konand va NABAYAD an ra besazand
//   B(this.a);
//
//   void sum(){
//     a.sum();
//   }
// }
//
// class B1 {
//   //NABAYAD an ra besazand
//   final A a = new A();
//   B1();
//
//   void sum(){
//     a.sum();
//   }
// }
//
// void main(){
//   B1 b1 = B1();
//
//   A a = A();
//   B b = B(a);
// }
