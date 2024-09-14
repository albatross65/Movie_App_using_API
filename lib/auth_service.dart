import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign-In with Email/Password
  // Sign-In with Email/Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors here
      switch (e.code) {
        case 'user-not-found':
          print("No user found for that email.");
          break;
        case 'wrong-password':
          print("Wrong password provided.");
          break;
        default:
          print("Error signing in: $e");
      }
      return null;
    } catch (e) {
      // General error
      print("General error signing in with email: $e");
      return null;
    }
  }


  // Register with Email/Password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Error registering with email: $e");
      return null;
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent to $email");
    } catch (e) {
      print("Error sending password reset email: $e");
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
