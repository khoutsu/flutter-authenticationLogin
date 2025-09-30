import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  bool _loading = false;
  User? _user;

  bool get isLoading => _loading;
  User? get user => _user;
  Stream<User?> get authStateChanges => _auth.authStateChanges;

  AuthProvider() {
    // Listen to auth state changes
    _auth.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<String?> register({
    required String email,
    required String password,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      await _auth.register(email: email, password: password);
      _user = FirebaseAuth.instance.currentUser;
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      await _auth.login(email: email, password: password);
      _user = FirebaseAuth.instance.currentUser;
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    _user = null;
    notifyListeners();
  }

  Future<String?> sendPasswordReset({required String email}) async {
    _loading = true;
    notifyListeners();
    try {
      await _auth.sendPasswordReset(email: email);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
