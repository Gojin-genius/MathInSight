// lib/routes/exam_history/list.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) return Response(statusCode: HttpStatus.methodNotAllowed);

  final db = context.read<Database>();
  final params = context.request.uri.queryParameters;
  final studentId = params['studentId'];

  try {
    final result = db.select('SELECT batchId FROM exam_history WHERE studentId = ?', [studentId]);
    final list = result.map((row) => row['batchId'] as int).toList();
    return Response.json(body: list);
  } catch (e) {
    return Response.json(body: []); 
  }
}