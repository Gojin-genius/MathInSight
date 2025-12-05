// lib/screens/cramschool/cram_qna.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api_service.dart';
import '../../models.dart';
import '../../neural_ui.dart';

// 1. 채팅방 목록
class ChatRoomListScreen extends StatelessWidget {
  const ChatRoomListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cram = context.read<UserProvider>().cramSchool!;
    return NeuralBackground(
      child: Column(
        children: [
          AppBar(backgroundColor: Colors.transparent, title: const Text("Q&A Rooms")),
          Expanded(
            child: FutureBuilder(
              future: context.read<ApiService>().getChatRooms(cram.cramschool),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final list = snapshot.data as List;
                if (list.isEmpty) return const Center(child: Text("대화방이 없습니다.", style: TextStyle(color: Colors.white54)));
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final room = list[index];
                    final unread = room['unreadCount'] > 0;
                    return GlassCard(
                      onTap: () async {
                        await context.read<ApiService>().markAsRead(cram.cramschool, room['studentId']);
                        if (!context.mounted) return;
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CramChatScreen(studentId: room['studentId'], studentName: room['studentName'])));
                      },
                      child: ListTile(
                        title: Text(room['studentName'], style: const TextStyle(color: Colors.white)),
                        trailing: unread
                            ? Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: Text(room['unreadCount'].toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
                            : null,
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

// 2. 채팅 화면
class CramChatScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  const CramChatScreen({super.key, required this.studentId, required this.studentName});
  @override
  State<CramChatScreen> createState() => _CramChatScreenState();
}

class _CramChatScreenState extends State<CramChatScreen> {
  final _ctrl = TextEditingController();
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final cram = context.read<UserProvider>().cramSchool!;
    final msgs = await context.read<ApiService>().getMessages(cram.cramschool, widget.studentId);
    setState(() => _messages = msgs);
  }

  void _send() async {
    if (_ctrl.text.isEmpty) return;
    final cram = context.read<UserProvider>().cramSchool!;
    await context.read<ApiService>().sendMessage({
      'cramschool': cram.cramschool,
      'studentId': widget.studentId,
      'senderName': cram.cramschool,
      'message': _ctrl.text,
      'userType': 'cramschool',
    });
    _ctrl.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return NeuralBackground(
      child: Column(
        children: [
          AppBar(backgroundColor: Colors.transparent, title: Text("${widget.studentName} 학생")),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isMe = m.senderName == context.read<UserProvider>().cramSchool!.cramschool;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFA78BFA) : Colors.white12,
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
                IconButton(icon: const Icon(Icons.send, color: Color(0xFFA78BFA)), onPressed: _send),
              ],
            ),
          )
        ],
      ),
    );
  }
}