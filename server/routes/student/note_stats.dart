// lib/routes/student/node_stats.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final db = context.read<Database>();
  final params = context.request.uri.queryParameters;
  final studentId = params['studentId'];

  if (studentId == null) return Response.json(body: {'total': 0, 'done': 0, 'percentage': 0.0});

  try {
    final totalRes = db.select('SELECT COUNT(*) as cnt FROM WrongAnswerNotes WHERE studentId = ?', [studentId]);
    final total = totalRes.first['cnt'] as int;

    final doneRes = db.select(
      "SELECT COUNT(*) as cnt FROM WrongAnswerNotes WHERE studentId = ? AND reason IS NOT NULL AND reason != '' AND trim(reason) != ''", 
      [studentId]
    );
    final done = doneRes.first['cnt'] as int;

    double percentage = 0.0;
    if (total > 0) percentage = (done / total) * 100;

    return Response.json(body: {
      'total': total,
      'done': done,
      'percentage': percentage,
    });
  } catch (e) {
    return Response.json(body: {'total': 0, 'done': 0, 'percentage': 0.0});
  }
}