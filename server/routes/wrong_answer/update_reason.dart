// server/routes/wrong_answer/update_reason.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final db = context.read<Database>();
  
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final noteId = body['noteId'];
    final reason = body['reason'];

    print("저장 요청 -> ID: $noteId, 내용: $reason");

    if (noteId == null) {
      return Response(statusCode: HttpStatus.badRequest);
    }
    
    final stmt = db.prepare('UPDATE WrongAnswerNotes SET reason = ? WHERE noteId = ?');
    stmt.execute([reason, noteId]);
    stmt.dispose();
    
    print("저장 성공");
    return Response.json(body: {'message': 'Updated successfully'});
  } catch (e) {
    print("저장 에러: $e");
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  }
}