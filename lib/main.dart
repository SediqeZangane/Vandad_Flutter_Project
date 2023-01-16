import 'package:flutter/material.dart';
import 'package:vandad_flutter_project/constants/routes.dart';
import 'package:vandad_flutter_project/services/auth/auth_service.dart';
import 'package:vandad_flutter_project/views/login_view.dart';
import 'package:vandad_flutter_project/views/notes/new_note_view.dart';
import 'package:vandad_flutter_project/views/notes/notes_view.dart';
import 'package:vandad_flutter_project/views/register_view.dart';
import 'package:vandad_flutter_project/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        newNoteRoute: (context) => const NewNoteView(),

      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            debugPrint(user.toString());
            if (user != null) {
              if (user.isEmailVerified) {
                debugPrint('is verified');
                return const NotesView();
              } else {
                debugPrint('You need to  verify');
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
              // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              //   Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => const VerifyEmailView(),
              //   ));
              // });
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

// Future<bool> showLogOutDialog(BuildContext context) {
//   return showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Log Out'),
//         content: const Text('Are you sure you want to log out? '),
//         actions: [
//           TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(false);
//               },
//               child: const Text('Cancel')),
//           TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(true);
//               },
//               child: const Text('Log out')),
//         ],
//       );
//     },
//   ).then((value) => value ?? false);
// }
