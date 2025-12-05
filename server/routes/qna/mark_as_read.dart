// lib/routes/qna/mark_as_read.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final json = await context.request.json() as Map<String, dynamic>;
  final cramschool = json['cramschool'] as String?;
  final studentId = json['studentId'] as String?;

  if(cramschool == null || studentId == null) {
    return Response(statusCode: HttpStatus.badRequest, body: 'cramschool과 studentId가 필요합니다.');
  }

  final db = context.read<Database>();

  try {
    db.execute(
      'UPDATE QnAMessages SET isReadByCramschool = 1 WHERE cramschool = ? AND studentId = ? AND isReadByCramschool = 0',
      [cramschool, studentId],
    );
    return Response(body: '메시지를 읽었습니다.');
  }
  catch (e) {
    return Response(statusCode: HttpStatus.internalServerError, body: '서버 오류: $e');
  }
}