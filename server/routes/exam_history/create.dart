// lib/routes/exam_history/create.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final db = context.read<Database>();
  
  db.execute('''
    CREATE TABLE IF NOT EXISTS exam_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      studentId TEXT,
      batchId INTEGER,
      score REAL,
      createdAt TEXT
    );
  ''');

  final body = await context.request.json() as Map<String, dynamic>;
  final stmt = db.prepare('INSERT INTO exam_history (studentId, batchId, score, createdAt) VALUES (?, ?, ?, ?)');
  
  stmt.execute([
    body['studentId'],
    body['batchId'],
    body['score'],
    DateTime.now().toIso8601String(),
  ]);
  stmt.dispose();

  return Response.json(body: {'message': 'History saved'});
}