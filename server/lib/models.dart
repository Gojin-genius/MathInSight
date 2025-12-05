// lib/models.dart

// 학생 class
class Student {
  final String id;
  final String password;
  final String name;
  final int age;
  final String school;
  final String cramschool;

  Student({
    required this.id,
    required this.password,
    required this.name,
    required this.age,
    required this.school,
    required this.cramschool,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'school': school,
    'cramschool': cramschool,
  };
}

// 학원 class
class CramSchool {
  final String id;
  final String password;
  final String cramschool;

  CramSchool({
    required this.id,
    required this.password,
    required this.cramschool,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'cramschool': cramschool,
  };
}