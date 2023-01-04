import 'package:flutter/material.dart';
import 'package:vandad_flutter_project/constants/routes.dart';
import 'package:vandad_flutter_project/enums/menu_action.dart';
import 'package:vandad_flutter_project/main.dart';
import 'dart:developer' as devtools show log;

import 'package:vandad_flutter_project/services/auth/auth_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  NotesViewState createState() => NotesViewState();
}

class NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        actions: [
          PopupMenuButton<MenuActions>(
            onSelected: (value) async {
              switch (value) {
                case MenuActions.logout:
                  final shouldLogOut = await showLogOutDialog(context);
                  devtools.log(shouldLogOut.toString());
                  if (shouldLogOut) {
                    await AuthService.firebase().logOut();
                    if (mounted) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                    }
                  }
                // break;
              }

              // debugPrint(value.toString());
              // print(value);
              devtools.log(value.toString());
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: MenuActions.logout, child: Text('LogOut'))
              ];
            },
          )
        ],
      ),
    );
  }
}
