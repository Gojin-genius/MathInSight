// lib/screens/signup_cramschool_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api_service.dart';
import '../neural_ui.dart';

class SignupCramSchoolScreen extends StatefulWidget {
  const SignupCramSchoolScreen({super.key});
  @override
  State<SignupCramSchoolScreen> createState() => _SignupCramSchoolScreenState();
}

class _SignupCramSchoolScreenState extends State<SignupCramSchoolScreen> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(); // 학원 이름

  void _signup() async {
    final api = context.read<ApiService>();
    try {
      if (_idCtrl.text.isEmpty || _pwCtrl.text.isEmpty || _nameCtrl.text.isEmpty) {
        throw Exception("모든 정보를 입력해주세요.");
      }

      await api.signup('cramschool', {
        'id': _idCtrl.text,
        'password': _pwCtrl.text,
        'cramschool': _nameCtrl.text, 
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("학원 등록 성공! 로그인해주세요.")));
      Navigator.pop(context); // 회원가입 후 로그인 화면으로 돌아가기
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeuralBackground(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- 상단 뒤로가기 버튼 ---
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text("Back", style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: ListView(
                children: [
                  Text("Partner with Insight", style: GoogleFonts.orbitron(fontSize: 26, color: Colors.white)),
                  const SizedBox(height: 10),
                  const Text("학원 관리자 계정을 생성합니다.", style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 30),
                  
                  NeuralTextField(controller: _idCtrl, label: "관리자 ID", icon: Icons.person),
                  NeuralTextField(controller: _pwCtrl, label: "비밀번호", icon: Icons.lock, isObscure: true),
                  NeuralTextField(controller: _nameCtrl, label: "학원 이름 (표시용)", icon: Icons.business),
                  
                  const SizedBox(height: 40),
                  NeonButton(
                    text: "학원 등록하기", 
                    onPressed: _signup, 
                    color: const Color(0xFFF472B6) // 학원 테마 색상 (분홍)
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