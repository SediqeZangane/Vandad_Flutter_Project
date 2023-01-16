import 'package:flutter/material.dart';
import 'package:vandad_flutter_project/constants/routes.dart';
import 'package:vandad_flutter_project/services/auth/auth_exceptions.dart';
import 'package:vandad_flutter_project/services/auth/auth_service.dart';
import 'package:vandad_flutter_project/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  RegisterViewState createState() => RegisterViewState();
}

class RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text('Register')),
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
            obscureText: false,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.number,
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;

              try {
                final userCredential = await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );
                AuthService.firebase().sendEmailVerification();

                if (mounted) {
                  Navigator.of(context)
                      .pushNamed(verifyEmailRoute, arguments: (route) => false);
                }
                debugPrint(userCredential.toString());
              } on WeakPasswordAuthException {
                await showErrorDialog(
                  context,
                  'weak-password',
                );
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(
                  context,
                  'Email already in use',
                );
              } on InvalidEmailAuthException {
                await showErrorDialog(
                  context,
                  'Invalid email',
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  'Failed to register',
                );
              }

              // on FirebaseAuthException catch (e) {
              //   if (e.code == 'weak-password') {
              //     debugPrint('Weak password');
              //     await showErrorDialog(context, 'Weak password');
              //   } else if (e.code == 'email-already-in-use') {
              //     debugPrint('Email already in use');
              //     await showErrorDialog(context, 'Email already in use');
              //   } else if (e.code == 'invalid-email') {
              //     debugPrint('Invalid email');
              //     await showErrorDialog(context, 'Invalid email');
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
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text('Already registered? Login here!'),
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
