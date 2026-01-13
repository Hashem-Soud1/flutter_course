import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isAdmin = false;
  bool _isLoading = true;

  User? get user => _user;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _user = _authService.currentUser;
    if (_user != null) {
      await _checkAdminStatus();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _checkAdminStatus() async {
    if (_user == null) return;
    try {
      final userData = await _authService.getUserData(_user!.uid);
      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>;
        _isAdmin = data['role'] == 'admin';
      } else {
        _isAdmin = false;
      }
    } catch (e) {
      _isAdmin = false;
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final credential = await _authService.signIn(
        email: email,
        password: password,
      );
      _user = credential.user;
      if (_user != null) {
        await _authService.ensureUserDocumentExists(_user!);
        await _checkAdminStatus();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      final credential = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );
      _user = credential.user;
      _isAdmin = false; // Default for new signups
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    _isAdmin = false;
    notifyListeners();
  }
}
