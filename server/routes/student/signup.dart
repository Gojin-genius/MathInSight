// lib/routes/student/signup.dart

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
  final name = json['name'] as String?;
  final age = json['age'] as int?;
  final school = json['school'] as String?;
  final cramschool = json['cramschool'] as String?;

  if (id == null || password == null || name == null || age == null || school == null || cramschool == null ) {
    return Response(statusCode: HttpStatus.badRequest, body: '필수 값이 누락되었습니다.');
  }

  final db = context.read<Database>();

  try {
    db.execute(
      'INSERT INTO students (id, password, name, age, school, cramschool) VALUES (?,?,?,?,?,?)',
      [id, password, name, age, school, cramschool],
    );

    print('새 학생 가입: $id (학원: $cramschool)');
    return Response(statusCode: HttpStatus.created, body: '학생 회원가입 성공');
  }
  on SqliteException catch (e) {
    if(e.extendedResultCode == SqlExtendedError.SQLITE_CONSTRAINT_UNIQUE) {
      return Response(statusCode: HttpStatus.conflict, body: '이미 사용 중인 ID입니다.');
    }
    
    if(e.extendedResultCode == SqlExtendedError.SQLITE_CONSTRAINT_FOREIGNKEY){
      return Response(statusCode: HttpStatus.badRequest, body: '존재하지 않는 학원입니다.');
    }

    return Response(statusCode: HttpStatus.internalServerError, body: 'DB 오류: ${e.message}');
  }
}