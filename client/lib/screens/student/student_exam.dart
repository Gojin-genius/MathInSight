// lib/screens/student/student_exam.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api_service.dart';
import '../../models.dart';
import '../../neural_ui.dart';

// 1. 시험 목록 화면
class ExamListScreen extends StatelessWidget {
  const ExamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    if (userProvider.student == null) return const Center(child: Text("로그인 필요"));
    final student = userProvider.student!;

    return NeuralBackground(
      child: Column(
        children: [
          AppBar(backgroundColor: Colors.transparent, title: const Text("Exam List"), leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
          Expanded(
            child: FutureBuilder(
              future: Future.wait([
                context.read<ApiService>().getExamBatches(student.cramschool),
                context.read<ApiService>().getTakenExamIds(student.id),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final allExams = snapshot.data![0] as List<Map<String, dynamic>>;
                final takenIds = snapshot.data![1] as List<int>;
                final availableExams = allExams.where((exam) => !takenIds.contains(exam['batchId'])).toList();

                if (availableExams.isEmpty) return const Center(child: Text("남은 시험이 없습니다! 🎉", style: TextStyle(color: Colors.white54, fontSize: 18)));

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: availableExams.length,
                  itemBuilder: (context, index) {
                    final exam = availableExams[index];
                    return GlassCard(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExamSolvingScreen(batchId: exam['batchId'], title: exam['title']))),
                      child: ListTile(
                        title: Text(exam['title'], style: const TextStyle(color: Colors.white, fontSize: 18)),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 2. 시험 응시 화면
class ExamSolvingScreen extends StatefulWidget {
  final int batchId;
  final String title;
  const ExamSolvingScreen({super.key, required this.batchId, required this.title});
  @override
  State<ExamSolvingScreen> createState() => _ExamSolvingScreenState();
}

class _ExamSolvingScreenState extends State<ExamSolvingScreen> {
  List<Question> _questions = [];
  
  Map<int, String> _userAnswers = {}; 
  Map<int, List<String>> _generatedOptions = {};
  
  int _currentIndex = 0;
  bool _loading = true;

  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadQuestions() async {
    try {
      final qs = await context.read<ApiService>().getQuestions(widget.batchId);
      
      for (int i = 0; i < qs.length; i++) {
        _generatedOptions[i] = _generateOptions(qs[i]); 
      }

      setState(() {
        _questions = qs;
        _loading = false;
      });
      if (qs.isNotEmpty) _startTimerForQuestion(0);
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }



  List<String> _generateOptions(Question q) {
    List<String> options = [];
    
    options.add(q.answer);

    if (q.wrongOptions != null && q.wrongOptions!.isNotEmpty) {
      
      final wrongs = q.wrongOptions!.split(',').map((e) => e.trim()).toList();

      for (var w in wrongs) {
        if (!options.contains(w)) {
          options.add(w);
        }
      }
    } 
    
    if (options.length < 5) {
      double? numAns = double.tryParse(q.answer);
      Random random = Random();

      if (numAns != null) {
        while (options.length < 5) {
          int offset = random.nextInt(10) - 5; 
          if (offset == 0) offset = 1;
          
          String wrong;
          if (numAns % 1 == 0) {
            wrong = (numAns.toInt() + offset).toString();
          } else {
            wrong = (numAns + offset * 0.5).toStringAsFixed(1);
          }

          if (!options.contains(wrong)) {
            options.add(wrong);
          }
        }
      } else {
        // 숫자가 아닌 경우 더미 데이터 추가
        List<String> dummy = ["모름", "없음", "모두 정답", "정답 없음"];
        for (var d in dummy) {
          if (!options.contains(d) && options.length < 5) options.add(d);
        }
      }
    }

    options.shuffle();
    
    // 최대 5개까지만 잘라서 반환합니다.
    return options.take(5).toList();
  }

  void _startTimerForQuestion(int index) {
    _timer?.cancel();
    final q = _questions[index];
    setState(() => _remainingSeconds = q.timeLimit * 60);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _handleTimeOut(index);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _handleTimeOut(int index) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("시간 초과! 다음 문제로 넘어갑니다.", style: TextStyle(color: Colors.redAccent))));
    _userAnswers[index] = "(시간초과)"; 
    _moveToNext();
  }

  void _moveToNext() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
      _startTimerForQuestion(_currentIndex);
    } else {
      _submit();
    }
  }

  void _submit() async {
    _timer?.cancel();
    final student = context.read<UserProvider>().student!;
    
    int correctCount = 0;
    List<Map<String, dynamic>> results = [];

    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final userAns = _userAnswers[i] ?? ""; 
      final isCorrect = userAns.trim() == q.answer.trim();
      
      if (isCorrect) correctCount++;
      
      results.add({
        'studentId': student.id,
        'examBatchId': widget.batchId,
        'examTitle': widget.title,
        'problem': q.problem,
        'correctAnswer': q.answer,
        'userAnswer': userAns,
        'subject': q.subject,
        'isCorrect': isCorrect,
      });
    }

    final double score = (correctCount / (_questions.isEmpty ? 1 : _questions.length)) * 100;

    try {
      final wrongList = results.where((r) => r['isCorrect'] == false).toList();
      if (wrongList.isNotEmpty) {
        await context.read<ApiService>().saveWrongAnswers(wrongList);
      }
      await context.read<ApiService>().saveExamHistory(student.id, widget.batchId, score);
    } catch (e) {
      // ignore
    }

    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ExamResultScreen(score: score, results: results)));
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_questions.isEmpty) return const Scaffold(body: Center(child: Text("문제가 없습니다.")));

    final q = _questions[_currentIndex];
    final options = _generatedOptions[_currentIndex] ?? [];
    final selectedAnswer = _userAnswers[_currentIndex];

    return NeuralBackground(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Align(alignment: Alignment.centerRight, child: Text(_formatTime(_remainingSeconds), style: const TextStyle(color: Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: (_currentIndex + 1) / _questions.length, color: const Color(0xFF2DD4BF)),
            const SizedBox(height: 20),
            Text("Q${_currentIndex + 1}. ${q.subject}", style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 10),
            
            Expanded(
              flex: 2,
              child: GlassCard(
                child: Center(child: SingleChildScrollView(child: Text(q.problem, style: const TextStyle(fontSize: 22, color: Colors.white, height: 1.4), textAlign: TextAlign.center))),
              ),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              flex: 3,
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = selectedAnswer == option;
                  
                  return GestureDetector(
                    onTap: () => setState(() => _userAnswers[_currentIndex] = option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2DD4BF).withOpacity(0.8) : Colors.black45,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: isSelected ? const Color(0xFF2DD4BF) : Colors.white24),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: isSelected ? Colors.white : Colors.grey,
                            child: Text("${index + 1}", style: TextStyle(color: isSelected ? const Color(0xFF2DD4BF) : Colors.black, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 15),
                          Expanded(child: Text(option, style: const TextStyle(color: Colors.white, fontSize: 18))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 150,
                  child: NeonButton(
                    text: _currentIndex == _questions.length - 1 ? "제출" : "다음",
                    onPressed: _moveToNext,
                    color: _currentIndex == _questions.length - 1 ? const Color(0xFFF472B6) : const Color(0xFF2DD4BF),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ExamResultScreen extends StatelessWidget {
  final double score;
  final List<Map<String, dynamic>> results;

  const ExamResultScreen({super.key, required this.score, required this.results});

  @override
  Widget build(BuildContext context) {
    return NeuralBackground(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text("시험 결과", style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
            Text("${score.toStringAsFixed(1)}점", style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 50, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.separated(
                itemCount: results.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final r = results[index];
                  final isCorrect = r['isCorrect'];
                  return GlassCard(
                    child: ListTile(
                      leading: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                        size: 30,
                      ),
                      title: Text("Q${index + 1}. ${r['problem']}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text("내 답: ${r['userAnswer']}", style: TextStyle(color: isCorrect ? Colors.white70 : Colors.redAccent)),
                          if (!isCorrect) Text("정답: ${r['correctAnswer']}", style: const TextStyle(color: Colors.greenAccent)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            NeonButton(
              text: "목록으로 돌아가기",
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}