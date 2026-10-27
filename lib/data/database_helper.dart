import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';
import '../models/user.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final path = kIsWeb ? 'notas.db' : join(await getDatabasesPath(), 'notas.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            salt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            color INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt$password')).toString();
  }

  Future<User?> register(String username, String password) async {
    final db = await database;
    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (existing.isNotEmpty) return null;

    final salt = _generateSalt();
    final id = await db.insert('users', {
      'username': username,
      'password_hash': _hash(password, salt),
      'salt': salt,
    });
    return User(id: id, username: username);
  }

  Future<User?> login(String username, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    final hash = _hash(password, row['salt'] as String);
    if (hash != row['password_hash']) return null;
    return User.fromMap(row);
  }

  Future<List<Note>> getNotes(int userId, {String query = ''}) async {
    final db = await database;
    final rows = query.isEmpty
        ? await db.query(
            'notes',
            where: 'user_id = ?',
            whereArgs: [userId],
            orderBy: 'updated_at DESC',
          )
        : await db.query(
            'notes',
            where: 'user_id = ? AND (title LIKE ? OR content LIKE ?)',
            whereArgs: [userId, '%$query%', '%$query%'],
            orderBy: 'updated_at DESC',
          );
    return rows.map(Note.fromMap).toList();
  }

  Future<Note> saveNote(Note note) async {
    final db = await database;
    if (note.id == null) {
      final map = note.toMap()..remove('id');
      final id = await db.insert('notes', map);
      return note.copyWith(id: id);
    }
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [note.id, note.userId],
    );
    return note;
  }

  Future<void> deleteNote(int id, int userId) async {
    final db = await database;
    await db.delete(
      'notes',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }
}
