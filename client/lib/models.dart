import 'package:flutter/material.dart';

// --- Data Models ---
class Student {
  final String id;
  final String name;
  final int age;
  final String school;
  final String cramschool;
  final String? charactoristic;

  Student({
    required this.id,
    required this.name,
    required this.age,
    required this.school,
    required this.cramschool,
    this.charactoristic,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      school: json['school'],
      cramschool: json['cramschool'],
      charactoristic: json['charactoristic'],
    );
  }
}

class CramSchool {
  final String id;
  final String cramschool;

  CramSchool({required this.id, required this.cramschool});

  factory CramSchool.fromJson(Map<String, dynamic> json) {
    return CramSchool(
      id: json['id'],
      cramschool: json['cramschool'],
    );
  }
}

class Question {
  final int? id;
  final String problem;
  final String answer;
  final int timeLimit;
  final String subject;
  final int? batchId;
  final String? wrongOptions;

  Question({
    this.id,
    required this.problem,
    required this.answer,
    required this.timeLimit,
    required this.subject,
    this.batchId,
    this.wrongOptions,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      problem: json['problem'],
      answer: json['answer'],
      wrongOptions: json['wrongOptions'],
      timeLimit: json['timeLimit'],
      subject: json['subject'],
    );
  }
}

class ChatMessage {
  final String senderName;
  final String message;

  ChatMessage({required this.senderName, required this.message});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderName: json['senderName'],
      message: json['message'],
    );
  }
}

// --- State Management (UserProvider) ---
class UserProvider extends ChangeNotifier {
  Student? student;
  CramSchool? cramSchool;

  void setStudent(Student s) {
    student = s;
    cramSchool = null;
    notifyListeners();
  }

  void setCramSchool(CramSchool c) {
    cramSchool = c;
    student = null;
    notifyListeners();
  }

  void logout() {
    student = null;
    cramSchool = null;
    notifyListeners();
  }
}