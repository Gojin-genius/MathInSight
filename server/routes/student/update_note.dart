// lib/routes/student/update_note.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final json = await context.request.json() as Map<String, dynamic>;
  final studentId = json['studentId'] as String?;
  final charactoristic = json['charactoristic'] as String?;

  if(studentId == null || charactoristic == null) {
    return Response(statusCode: HttpStatus.badRequest, body: 'studentId와 charactoristic가 필요합니다');
  }

  final db = context.read<Database>();

  try {
    db.execute(
      'UPDATE Students SET charactoristic = ? WHERE id = ?',
      [charactoristic, studentId],
    );
    return Response(body: '학생 특징이 저장되었습니다.');
  }
  catch (e) {
    return Response(statusCode: HttpStatus.internalServerError, body: '서버 오류: $e');
  }
}