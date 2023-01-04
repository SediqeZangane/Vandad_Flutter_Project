import 'package:flutter/material.dart';
import 'package:vandad_flutter_project/constants/routes.dart';
import 'package:vandad_flutter_project/utilities/show_error_dialog.dart';
import 'package:vandad_flutter_project/services/auth/auth_service.dart';

import '../services/auth/auth_exceptions.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        children: [
          TextField(
            controller: _email,
            decoration:
                const InputDecoration(hintText: 'Enter your email here'),
            keyboardType: TextInputType.emailAddress,
            enableSuggestions: false,
            autocorrect: false,
          ),
          TextField(
            controller: _password,
            decoration:
                const InputDecoration(hintText: 'Enter your password here'),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.number,
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;

              try {
                final userCredential = await AuthService.firebase().logIn(
                  email: email,
                  password: password,
                );
                debugPrint(userCredential.toString());
                final user = AuthService.firebase().currentUser;
                if (user?.isEmailVerified ?? false) {
                  if (mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(notesRoute, (route) => false);
                  }
                } else {
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        verifyEmailRoute, (route) => false);
                  }
                }
              } on UserNotFoundAuthException {
                await showErrorDialog(
                  context,
                  'User not found',
                );
              } on WrongPasswordAuthException {
                await showErrorDialog(
                  context,
                  'wrong-password',
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  'Authentication Error',
                );
              }
              // on FirebaseAuthException catch (e) {
              //   // print (e.code);
              //   if (e.code == 'user-not-found') {
              //     debugPrint('User not found');
              //     await showErrorDialog(context, 'User not found');
              //   } else if (e.code == 'wrong-password') {
              //     debugPrint('Wrong password');
              //     await showErrorDialog(context, 'Wrong credentials');
              //   } else {
              //     await showErrorDialog(
              //       context,
              //       'Error: ${e.code}',
              //     );
              //   }
              // } catch (e) {
              //   await showErrorDialog(
              //     context,
              //     e.toString(),
              //   );
              // }
              // catch (e) {
              //   print('sth bad happened');
              //   print(e.runtimeType);
              //   print(e);
              // }
            },
            child: const Text('LogIn'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text('Not register yet? Register here!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}
