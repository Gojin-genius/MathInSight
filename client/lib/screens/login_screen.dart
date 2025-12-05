// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api_service.dart';
import '../models.dart';
import '../neural_ui.dart';
import 'signup_screen.dart'; 
import 'signup_cramschool_screen.dart';
import 'student/student_home.dart';
import 'cramschool/cram_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _isStudent = true; // true면 학생, false면 학원
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    final api = context.read<ApiService>();
    try {
      final type = _isStudent ? 'student' : 'cramschool';
      final result = await api.login(type, _idCtrl.text, _pwCtrl.text);

      if (!mounted) return;
      if (_isStudent) {
        context.read<UserProvider>().setStudent(Student.fromJson(result['student']));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentHomeScreen()));
      } else {
        context.read<UserProvider>().setCramSchool(CramSchool.fromJson(result['cramschool']));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CramSchoolHomeScreen()));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goSignup() {
    if (_isStudent) {
      // 학생이 선택된 상태면 학생 가입 화면으로
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupStudentScreen()));
    } else {
      // 학원이 선택된 상태면 학원 가입 화면으로
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupCramSchoolScreen()));
    }
  }
  // -----------------------

  @override
  Widget build(BuildContext context) {
    return NeuralBackground(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Math Insight", style: GoogleFonts.orbitron(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white))
                .animate().fadeIn().scale(),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("학생"), 
                  selected: _isStudent, 
                  onSelected: (v) => setState(() => _isStudent = true)
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("학원"), 
                  selected: !_isStudent, 
                  onSelected: (v) => setState(() => _isStudent = false)
                ),
              ],
            ),
            const SizedBox(height: 20),
            NeuralTextField(controller: _idCtrl, label: "ID", icon: Icons.person),
            NeuralTextField(controller: _pwCtrl, label: "Password", icon: Icons.lock, isObscure: true),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : NeonButton(
                    text: "LOGIN", 
                    onPressed: _login, 
                    color: _isStudent ? const Color(0xFF2DD4BF) : const Color(0xFFF472B6)
                  ),
            TextButton(
              onPressed: _goSignup, 
              child: Text(
                _isStudent ? "학생 계정이 없으신가요? 회원가입" : "학원 파트너 등록하기", 
                style: const TextStyle(color: Colors.white70)
              ),
            ),
          ],
        ),
      ),
    );
  }
}