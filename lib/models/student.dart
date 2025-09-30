class Student {
  final int? id;
  final String studentId;
  final String firstName;
  final String lastName;
  final String program;
  final String activityName;
  final DateTime registrationDate;
  final String userEmail;

  Student({
    this.id,
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.program,
    required this.activityName,
    required this.registrationDate,
    required this.userEmail,
  });

  // แปลงเป็น Map สำหรับบันทึกลงฐานข้อมูล
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'first_name': firstName,
      'last_name': lastName,
      'program': program,
      'activity_name': activityName,
      'registration_date': registrationDate.toIso8601String(),
      'user_email': userEmail,
    };
  }

  // สร้าง Student object จาก Map ที่อ่านจากฐานข้อมูล
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      studentId: map['student_id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      program: map['program'],
      activityName: map['activity_name'],
      registrationDate: DateTime.parse(map['registration_date']),
      userEmail: map['user_email'],
    );
  }

  // คัดลอก Student object พร้อมแก้ไขข้อมูลบางส่วน
  Student copyWith({
    int? id,
    String? studentId,
    String? firstName,
    String? lastName,
    String? program,
    String? activityName,
    DateTime? registrationDate,
    String? userEmail,
  }) {
    return Student(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      program: program ?? this.program,
      activityName: activityName ?? this.activityName,
      registrationDate: registrationDate ?? this.registrationDate,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  // ชื่อเต็ม
  String get fullName => '$firstName $lastName';

  // รูปแบบวันที่แสดงผล
  String get formattedDate {
    return '${registrationDate.day}/${registrationDate.month}/${registrationDate.year} '
        '${registrationDate.hour.toString().padLeft(2, '0')}:${registrationDate.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'Student{id: $id, studentId: $studentId, fullName: $fullName, '
        'program: $program, activityName: $activityName, registrationDate: $registrationDate}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Student &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          studentId == other.studentId &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          program == other.program &&
          activityName == other.activityName &&
          userEmail == other.userEmail;

  @override
  int get hashCode =>
      id.hashCode ^
      studentId.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      program.hashCode ^
      activityName.hashCode ^
      userEmail.hashCode;
}
