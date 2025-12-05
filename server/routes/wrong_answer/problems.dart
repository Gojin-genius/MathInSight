// server/routes/wrong_answer/problems.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final params = context.request.uri.queryParameters;
  final studentId = params['studentId'];
  final examBatchIdString = params['examBatchId'];

  if(studentId == null || examBatchIdString == null) {
    return Response(statusCode: HttpStatus.badRequest, body: 'Missing parameters');
  }

  final examBatchId = int.tryParse(examBatchIdString);
  if(examBatchId == null) {
    return Response(statusCode: HttpStatus.badRequest, body: 'Invalid batchId');
  }

  final db = context.read<Database>();

  try {
    final ResultSet result = db.select(
      '''
      SELECT 
        noteId,        
        problem, 
        correctAnswer, 
        userAnswer, 
        reason 
      FROM WrongAnswerNotes 
      WHERE studentId = ? AND examBatchId = ?
      ''',
      [studentId, examBatchId],
    );

    final problems = result.map((row) {
      return {
        'noteId': row['noteId'], 
        'problem': row['problem'],
        'correctAnswer': row['correctAnswer'],
        'userAnswer': row['userAnswer'],
        'reason': row['reason'] ?? '',
      };
    }).toList();

    return Response.json(body: problems);

  } catch (e) {
    print("문제 조회 에러: $e");
    return Response.json(body: []);
  }
}