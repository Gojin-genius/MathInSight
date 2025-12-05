// lib/screens/cramschool/cram_exam.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api_service.dart';
import '../../models.dart';
import '../../neural_ui.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({super.key});
  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final _titleCtrl = TextEditingController();
  int? _batchId;
  int _questionCount = 0;

  final List<String> _subjects = [
    '수학 I', '수학 II', '미적분', '확률과 통계', '기하', '중등 수학', '고등 수학(상)', '고등 수학(하)'
  ];

  // 시간 리스트 (1분 ~ 10분)
  final List<int> _times = List.generate(10, (index) => index + 1);

  void _createBatch() async {
    if (_titleCtrl.text.isEmpty) return;
    final cram = context.read<UserProvider>().cramSchool!;
    try {
      final id = await context.read<ApiService>().createExamBatch(_titleCtrl.text, cram.cramschool);
      setState(() => _batchId = id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _addQuestion(String problem, String answer, int time, String subject) async {
    if (problem.isEmpty || answer.isEmpty) return;
    try {
      await context.read<ApiService>().createQuestion({
        'problem': problem, 
        'answer': answer, 
        'timeLimit': time, 
        'subject': subject, 
        'batchId': _batchId
      });
      setState(() => _questionCount++);
      if (!mounted) return;
      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("문제 추가 실패")));
    }
  }

  void _showAddDialog() {
    final pCtrl = TextEditingController();
    final aCtrl = TextEditingController();
    
    // 기본값 설정
    String selectedSubject = _subjects[0];
    int selectedTime = _times[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Text("문제 추가", style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: pCtrl,
                        maxLines: 5, 
                        minLines: 3,
                        decoration: const InputDecoration(
                          labelText: "문제 내용",
                          labelStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true, 
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      
                      TextField(
                        controller: aCtrl,
                        decoration: const InputDecoration(
                          labelText: "정답",
                          labelStyle: TextStyle(color: Colors.white54),
                          filled: true, 
                          fillColor: Colors.black26
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),

                      DropdownButtonFormField<int>(
                        value: selectedTime,
                        dropdownColor: const Color(0xFF1E293B),
                        decoration: const InputDecoration(
                          labelText: "제한 시간 (분)",
                          labelStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.black26,
                        ),
                        style: const TextStyle(color: Colors.white),
                        items: _times.map((t) => DropdownMenuItem(value: t, child: Text("$t 분"))).toList(),
                        onChanged: (v) {
                          if (v != null) setDialogState(() => selectedTime = v);
                        },
                      ),
                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: selectedSubject,
                        dropdownColor: const Color(0xFF1E293B),
                        decoration: const InputDecoration(
                          labelText: "과목",
                          labelStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.black26,
                        ),
                        style: const TextStyle(color: Colors.white),
                        items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) {
                          if (v != null) setDialogState(() => selectedSubject = v);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소", style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () => _addQuestion(pCtrl.text, aCtrl.text, selectedTime, selectedSubject),
                  child: const Text("추가", style: TextStyle(color: Color(0xFF2DD4BF))),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeuralBackground(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _batchId == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NeuralTextField(controller: _titleCtrl, label: "시험 제목", icon: Icons.title),
                  const SizedBox(height: 20),
                  NeonButton(text: "시험지 생성 시작", onPressed: _createBatch),
                ],
              )
            : Column(
                children: [
                  const SizedBox(height: 40),
                  Text("시험: ${_titleCtrl.text}", style: const TextStyle(color: Colors.white, fontSize: 24)),
                  Text("등록된 문제: $_questionCount 개", style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 40),
                  NeonButton(text: "문제 추가 (+)", onPressed: _showAddDialog),
                  const SizedBox(height: 20),
                  if (_questionCount >= 1) NeonButton(text: "출제 완료", onPressed: () => Navigator.pop(context), color: Colors.grey),
                ],
              ),
      ),
    );
  }
}