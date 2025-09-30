import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/gardiant_bg.dart';
import '../widgets/primary_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _showSnack(BuildContext context, String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _email.text.trim();
    final auth = context.read<AuthProvider>();
    final err = await auth.sendPasswordReset(email: email);
    if (!mounted) return; // กัน context หลัง dispose
    if (err == null) {
      _showSnack(context, 'ส่งลิงก์รีเซ็ตรหัสผ่านไปที่อีเมลแล้ว');
      Navigator.of(context).pop();
    } else {
      _showSnack(context, err, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    return GradientBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('ลืมรหัสผ่าน')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'กรอกอีเมลที่ใช้สมัคร เพื่อรับลิงก์เปลี่ยนรหัสผ่าน',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(labelText: 'อีเมล'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'กรุณากรอกอีเมล';
                          }
                          final ok = RegExp(
                            r'^[^@]+@[^@]+\.[^@]+',
                          ).hasMatch(v.trim());
                          if (!ok) return 'รูปแบบอีเมลไม่ถูกต้อง';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'ส่งลิงก์รีเซ็ต',
                        onPressed: _submit,
                        loading: loading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
