// lib/routes/cramschool/students.dart

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
    return Response(statusCode: HttpStatus.badRequest, body: 'cramschool이 필요합니다.');
  }

  final db = context.read<Database>();
  final ResultSet result = db.select(
    'SELECT id, name, school, age FROM Students WHERE cramschool = ? ORDER BY name',
    [cramschool],
  );

  final students = result.map((row) {
    return {
      'id': row['id'],
      'name': row['name'],
      'school': row['school'],
      'age': row['age'],
    };
  }).toList();

  return Response.json(body: students);
}