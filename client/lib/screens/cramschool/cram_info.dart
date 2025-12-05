// lib/screens/cramschool/cram_info.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../api_service.dart';
import '../../models.dart';
import '../../neural_ui.dart';

// 1. 학생 목록
class StudentInfoListScreen extends StatelessWidget {
  const StudentInfoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cram = context.read<UserProvider>().cramSchool!;
    return NeuralBackground(
      child: Column(
        children: [
          AppBar(backgroundColor: Colors.transparent, title: const Text("Student List"), leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
          Expanded(
            child: FutureBuilder(
              future: context.read<ApiService>().getStudentList(cram.cramschool),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final list = snapshot.data as List;
                if (list.isEmpty) return const Center(child: Text("등록된 학생이 없습니다.", style: TextStyle(color: Colors.white54)));
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final s = list[index];
                    return GlassCard(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetailScreen(studentId: s['id']))),
                      child: ListTile(
                        title: Text(s['name'], style: const TextStyle(color: Colors.white)),
                        subtitle: Text("${s['school']} / ${s['age']}세", style: const TextStyle(color: Colors.white54)),
                        trailing: const Icon(Icons.arrow_forward, color: Colors.white54),
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

// 2. 학생 상세 정보 
class StudentDetailScreen extends StatefulWidget {
  final String studentId;
  const StudentDetailScreen({super.key, required this.studentId});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  
  String _getTeacherMessage(double percent) {
    if (percent >= 100) return "✅ 오답 정리가 완벽합니다. 칭찬해주세요!";
    if (percent >= 80) return "👍 매우 성실한 학생입니다. 조금만 더 지도해주세요.";
    if (percent >= 60) return "👌 잘 따라오고 있습니다. 오답 정리를 독려해주세요.";
    if (percent >= 40) return "⚠️ 오답 정리 습관이 필요합니다. 확인해주세요.";
    if (percent >= 20) return "🚨 오답 정리가 미흡합니다. 상담이 필요할 수 있습니다.";
    return "❌ 오답 정리를 전혀 하지 않았습니다. 지도가 시급합니다.";
  }

  Color _getProgressColor(double percent) {
    if (percent < 50) return Color.lerp(Colors.redAccent, Colors.orangeAccent, percent / 50)!;
    return Color.lerp(Colors.orangeAccent, const Color(0xFF2DD4BF), (percent - 50) / 50)!;
  }

  @override
  Widget build(BuildContext context) {
    return NeuralBackground(
      child: FutureBuilder(
        future: Future.wait([
          context.read<ApiService>().getStudentInfo(widget.studentId),
          context.read<ApiService>().getWeakness(widget.studentId),
          context.read<ApiService>().getStudentNoteStats(widget.studentId),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text("데이터 로드 실패"));

          final data = snapshot.data as List;
          final info = data[0] as Map<String, dynamic>;
          final weak = data[1] as List;
          final stats = data[2] as Map<String, dynamic>;

          final noteCtrl = TextEditingController(text: info['charactoristic'] ?? "");
          final int totalNotes = stats['total'] ?? 0;
          final int doneNotes = stats['done'] ?? 0;
          final double percentage = (stats['percentage'] ?? 0.0).toDouble();

          List<PieChartSectionData> chartSections = [];
          final List<Color> colors = [Colors.redAccent, Colors.blueAccent, Colors.green, Colors.orange, Colors.purple];

          for (int i = 0; i < weak.length; i++) {
            final w = weak[i];
            final val = double.tryParse(w['percentage'].toString()) ?? 0.0;
            if (val > 0) {
              chartSections.add(PieChartSectionData(color: colors[i % colors.length], value: val, title: "${val.toInt()}%", radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)));
            }
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AppBar(backgroundColor: Colors.transparent, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
              
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.account_circle, size: 80, color: Colors.white),
                    const SizedBox(height: 10),
                    Text(info['name'], style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    Text("${info['school']} / ${info['age']}세", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("오답노트 지도 가이드", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Text(_getTeacherMessage(percentage), style: TextStyle(color: _getProgressColor(percentage), fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          Container(height: 20, decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10))),
                          AnimatedContainer(duration: const Duration(milliseconds: 800), height: 20, width: (MediaQuery.of(context).size.width - 80) * (percentage / 100), decoration: BoxDecoration(color: _getProgressColor(percentage), borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: _getProgressColor(percentage).withOpacity(0.5), blurRadius: 10)])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight, child: Text("$doneNotes / $totalNotes 작성 완료 (${percentage.toStringAsFixed(1)}%)", style: const TextStyle(color: Colors.white70, fontSize: 14))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              const Text("취약점 분석 (오답률)", style: TextStyle(color: Color(0xFF2DD4BF), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (chartSections.isEmpty) const SizedBox(height: 100, child: Center(child: Text("분석할 오답 데이터가 없습니다.", style: TextStyle(color: Colors.white30))))
              else SizedBox(height: 200, child: Row(children: [Expanded(child: PieChart(PieChartData(sections: chartSections, centerSpaceRadius: 40, sectionsSpace: 2))), Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: List.generate(weak.length, (i) { final w = weak[i]; if ((double.tryParse(w['percentage'].toString()) ?? 0) <= 0) return const SizedBox.shrink(); return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [Container(width: 12, height: 12, color: colors[i % colors.length]), const SizedBox(width: 5), Text(w['subject'], style: const TextStyle(color: Colors.white70, fontSize: 12))])); }))])),

              const SizedBox(height: 40),
              const Text("특징 메모", style: TextStyle(color: Color(0xFFF472B6), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              NeuralTextField(controller: noteCtrl, label: "메모 입력", icon: Icons.edit),
              const SizedBox(height: 10),
              NeonButton(
                text: "저장",
                onPressed: () async {
                  await context.read<ApiService>().updateStudentNote(widget.studentId, noteCtrl.text);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("저장되었습니다.")));
                  setState(() {}); // 저장 후 화면 갱신
                },
              )
            ],
          );
        },
      ),
    );
  }
}