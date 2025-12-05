// lib/routes/exam_batch/create.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final json = await context.request.json() as Map<String, dynamic>;
  final title = json['title'] as String?;
  final cramschool = json['cramschool'] as String?;
  

  if (title == null || cramschool == null ) {
    return Response(statusCode: HttpStatus.badRequest, body: '필수 값이 누락되었습니다.');
  }

  final db = context.read<Database>();

    try {
    db.execute(
      'INSERT INTO ExamBatches (title, cramschool) VALUES (?,?)',
      [title, cramschool],
    );

   final int batchId = db.lastInsertRowId;

   return Response.json(body: {'batchId': batchId});
  }

  catch (e) {
    return Response(statusCode: HttpStatus.internalServerError, body: '서버 오류: $e');
  }
}