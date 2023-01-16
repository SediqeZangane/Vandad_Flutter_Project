import 'package:flutter/material.dart';
import 'package:vandad_flutter_project/constants/routes.dart';
import 'package:vandad_flutter_project/enums/menu_action.dart';
import 'dart:developer' as devtools show log;

import 'package:vandad_flutter_project/services/auth/auth_service.dart';
import 'package:vandad_flutter_project/services/crud/notes_service.dart';
import 'package:vandad_flutter_project/utilities/dialogs/logout_dialog.dart';
import 'package:vandad_flutter_project/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  NotesViewState createState() => NotesViewState();
}

class NotesViewState extends State<NotesView> {
  String get userEmail => AuthService.firebase().currentUser!.email!;
  late final NotesService _notesService;

  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
    // _notesService.open();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
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
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNote: (note) async {
                            await _notesService.deleteNote(id: note.id);
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }

                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
