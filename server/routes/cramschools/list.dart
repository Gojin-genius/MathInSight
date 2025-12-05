// lib/routes/cramschools/list.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context){
  if(context.request.method != HttpMethod.get) {
    return Future.value(Response(statusCode: HttpStatus.methodNotAllowed));
  }

  final db = context.read<Database>();
  final ResultSet result = db.select('SELECT cramSchool FROM CramSchools');
  final cramSchools = result.map((row) => row['cramschool'] as String). toList();

  return Future.value(Response.json(body: cramSchools));
  
}