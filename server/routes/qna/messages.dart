// lib/routes/qna/messages.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final params = context.request.uri.queryParameters;
  final cramschool = params['cramschool'];
  final studentId = params['studentId'];

  if(cramschool == null || studentId == null) {
    return Response(statusCode: HttpStatus.badRequest, body: 'cramschool과 studentId가 필요합니다.');
  }

  final db = context.read<Database>();

  final ResultSet result = db.select(
    'SELECT senderName, message FROM QnAMessages WHERE cramschool = ? AND studentId = ? ORDER BY timestamp ASC',
    [cramschool, studentId],
  );

  final messages = result.map((row) {
    return {
      'senderName': row['senderName'],
      'message': row['message'],
    };
  }).toList();

  return Response.json(body: messages);
}