// lib/routes/exam_batch/list.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final params = context.request.uri.queryParameters;
  final cramschool = params['cramschool'];

  if(cramschool == null) {
    return Response(statusCode: HttpStatus.badRequest, body: '학원 이름이 필요합니다.');
  }

  final db = context.read<Database>();
  final ResultSet result = db.select(
    'SELECT batchId, title FROM ExamBatches WHERE cramschool = ?',
    [cramschool],
  );

  final examBatches = result.map((row) {
    return {
      'batchId': row['batchId'],
      'title': row['title'],
    };
  }).toList();
  return Response.json(body: examBatches);
}