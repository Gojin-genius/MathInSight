// lib/routes/wrong_answer/exams.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final params = context.request.uri.queryParameters;
  final studentId = params['studentId'];

  if(studentId == null) {
    return Response(statusCode: HttpStatus.badRequest, body: 'studentId가 필요합니다.');
  }

  final db = context.read<Database>();

  final ResultSet result = db.select(
    'SELECT DISTINCT examBatchId, examTitle FROM WrongAnswerNotes WHERE studentId = ?',
    [studentId],
  );

  final exams = result.map((row) {
    return {
      'examBatchId': row['examBatchId'],
      'examTitle': row['examTitle'],
    };
  }).toList();

  return Response.json(body: exams);
}