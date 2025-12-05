// lib/routes/student/info.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final params = context.request.uri.queryParameters;
  final studentId = params['studentId'];

  if (studentId == null) {
    return Response(statusCode: HttpStatus.badRequest, body: 'studentId가 필요합니다.');
  }

  final db = context.read<Database>();
  final ResultSet result = db.select(
    'SELECT name, age, school, charactoristic FROM Students WHERE id = ?',
    [studentId],
  );

  if (result.isEmpty) {
    return Response(statusCode: HttpStatus.notFound, body: '학생을 찾을 수 없습니다.');
  }

  final info = result.first;
  return Response.json(body: {
    'name': info['name'],
    'age': info['age'],
    'school': info['school'],
    'charactoristic': info['charactoristic'],
  });
}