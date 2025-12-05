// lib/screens/student/student_wrong_note.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api_service.dart';
import '../../models.dart';
import '../../neural_ui.dart';

// 1. 오답노트 목록
class WrongNoteListScreen extends StatefulWidget {
  const WrongNoteListScreen({super.key});

  @override
  State<WrongNoteListScreen> createState() => _WrongNoteListScreenState();
}

class _WrongNoteListScreenState extends State<WrongNoteListScreen> {
  // 화면을 갱신하기 위해 Future를 변수로 관리하지 않고 build 때마다 호출하거나,
  // 상세 화면에서 돌아올 때 setState를 호출합니다.

  String _getStudentMessage(double percent) {
    if (percent >= 100) return "와우! 오답 정리를 완벽하게 끝냈어요! 🎉";
    if (percent >= 80) return "거의 다 왔어요! 마지막까지 파이팅 💪";
    if (percent >= 50) return "절반이나 채웠네요! 조금만 더 힘내요 🔥";
    if (percent >= 20) return "시작이 반이에요! 차근차근 적어봐요 📝";
    return "오답 정리는 성적 향상의 핵심이에요! 🚀";
  }

  Color _getProgressColor(double percent) {
    if (percent < 50) {
      return Color.lerp(Colors.redAccent, Colors.orangeAccent, percent / 50)!;
    } else {
      return Color.lerp(Colors.orangeAccent, const Color(0xFF2DD4BF), (percent - 50) / 50)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = context.read<UserProvider>().student!;
    
    return NeuralBackground(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent, 
            title: const Text("Wrong Answer Notes"),
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
          ),
          
          // 상단 통계 헤더
          FutureBuilder(
            future: context.read<ApiService>().getStudentNoteStats(student.id),
            builder: (context, snapshot) {
              // 데이터가 없어도 기본값 0으로 보여주기 위해 처리
              final stats = snapshot.data as Map<String, dynamic>? ?? {'total': 0, 'done': 0, 'percentage': 0.0};
              final total = stats['total'];
              final done = stats['done'];
              final double percent = (stats['percentage']).toDouble();

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _getProgressColor(percent).withOpacity(0.5)),
                  boxShadow: [BoxShadow(color: _getProgressColor(percent).withOpacity(0.1), blurRadius: 10)]
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("My Status", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(
                            _getStudentMessage(percent), 
                            style: TextStyle(color: _getProgressColor(percent), fontSize: 16, fontWeight: FontWeight.bold, height: 1.3)
                          ),
                        ],
                      ),
                    ),
                    // 숫자 표시 영역 (흰색 글씨 강제 적용)
                    Column(
                      children: [
                        Text(
                          "$done/$total",
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                        Text("Done", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10))
                      ],
                    )
                  ],
                ),
              );
            },
          ),

          Expanded(
            child: FutureBuilder(
              future: context.read<ApiService>().getWrongAnswerExams(student.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final list = snapshot.data as List;
                if (list.isEmpty) return const Center(child: Text("오답 노트가 비어있습니다.", style: TextStyle(color: Colors.white54)));
                
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return GlassCard(
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => WrongProblemScreen(batchId: item['examBatchId'], title: item['examTitle'])));
                        setState(() {}); 
                      },
                      child: ListTile(
                        title: Text(item['examTitle'], style: const TextStyle(color: Colors.white)),
                        subtitle: const Text("오답 확인 및 메모 작성", style: TextStyle(color: Color(0xFF2DD4BF))),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
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

// 2. 오답 상세 (기존과 동일)
class WrongProblemScreen extends StatefulWidget {
  final int batchId;
  final String title;
  const WrongProblemScreen({super.key, required this.batchId, required this.title});
  @override
  State<WrongProblemScreen> createState() => _WrongProblemScreenState();
}

class _WrongProblemScreenState extends State<WrongProblemScreen> {
  List<Map<String, dynamic>> _problems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    try {
      final student = context.read<UserProvider>().student!;
      final list = await context.read<ApiService>().getWrongProblems(student.id, widget.batchId);
      setState(() {
        _problems = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _editReason(int noteId, String? currentReason) {
    final ctrl = TextEditingController(text: currentReason);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        insetPadding: const EdgeInsets.all(15), 
        title: const Text("오답 노트 작성", style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width, 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("왜 틀렸는지, 어떤 개념이 부족했는지 기록해보세요.", style: TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 10),
              TextField(
                controller: ctrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 8, 
                decoration: const InputDecoration(
                  hintText: "예) 계산 실수, 공식 암기 부족...",
                  hintStyle: TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("취소", style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("저장", style: TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.bold)),
            onPressed: () async {
              await context.read<ApiService>().updateReason(noteId, ctrl.text);
              if (!mounted) return;
              Navigator.pop(context);
              _load(); 
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeuralBackground(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent, 
            title: Text(widget.title), 
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))
          ),
          
          Expanded(
            child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _problems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final p = _problems[index];
                return GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Q${index+1}.", style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text("${p['problem']}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.5)),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 20),
                        _buildAnswerRow("정답", p['correctAnswer'], const Color(0xFF2DD4BF)),
                        const SizedBox(height: 8),
                        _buildAnswerRow("내 답", p['userAnswer'], const Color(0xFFF472B6), isWrong: true),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => _editReason(p['noteId'], p['reason']),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: const [Icon(Icons.edit_note, color: Colors.white54, size: 16), SizedBox(width: 5), Text("MEMO", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold))]),
                                const SizedBox(height: 8),
                                Text(p['reason'] != null && p['reason'].toString().isNotEmpty ? "${p['reason']}" : "터치하여 틀린 이유를 작성하세요...", style: TextStyle(color: p['reason'] != null ? Colors.white : Colors.white30, fontSize: 15, height: 1.4)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerRow(String label, String value, Color color, {bool isWrong = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 50, child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14))),
        Expanded(child: Text(value, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16))),
      ],
    );
  }
}