import 'package:firebase_auth/firebase_auth.dart' as fb;

class FirebaseAuthDatasource {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Future<fb.UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<fb.UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  fb.User? getCurrentUser() {
    return _auth.currentUser;
  }
}
