import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../database/database_helper.dart';
import '../providers/auth_provider.dart';
import '../widgets/gardiant_bg.dart';
import '../widgets/primary_button.dart';

class ActivityRegistrationScreen extends StatefulWidget {
  const ActivityRegistrationScreen({super.key});

  @override
  State<ActivityRegistrationScreen> createState() =>
      _ActivityRegistrationScreenState();
}

class _ActivityRegistrationScreenState
    extends State<ActivityRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _activityNameController = TextEditingController();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;

  // รายการหลักสูตรสำหรับเลือก
  final List<String> _programs = [
    'วิทยาการคอมพิวเตอร์',
    'เทคโนโลยีสารสนเทศ',
    'วิศวกรรมคอมพิวเตอร์',
    'วิศวกรรมซอฟต์แวร์',
    'ระบบสารสนเทศ',
    'การจัดการเทคโนโลยีสารสนเทศ',
  ];

  String? _selectedProgram;

  @override
  void dispose() {
    _studentIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _activityNameController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _registerStudent() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final userEmail = authProvider.user?.email;

    if (userEmail == null) {
      _showSnackBar('กรุณาเข้าสู่ระบบก่อน', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ตรวจสอบว่านักศึกษาลงทะเบียนกิจกรรมนี้แล้วหรือไม่
      final isRegistered = await _dbHelper.isStudentRegistered(
        _studentIdController.text.trim(),
        _activityNameController.text.trim(),
        userEmail,
      );

      if (isRegistered) {
        _showSnackBar('นักศึกษาคนนี้ลงทะเบียนกิจกรรมนี้แล้ว', isError: true);
        return;
      }

      // สร้าง Student object
      final student = Student(
        studentId: _studentIdController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        program: _selectedProgram!,
        activityName: _activityNameController.text.trim(),
        registrationDate: DateTime.now(),
        userEmail: userEmail,
      );

      // บันทึกลงฐานข้อมูล
      await _dbHelper.insertStudent(student);
      _showSnackBar('ลงทะเบียนสำเร็จ!');
      _clearForm();

      // กลับไปหน้าก่อนหน้าพร้อมส่งผลลัพธ์
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _studentIdController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _activityNameController.clear();
    setState(() => _selectedProgram = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ลงทะเบียนเข้าร่วมกิจกรรม'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: GradientBg(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Header Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.purple.shade50],
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 50,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ลงทะเบียนเข้าร่วมกิจกรรม',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'กรอกข้อมูลนักศึกษาและกิจกรรมที่ต้องการเข้าร่วม',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Form Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // รหัสนักศึกษา
                          TextFormField(
                            controller: _studentIdController,
                            decoration: InputDecoration(
                              labelText: 'รหัสนักศึกษา',
                              prefixIcon: const Icon(Icons.badge),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'กรุณากรอกรหัสนักศึกษา';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // ชื่อ
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'ชื่อ',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'กรุณากรอกชื่อ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // นามสกุล
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'นามสกุล',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'กรุณากรอกนามสกุล';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // หลักสูตร
                          DropdownButtonFormField<String>(
                            value: _selectedProgram,
                            decoration: InputDecoration(
                              labelText: 'หลักสูตร',
                              prefixIcon: const Icon(Icons.school),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            items: _programs.map((String program) {
                              return DropdownMenuItem<String>(
                                value: program,
                                child: Text(program),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() => _selectedProgram = newValue);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณาเลือกหลักสูตร';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // ชื่อกิจกรรม
                          TextFormField(
                            controller: _activityNameController,
                            decoration: InputDecoration(
                              labelText: 'ชื่อกิจกรรม',
                              prefixIcon: const Icon(Icons.event),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'กรุณากรอกชื่อกิจกรรม';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // ปุ่มลงทะเบียน
                          PrimaryButton(
                            label: _isLoading ? 'กำลังบันทึก...' : 'ลงทะเบียน',
                            loading: _isLoading,
                            onPressed: () => _registerStudent(),
                          ),

                          const SizedBox(height: 12),

                          // ปุ่มเคลียร์ฟอร์ม
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _clearForm,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('เคลียร์ฟอร์ม'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
