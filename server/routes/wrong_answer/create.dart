// lib/routes/wrong_answer/create.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final jsonList = await context.request.json() as List<dynamic>;
  final db = context.read<Database>();

  try {
    for (final json in jsonList) {
      final map = json as Map<String, dynamic>;
      db.execute(
        'INSERT INTO WrongAnswerNotes (studentId, examBatchId, examTitle, problem, correctAnswer, userAnswer, subject) VALUES (?,?,?,?,?,?,?)',
        [
          map['studentId'],
          map['examBatchId'],
          map['examTitle'],
          map['problem'],
          map['correctAnswer'],
          map['userAnswer'],
          map['subject'],
        ],
      );
    }
    return Response(statusCode: HttpStatus.created, body: '오답이 저장되었습니다.');
  }
  catch (e) {
    return Response(statusCode: HttpStatus.internalServerError, body: '서버 오류: $e');
  }
}