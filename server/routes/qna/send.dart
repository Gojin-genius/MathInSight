// lib/routes/qna/send.dart

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
  final senderName = json['senderName'] as String?;
  final message = json['message'] as String?;
  final userType = json['userType'] as String?;

  if (cramschool == null || studentId == null || senderName == null || message == null || userType == null) {
    return Response(statusCode: HttpStatus.badRequest,body: '필수 파라미터가 누락되었습니다.');
  }

  final isRead= (userType == 'student') ? 0 : 1;

  final db = context.read<Database>();

  try {
    db.execute(
      'INSERT INTO QnAMessages (cramschool, studentId, senderName, message, isReadByCramschool) VALUES (?,?,?,?,?)',
      [cramschool, studentId, senderName, message, isRead],
    );
    return Response(statusCode: HttpStatus.created, body: '메시지가 저장되었습니다.');
  }
  catch (e) {
    return Response(statusCode: HttpStatus.internalServerError, body: '서버 오류: $e');
  }
}