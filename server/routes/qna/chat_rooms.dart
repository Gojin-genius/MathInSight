// lib/routes/qna/chat_rooms.dart

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
    '''
    SELECT
      T1.id AS studentId,
      T1.name AS studentName,
      COALESCE(SUM(CASE WHEN T2.isReadByCramschool = 0 THEN 1 ELSE 0 END), 0) AS unreadCount 
    FROM Students AS T1
    LEFT JOIN QnAMessages AS T2
      ON T1.id = T2.studentId AND T1.cramschool = T2.cramschool
    WHERE T1.cramschool = ?
    GROUP BY T1.id, T1.name
    ORDER BY T1.name;
    ''',
    [cramschool],
  );

  final chatRooms = result.map((row) {
    return {
      'studentId': row['studentId'],
      'studentName': row['studentName'],
      'unreadCount': row['unreadCount'],
    };
  }).toList();

  return Response.json(body: chatRooms);
}