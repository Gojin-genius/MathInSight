// lib/routes/student/weakness.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final params = context.request.uri.queryParameters;
  final studentId = params['studentId'];

  if (studentId == null) {
    return Response(statusCode: HttpStatus.badRequest, body: 'studentId가 필요합니다.');
  }

  final db = context.read<Database>();

  final totalResult = db.select(
    'SELECT COUNT(*) as totalCount FROM WrongAnswerNotes WHERE studentId = ?',
    [studentId],
  );

  final totalCount = totalResult.first['totalCount'] as int;
  if (totalCount == 0) {
    return Response.json(body: []);
  }

  final ResultSet result = db.select(
    'SELECT subject, COUNT(*) as wrongCount FROM WrongAnswerNotes WHERE studentId = ? GROUP BY subject ORDER BY wrongCount DESC',
    [studentId],
  );

  final weaknesses = result.map((row) {
    final wrongCount = row['wrongCount'] as int;
    final percentage = (wrongCount / totalCount) * 100;
    return {
      'subject': row['subject'],
      'percentage': percentage.toStringAsFixed(1),
    };
  }).toList();

  return Response.json(body: weaknesses);
}