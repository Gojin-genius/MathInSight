// lib/routes/question/create.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:dotenv/dotenv.dart';

Future<Response> onRequest(RequestContext context) async {

  var env = DotEnv(includePlatformEnvironment: true)..load();
  final apiKey = env['GEMINI_API_KEY']; 

  if (apiKey == null) {
    return Response(statusCode: 500, body: '서버 설정 오류: API Key 없음');
  }
  
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final json = await context.request.json() as Map<String, dynamic>;
  final problem = json['problem'] as String?;
  final answer = json['answer'] as String?;
  final timeLimit = json['timeLimit'] as int?;
  final subject = json['subject'] as String?;
  final batchId = json['batchId'] as int?;

  if (problem == null || answer == null || timeLimit == null || subject == null || batchId == null ) {
    return Response(statusCode: HttpStatus.badRequest, body: '필수 항목 값이 누락되었습니다.');
  }

  String wrongOptions = ""; 
  try {
    print("Gemini에게 오답 생성 요청 중...");
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
    
    final prompt = '''
      수학 문제: "$problem"
      정답: "$answer"
      
      이 문제에 대해 학생들이 틀리기 쉬운 '오답 보기' 4개를 만들어줘.
      설명 없이 오직 숫자(또는 답) 4개만 쉼표(,)로 구분해서 출력해.
      예시: 12, 15, 18, 20
    ''';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    
    // 응답 예시: "11, 13, 15, 17"
    wrongOptions = response.text?.replaceAll('\n', '').trim() ?? "";
    print("Gemini 응답: $wrongOptions");

  } catch (e) {
    print("Gemini API 오류 (기본값으로 저장됩니다): $e");
    wrongOptions = ""; 
  }

  final db = context.read<Database>();

  try {
    db.execute(
      'INSERT INTO Questions (problem, answer, wrongOptions, timeLimit, subject, batchId) VALUES (?,?,?,?,?,?)',
      [problem, answer, wrongOptions, timeLimit, subject, batchId],
    );

    return Response(statusCode: HttpStatus.created, body: 'AI가 생성한 오답과 함께 문제가 출제되었습니다.');
  } on SqliteException catch (e) {
    return Response(statusCode: HttpStatus.internalServerError, body: 'DB 오류: ${e.message}');
  }
}