// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up with email and password
  Future<UserCredential> signUp(
      {required String email, required String password}) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}