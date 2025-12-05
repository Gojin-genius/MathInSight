// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api_service.dart';
import '../neural_ui.dart';

class SignupStudentScreen extends StatefulWidget {
  const SignupStudentScreen({super.key});
  @override
  State<SignupStudentScreen> createState() => _SignupStudentScreenState();
}

class _SignupStudentScreenState extends State<SignupStudentScreen> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  String? _selectedCramSchool;
  List<String> _cramSchools = [];
  bool _isLoadingList = true;

  @override
  void initState() {
    super.initState();
    _loadCramSchools();
  }

  // 서버에서 최신 학원 목록 가져오기
  Future<void> _loadCramSchools() async {
    setState(() => _isLoadingList = true);
    try {
      final list = await context.read<ApiService>().getCramSchoolList();
      setState(() {
        _cramSchools = list;
        _isLoadingList = false;

        if (_selectedCramSchool != null && !_cramSchools.contains(_selectedCramSchool)) {
          _selectedCramSchool = null;
        }
      });
    } catch (e) {
      setState(() => _isLoadingList = false);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("학원 목록을 불러오지 못했습니다.")));
    }
  }

  void _signup() async {
    final api = context.read<ApiService>();
    try {
      if (_selectedCramSchool == null) throw Exception("학원을 선택해주세요");
      await api.signup('student', {
        'id': _idCtrl.text,
        'password': _pwCtrl.text,
        'name': _nameCtrl.text,
        'age': int.tryParse(_ageCtrl.text) ?? 0,
        'school': _schoolCtrl.text,
        'cramschool': _selectedCramSchool,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("가입 성공! 로그인해주세요.")));
      Navigator.pop(context);
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
            // 뒤로가기
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text("Back", style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: [
                  Text("Join Insight", style: GoogleFonts.orbitron(fontSize: 30, color: Colors.white)),
                  const SizedBox(height: 20),
                  NeuralTextField(controller: _idCtrl, label: "ID", icon: Icons.person),
                  NeuralTextField(controller: _pwCtrl, label: "Password", icon: Icons.lock, isObscure: true),
                  NeuralTextField(controller: _nameCtrl, label: "이름", icon: Icons.badge),
                  NeuralTextField(controller: _ageCtrl, label: "나이", icon: Icons.cake, type: TextInputType.number),
                  NeuralTextField(controller: _schoolCtrl, label: "학교", icon: Icons.school),
                  const SizedBox(height: 20),
                  
                  
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Colors.white),
                          value: _selectedCramSchool,
                          decoration: InputDecoration(
                            labelText: "학원 선택",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.3),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            prefixIcon: const Icon(Icons.business, color: Colors.white54),
                          ),
                          items: _cramSchools.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _selectedCramSchool = v),
                          hint: _isLoadingList ? const Text("목록 불러오는 중...", style: TextStyle(color: Colors.white30)) : const Text("학원을 선택하세요"),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Color(0xFF2DD4BF)),
                        onPressed: _loadCramSchools, // 목록 새로고침 버튼 추가
                        tooltip: "목록 새로고침",
                      )
                    ],
                  ),
                  // ------------------------------------

                  const SizedBox(height: 30),
                  NeonButton(text: "SIGN UP", onPressed: _signup),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}