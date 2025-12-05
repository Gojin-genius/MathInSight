// test/server/bulk_insert_test.dart

import 'package:test/test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Database db;

  setUp(() {
    db = sqlite3.openInMemory();

    db.execute('''
      CREATE TABLE WrongAnswerNotes (
        noteId INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId TEXT,
        problem TEXT,
        userAnswer TEXT,
        examBatchId INTEGER,
        examTitle TEXT,
        correctAnswer TEXT,
        subject TEXT,
        reason TEXT
      )
    ''');
  });

  tearDown(() {
    db.dispose();
  });

  test('한꺼번에 오답노트 3개 저장 테스트', () {

    final List<Map<String, dynamic>> wrongAnswers = [
      {
        'studentId': 'std1',
        'problem': '1+1=?',
        'userAnswer': '3',
        'examBatchId': 1,
        'examTitle': '중간',
        'correctAnswer': '2',
        'subject': '수학'
      },
      {
        'studentId': 'std1',
        'problem': '2+2=?',
        'userAnswer': '5',
        'examBatchId': 1,
        'examTitle': '중간',
        'correctAnswer': '4',
        'subject': '수학'
      },
      {
        'studentId': 'std1',
        'problem': '3+3=?',
        'userAnswer': '7',
        'examBatchId': 1,
        'examTitle': '중간',
        'correctAnswer': '6',
        'subject': '수학'
      },
    ];

    for (final map in wrongAnswers) {
      db.execute(
        'INSERT INTO WrongAnswerNotes (studentId, problem, userAnswer, examBatchId, examTitle, correctAnswer, subject) VALUES (?,?,?,?,?,?,?)',
        [
          map['studentId'],
          map['problem'],
          map['userAnswer'],
          map['examBatchId'],
          map['examTitle'],
          map['correctAnswer'],
          map['subject'],
        ],
      );
    }

    final result = db.select('SELECT COUNT(*) as cnt FROM WrongAnswerNotes');
    final count = result.first['cnt'];

    print('저장된 오답 개수: $count');
    expect(count, equals(3));
    
    final firstRow = db.select('SELECT problem FROM WrongAnswerNotes WHERE problem="1+1=?"');
    expect(firstRow.isNotEmpty, isTrue);
  });
}