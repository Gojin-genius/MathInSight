// lib/routes/question/list.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final params = context.request.uri.queryParameters;
  final batchId = params['batchId'];

  if(batchId == null) {
    return Response(statusCode: HttpStatus.badRequest, body: 'batchId가 필요합니다.');
  }

  final db = context.read<Database>();
  final ResultSet result = db.select(
    'SELECT id, problem, answer, wrongOptions, timeLimit, subject FROM Questions WHERE batchId = ?',
    [batchId],
  );


  final questions = result.map((row) {
    return {
      'id': row['id'],
      'problem': row['problem'],
      'answer': row['answer'],
      'wrongOptions': row['wrongOptions'],
      'timeLimit': row['timeLimit'],
      'subject': row['subject'],
    };
  }).toList();
  
  return Response.json(body: questions);
}