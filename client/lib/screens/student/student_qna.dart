// lib/screens/student/student_qna.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api_service.dart';
import '../../models.dart';
import '../../neural_ui.dart';

class StudentQnAScreen extends StatefulWidget {
  const StudentQnAScreen({super.key});
  @override
  State<StudentQnAScreen> createState() => _StudentQnAScreenState();
}

class _StudentQnAScreenState extends State<StudentQnAScreen> {
  final _ctrl = TextEditingController();
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final s = context.read<UserProvider>().student!;
    final msgs = await context.read<ApiService>().getMessages(s.cramschool, s.id);
    setState(() => _messages = msgs);
  }

  void _send() async {
    if (_ctrl.text.isEmpty) return;
    final s = context.read<UserProvider>().student!;
    await context.read<ApiService>().sendMessage({
      'cramschool': s.cramschool,
      'studentId': s.id,
      'senderName': s.name,
      'message': _ctrl.text,
      'userType': 'student',
    });
    _ctrl.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return NeuralBackground(
      child: Column(
        children: [
          AppBar(backgroundColor: Colors.transparent, title: const Text("Q&A Chat")),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isMe = m.senderName != context.read<UserProvider>().student!.cramschool;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF2DD4BF).withOpacity(0.8) : Colors.white12,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(m.message, style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(child: NeuralTextField(controller: _ctrl, label: "메시지", icon: Icons.send)),
                IconButton(icon: const Icon(Icons.send, color: Color(0xFF2DD4BF)), onPressed: _send),
              ],
            ),
          )
        ],
      ),
    );
  }
}