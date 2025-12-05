// test/server/weakness_test.dart

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
        subject TEXT
      );
    ''');
  });

  tearDown(() {
    db.dispose();
  });

  test('취약점 분석 로직이 과목별 비율을 정확히 계산하는지 테스트', () {
    // 1. 가짜 데이터 삽입 (총 10개: 미적분 7개, 수학I 3개)
    final studentId = 'std1';
    for (int i = 0; i < 7; i++) {
      db.execute("INSERT INTO WrongAnswerNotes (studentId, subject) VALUES (?, ?)", [studentId, '미적분']);
    }
    for (int i = 0; i < 3; i++) {
      db.execute("INSERT INTO WrongAnswerNotes (studentId, subject) VALUES (?, ?)", [studentId, '수학I']);
    }

    final totalResult = db.select('SELECT COUNT(*) as totalCount FROM WrongAnswerNotes WHERE studentId = ?', [studentId]);
    final totalCount = totalResult.first['totalCount'] as int;

    final resultSet = db.select(
      'SELECT subject, COUNT(*) as wrongCount FROM WrongAnswerNotes WHERE studentId = ? GROUP BY subject ORDER BY wrongCount DESC',
      [studentId],
    );

    final results = resultSet.map((row) {
      return {
        'subject': row['subject'],
        'percentage': (row['wrongCount'] as int) / totalCount * 100,
      };
    }).toList();

    expect(totalCount, equals(10)); 
    expect(results.length, equals(2)); 

    // 1위: 미적분 (70%)
    expect(results[0]['subject'], equals('미적분'));
    expect(results[0]['percentage'], equals(70.0));

    // 2위: 수학I (30%)
    expect(results[1]['subject'], equals('수학I'));
    expect(results[1]['percentage'], equals(30.0));
  });
}