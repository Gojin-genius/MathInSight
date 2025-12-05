// lib/routes/cramschool/signup.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final json = await context.request.json() as Map<String, dynamic>;
  final id = json['id'] as String?;
  final password = json['password'] as String?;
  final cramschool = json['cramschool'] as String?;

  if (id == null || password == null || cramschool == null) {
    return Response(statusCode: HttpStatus.badRequest, body: '필수 항목 값이 누락되었습니다.');
  }

  final db = context.read<Database>();

  try {
    db.execute(
      'INSERT INTO CramSchools (id, password, cramschool) VALUES (?,?,?)',
      [id, password, cramschool],
    );
    print('새로운 학원 가입: $cramschool');
    return Response(statusCode: HttpStatus.created, body: '학원 회원가입 성공');
  }

  on SqliteException catch (e) {
    if(e.extendedResultCode == SqlExtendedError.SQLITE_CONSTRAINT_UNIQUE ||
    e.extendedResultCode == SqlExtendedError.SQLITE_CONSTRAINT_PRIMARYKEY) {
      return Response(statusCode: HttpStatus.conflict, body: '이미 사용 중인 ID 또는 학원 이름입니다.');
    }
    return Response(statusCode: HttpStatus.internalServerError, body: 'DB 오류:{e.message}');
  }
}