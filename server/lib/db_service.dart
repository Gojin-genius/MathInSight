// lib/db_service.dart

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

late final Database db;

void initDatabase() {
  final dbPath = p.join(Directory.current.path, 'data.db');
  db = sqlite3.open(dbPath);

  db.execute('''
    CREATE TABLE IF NOT EXISTS CramSchools(
      id TEXT PRIMARY KEY NOT NULL,
      password TEXT NOT NULL,
      cramschool TEXT NOT NULL UNIQUE
    );
''');

  db.execute('''
      CREATE TABLE IF NOT EXISTS Students(
        id TEXT PRIMARY KEY NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        school TEXT NOT NULL,
        cramschool TEXT NOT NULL,
        charactoristic TEXT,
        FOREIGN KEY (cramschool) REFERENCES CramSchools (cramschool)
      );
  ''');

  db.execute('''
      CREATE TABLE IF NOT EXISTS ExamBatches(
        batchId INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        cramschool TEXT NOT NULL,
        FOREIGN KEY (cramschool) REFERENCES CramSchools (cramschool)
      );
  ''');

  db.execute('''
      CREATE TABLE IF NOT EXISTS Questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        problem TEXT NOT NULL,
        answer TEXT NOT NULL,
        wrongOptions TEXT,  
        timeLimit INTEGER NOT NULL,
        subject TEXT NOT NULL,
        batchId INTEGER NOT NULL,
        FOREIGN KEY (batchId) REFERENCES ExamBatches (batchId)
      );
  ''');

  db.execute('''
      CREATE TABLE IF NOT EXISTS WrongAnswerNotes(
        noteId INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId TEXT NOT NULL,
        examBatchId INTEGER NOT NULL,
        examTitle TEXT NOT NULL,
        problem TEXT NOT NULL,
        correctAnswer TEXT NOT NULL,
        userAnswer TEXT NOT NULL,
        subject Text NOT NULL,
        reason TEXT,
        FOREIGN KEY (studentId) REFERENCES Students (id),
        FOREIGN KEY (examBatchId) REFERENCES ExamBatches (batchId)
      );
  ''');

  db.execute('''
      CREATE TABLE IF NOT EXISTS QnAMessages(
        messageId INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId TEXT NOT NULL,
        cramschool TEXT NOT NULL,
        senderName TEXT NOT NULL,
        message TEXT NOT NULL,
        isReadByCramschool INTEGER DEFAULT 0,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (cramschool) REFERENCES CramSchools (cramschool),
        FOREIGN KEY (studentId) REFERENCES Students (id)
      );
  ''');

  print('Database initialized at $dbPath');
}