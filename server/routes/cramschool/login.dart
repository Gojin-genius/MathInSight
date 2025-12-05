// lib/routes/cramschool/login.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final json= await context.request.json() as Map<String, dynamic>;
  final id = json['id'] as String?;
  final password = json['password'] as String?;

  if(id == null || password == null) {
    return Response(statusCode: HttpStatus.badRequest, body: 'ID or PassWord가 누락되었습니다.');
  }

  final db = context.read<Database>();

  final ResultSet result = db.select(
    'SELECT id, cramschool FROM CramSchools WHERE id = ? AND password = ?',
    [id, password],
  );

  if(result.isEmpty) {
    return Response(statusCode: HttpStatus.unauthorized, body: 'ID or Password가 틀립니다.');
  }

  final row = result.first;

  final cramSchoolJson = {
    'id': row['id'],
    'cramschool': row['cramschool'],
  };

  return Response.json(
    body: {
      'message': '학원 로그인 성공',
      'cramschool': cramSchoolJson,
    },
  );
}