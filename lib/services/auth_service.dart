import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up using email and password
  Future<UserCredential?> signUpWithEmailPassword(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(name);
      
      // Save info locally (optional, for caching)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', name);
      await prefs.setString('userEmail', email);
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in using email and password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save info locally
      final prefs = await SharedPreferences.getInstance();
      if (userCredential.user?.displayName != null) {
        await prefs.setString('userName', userCredential.user!.displayName!);
      }
      await prefs.setString('userEmail', email);

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is currently logged in
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userEmail');
  }
}
