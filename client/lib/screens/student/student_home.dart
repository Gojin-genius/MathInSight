// lib/screens/student/student_home.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models.dart';
import '../../neural_ui.dart';
import '../login_screen.dart';
import 'student_exam.dart';
import 'student_wrong_note.dart';
import 'student_qna.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = context.watch<UserProvider>().student!;
    return NeuralBackground(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Hi, ${student.name}", style: GoogleFonts.orbitron(fontSize: 28, color: Colors.white)),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: () {
                    context.read<UserProvider>().logout();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                ),
              ],
            ),
            Text("Let's grow your insight.", style: TextStyle(color: Colors.white.withOpacity(0.6))),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _MenuCard(
                    title: "EXAM",
                    icon: Icons.edit_document,
                    color: const Color(0xFF2DD4BF),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamListScreen())),
                  ),
                  _MenuCard(
                    title: "WRONG\nNOTES",
                    icon: Icons.bookmark_border,
                    color: const Color(0xFFF472B6),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WrongNoteListScreen())),
                  ),
                  _MenuCard(
                    title: "Q & A",
                    icon: Icons.chat_bubble_outline,
                    color: const Color(0xFFA78BFA),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentQnAScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MenuCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 15),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}