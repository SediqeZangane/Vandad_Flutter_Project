import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:vandad_flutter_project/services/crud/crud_exceptions.dart';

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  static final NotesService _shared = NotesService._sharedInstance();

  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }

  factory NotesService() => _shared;

  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser catch (_) {
      final createdUser = await createUser(email: email);

      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    _notes = await getAllNotes();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({
    required int id,
    String? text,
    bool? isSync,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    //make sure note exists
    final note = await getNote(id: id);
    //update DB
    int updatesCount = await db.update(
      noteTable,
      {
        textColumn: text ?? note.text,
        isSyncedWithCloudColumn: (isSync ?? note.isSyncedWithCloud) ? 1 : 0,
      },
      where: 'id=?',
      whereArgs: [id],
    );
    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    }
    final updatedNote = await getNote(id: note.id);
    _notes.removeWhere((note) => note.id == updatedNote.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
    // return DatabaseNote(
    //   id: note.id,
    //   userId: note.userId,
    //   text: text ?? note.text,
    //   isSyncedWithCloud: isSync ?? note.isSyncedWithCloud,
    // );
  }

  Future<List<DatabaseNote>> getAllNotes() async {
    // List<int> d = [];
    // for(int i=0;i<10;i++){
    //   d.add(i);
    // }
    // d.shuffle();
    // List<String> b = d.map((e) => 'MAMAD$e').toList();
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final listMapNotes = await db.query(
      noteTable,
    );
    return listMapNotes.map((e) => DatabaseNote.fromRow(e)).toList();
  }

  //   Future<Iterable<DatabaseNote>> getAllNotes() async {
  //   final db = _getDatabaseOrThrow();
  //   final notes = await db.query(noteTable);
  //
  //   return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  // }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final mapNotes = await db.query(
      noteTable,
      where: 'id=?',
      whereArgs: [id],
      limit: 1,
    );
    if (mapNotes.isNotEmpty) {
      final note = DatabaseNote.fromRow(mapNotes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    } else {
      throw CouldNotFindNote();
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id=?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((element) => element.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';
    // create the note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  // Future<DatabaseNote> createNote({
  //   required String email,
  //   String? text,
  //   bool isSyncedWithCloud = false,
  // }) async {
  //   final db = _getDatabaseOrThrow();
  //   final user = await getUser(email: email);
  //
  //   final id = await db.insert(noteTable, {
  //     userIdColumn: user.id,
  //     textColumn: text ?? '',
  //     isSyncedWithCloudColumn: isSyncedWithCloud ? 1 : 0,
  //   });
  //   return DatabaseNote(
  //     id: id,
  //     userId: user.id,
  //     text: text ?? '',
  //     isSyncedWithCloud: isSyncedWithCloud,
  //   );
  // }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final res = await db.query(
      userTable,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (res.isEmpty) throw CouldNotFindUser();
    final getMap = res.first;
    DatabaseUser databaseUser = DatabaseUser.fromRow(getMap);

    return databaseUser;
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;

    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      // Users/mahdishahbazi/Downloads/
      final docsPath = await getApplicationDocumentsDirectory();
      // Users/mahdishahbazi/Downloads/a/b/notes.db
      // final dbPath = join(docsPath.path, 'a','b' ,dbName);
      final dbPath = join(docsPath.path, dbName);

      final db = await openDatabase(dbPath);
      _db = db;
      //CREATE THE USER TABLE
      await db.execute(createUserTable);
      //CREATE THE NOTE TABLE
      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> mapUser)
      : id = mapUser[idColumn] as int,
        email = mapUser[emailColumn] as String;

  @override
  String toString() {
    return 'Person, ID = $id, email=$email';
  }

  @override
  bool operator ==(covariant DatabaseUser other) {
    return id == other.id;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> mapNote)
      : id = mapNote[idColumn] as int,
        userId = mapNote[userIdColumn] as int,
        text = mapNote[textColumn] as String,
        isSyncedWithCloud =
            (mapNote[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  // mapNote<String ,Object?> {
  //
  // ‘id’ → 1
  //
  // ‘userId’ → 2
  //
  // ‘text’ → “hello”
  //
  // ‘isSyncedWithCloud’ → false
  //
  // }
  //
  // String idColumn = ’id’
  //
  // int id = mapNote[idColumn] as int

  @override
  String toString() {
    return 'DatabaseNote{id: $id, userId: $userId, text: $text, isSyncedWithCloud: $isSyncedWithCloud}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DatabaseNote &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = ''' CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
        ); ''';
const createNoteTable = ''' CREATE TABLE IF NOT EXISTS "note" (
      	"id"	INTEGER NOT NULL,
      	"user_id"	INTEGER NOT NULL,
      	"text"	TEXT,
      	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
      	FOREIGN KEY("user_id") REFERENCES "user"("id"),
      	PRIMARY KEY("id" AUTOINCREMENT)
       ); ''';
