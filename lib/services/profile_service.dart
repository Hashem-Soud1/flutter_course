import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> updateDisplayName(String name) async {
    await currentUser?.updateDisplayName(name);
    await currentUser?.reload();
  }

  Future<void> updateEmail(String email) async {
    await currentUser?.verifyBeforeUpdateEmail(email);
  }

  Future<void> updatePassword(String password) async {
    await currentUser?.updatePassword(password);
  }
}
