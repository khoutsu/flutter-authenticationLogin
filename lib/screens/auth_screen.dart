import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/gardiant_bg.dart';
import '../widgets/primary_button.dart';
import 'reset_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showSnack(BuildContext context, String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red.shade600 : Colors.green.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final email = _email.text.trim();
    final pass = _password.text.trim();

    String? err;
    if (_isLogin) {
      err = await auth.login(email: email, password: pass);
    } else {
      err = await auth.register(email: email, password: pass);
    }

    // ป้องกันเรียก context หลังถูก dispose: เช็ค mounted ก่อนทุกครั้งหลัง await
    if (!mounted) return;

    if (err == null) {
      _showSnack(context, _isLogin ? 'เข้าสู่ระบบสำเร็จ' : 'สมัครสมาชิกสำเร็จ');
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _isLogin ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก',
                        key: ValueKey(_isLogin),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'อีเมล',
                            ),
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
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _password,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'รหัสผ่าน',
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'กรุณากรอกรหัสผ่าน';
                              }
                              if (v.length < 6) {
                                return 'รหัสผ่านอย่างน้อย 6 ตัวอักษร';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            label: _isLogin ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก',
                            loading: loading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              setState(() => _isLogin = !_isLogin);
                            },
                            child: Text(
                              _isLogin
                                  ? 'ยังไม่มีบัญชี? สมัครสมาชิก'
                                  : 'มีบัญชีแล้ว? เข้าสู่ระบบ',
                            ),
                          ),
                          if (_isLogin) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ResetPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text('ลืมรหัสผ่าน? เปลี่ยนรหัสผ่าน'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
