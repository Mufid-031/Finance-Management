class Failure {
  final String message;
  final String? code;

  Failure(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthFailure extends Failure {
  AuthFailure(super.message, {super.code});

  factory AuthFailure.fromFirebase(String code) {
    switch (code) {
      case 'user-not-found':
        return AuthFailure('Email tidak terdaftar.', code: code);
      case 'wrong-password':
        return AuthFailure('Password salah. Silakan coba lagi.', code: code);
      case 'invalid-email':
        return AuthFailure('Format email tidak valid.', code: code);
      case 'network-request-failed':
        return AuthFailure('Tidak ada koneksi internet.', code: code);
      case 'too-many-requests':
        return AuthFailure(
          'Terlalu banyak percobaan. Coba lagi nanti.',
          code: code,
        );
      default:
        return AuthFailure('Terjadi kesalahan autentikasi ($code).');
    }
  }
}
