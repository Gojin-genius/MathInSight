// lib/api_service.dart

import 'dart:convert';
import 'dart:io'; // 플랫폼 감지용 (Android, Windows 등)
import 'package:flutter/foundation.dart'; // 웹(kIsWeb) 감지용
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiService {
  // ------------------------------------------------------------------------
  // 1. 환경에 따른 Base URL 자동 설정
  // ------------------------------------------------------------------------
  String get _baseUrl {
    // 웹 브라우저
    if (kIsWeb) return 'http://localhost:8080';
    
    // 안드로이드 에뮬레이터
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    
    // iOS 시뮬레이터, 윈도우(Windows), 맥(macOS) 등 데스크탑
    return 'http://localhost:8080';
  }

  // ------------------------------------------------------------------------
  // 2. 인증 (Auth) - 로그인 & 회원가입
  // ------------------------------------------------------------------------
  Future<Map<String, dynamic>> login(String type, String id, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$type/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('로그인 실패: ${response.body}');
  }

  Future<void> signup(String type, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$type/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('회원가입 실패: ${response.body}');
    }
  }

  // 학원 목록 조회 (회원가입 시 드롭다운용)
  Future<List<String>> getCramSchoolList() async {
    final response = await http.get(Uri.parse('$_baseUrl/cramschools/list'));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    }
    return [];
  }

  // ------------------------------------------------------------------------
  // 3. 시험 & 문제 (Exam & Questions)
  // ------------------------------------------------------------------------
  
  // [학생/학원] 시험지 목록 조회
  Future<List<Map<String, dynamic>>> getExamBatches(String cramschool) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/exam_batch/list?cramschool=$cramschool'),
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  // [학생] 특정 시험의 문제 목록 조회
  Future<List<Question>> getQuestions(int batchId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/question/list?batchId=$batchId'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => Question.fromJson(e)).toList();
    }
    return [];
  }

  // [학원] 새 시험지 생성 (Batch)
  Future<int> createExamBatch(String title, String cramschool) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/exam_batch/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'cramschool': cramschool}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['batchId'];
    }
    throw Exception('시험 생성 실패: ${response.body}');
  }

  // [학원] 문제 등록
  Future<void> createQuestion(Map<String, dynamic> data) async {
    await http.post(
      Uri.parse('$_baseUrl/question/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  // ------------------------------------------------------------------------
  // 4. 오답 노트 (Wrong Answer Notes)
  // ------------------------------------------------------------------------
  
  // [학생] 오답 저장 (시험 종료 후)
  Future<void> saveWrongAnswers(List<Map<String, dynamic>> wrongAnswers) async {
    await http.post(
      Uri.parse('$_baseUrl/wrong_answer/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(wrongAnswers),
    );
  }

  // [학생] 오답 노트가 있는 시험 목록 조회
  Future<List<Map<String, dynamic>>> getWrongAnswerExams(String studentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/wrong_answer/exams?studentId=$studentId'),
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  // [학생] 특정 시험의 오답 문제 상세 조회
  Future<List<Map<String, dynamic>>> getWrongProblems(String studentId, int batchId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/wrong_answer/problems?studentId=$studentId&examBatchId=$batchId'),
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  // [학생] 틀린 이유 수정
  Future<void> updateReason(int noteId, String reason) async {
    await http.post(
      Uri.parse('$_baseUrl/wrong_answer/update_reason'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'noteId': noteId, 'reason': reason}),
    );
  }

  // ------------------------------------------------------------------------
  // 5. 학생 정보 & 관리 (For Cram School)
  // ------------------------------------------------------------------------
  
  // [학원] 소속 학생 목록 조회
  Future<List<Map<String, dynamic>>> getStudentList(String cramschool) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cramschool/students?cramschool=$cramschool'),
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  // [학원] 학생 상세 정보 조회
  Future<Map<String, dynamic>> getStudentInfo(String studentId) async {
    final response = await http.get(Uri.parse('$_baseUrl/student/info?studentId=$studentId'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('학생 정보 로드 실패');
  }

  // [학원] 학생 취약점(오답률) 분석 조회
  Future<List<Map<String, dynamic>>> getWeakness(String studentId) async {
    final response = await http.get(Uri.parse('$_baseUrl/student/weakness?studentId=$studentId'));
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    return [];
  }

  // [학원] 학생 특징 메모 업데이트
  Future<void> updateStudentNote(String studentId, String note) async {
    await http.post(
      Uri.parse('$_baseUrl/student/update_note'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentId': studentId, 'charactoristic': note}),
    );
  }

  // ------------------------------------------------------------------------
  // 6. Q&A 채팅 (Chat)
  // ------------------------------------------------------------------------
  
  // [공통] 채팅 메시지 목록 조회
  Future<List<ChatMessage>> getMessages(String cramschool, String studentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/qna/messages?cramschool=$cramschool&studentId=$studentId'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => ChatMessage.fromJson(e)).toList();
    }
    return [];
  }

  // [공통] 메시지 전송
  Future<void> sendMessage(Map<String, dynamic> data) async {
    await http.post(
      Uri.parse('$_baseUrl/qna/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  // [학원] 채팅방 목록 조회
  Future<List<Map<String, dynamic>>> getChatRooms(String cramschool) async {
    final response = await http.get(Uri.parse('$_baseUrl/qna/chat_rooms?cramschool=$cramschool'));
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    return [];
  }

  // [학원] 읽음 처리
  Future<void> markAsRead(String cramschool, String studentId) async {
    await http.post(
      Uri.parse('$_baseUrl/qna/mark_as_read'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cramschool': cramschool, 'studentId': studentId}),
    );
  }
  
  Future<void> saveExamHistory(String studentId, int batchId, double score) async {
    await http.post(
      Uri.parse('$_baseUrl/exam_history/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': studentId,
        'batchId': batchId,
        'score': score,
      }),
    );
  }

  Future<List<int>> getTakenExamIds(String studentId) async {
    final response = await http.get(Uri.parse('$_baseUrl/exam_history/list?studentId=$studentId'));
    if (response.statusCode == 200) {
      return List<int>.from(jsonDecode(response.body));
    }
    return [];
  }

  Future<Map<String, dynamic>> getStudentNoteStats(String studentId) async {
    final response = await http.get(Uri.parse('$_baseUrl/student/note_stats?studentId=$studentId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {'total': 0, 'done': 0, 'percentage': 0.0};
  } 
}