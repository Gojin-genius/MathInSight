// lib/screens/cramschool/cram_home.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models.dart';
import '../../neural_ui.dart';
import '../login_screen.dart';
import 'cram_exam.dart';
import 'cram_info.dart';
import 'cram_qna.dart';

class CramSchoolHomeScreen extends StatelessWidget {
  const CramSchoolHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cram = context.watch<UserProvider>().cramSchool!;
    return NeuralBackground(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Teacher Mode", style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(cram.cramschool, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: () {
                    context.read<UserProvider>().logout();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _MenuCard(
                    title: "CREATE\nEXAM",
                    icon: Icons.edit_note,
                    color: const Color(0xFFF472B6), // Pink
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateExamScreen())),
                  ),
                  _MenuCard(
                    title: "STUDENT\nINFO",
                    icon: Icons.people_alt,
                    color: const Color(0xFF2DD4BF), // Teal
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentInfoListScreen())),
                  ),
                  _MenuCard(
                    title: "Q & A\nROOMS",
                    icon: Icons.chat_bubble_outline,
                    color: const Color(0xFFA78BFA), // Purple
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatRoomListScreen())),
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
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}