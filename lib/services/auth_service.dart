import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Current User
  User? get currentUser => _auth.currentUser;

  // 🔹 Register
  Future<User?> register(String email, String password) async {
    try {
      var result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Register Error: $e");
      return null;
    }
  }

  // 🔹 Login
  Future<User?> login(String email, String password) async {
    try {
      var result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // 🔹 Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 🔐 ADMIN CHECK (NEW 🔥)
  Future<bool> isAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('admins')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return doc['role'] == 'admin';
      }

      return false;
    } catch (e) {
      print("Admin Check Error: $e");
      return false;
    }
  }
}