import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:http/http.dart' as http;

class UserProfileFirestoreDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  // BOSS, Masukkan detail Cloudinary di sini nanti
  // Caranya: Register Cloudinary -> Dashboard -> Cloud Name
  // Settings -> Upload -> Upload Presets -> Add Unsigned Upload Preset
  static const String _cloudName = "dvwntkadz"; 
  static const String _uploadPreset = "uw_preset_123";

  fb.User? get currentUser => _auth.currentUser;

  Future<DocumentSnapshot> getUserDoc(String id) {
    return _firestore.collection('users').doc(id).get();
  }

  Future<void> updateFirestoreProfile(String id, Map<String, dynamic> data) {
    return _firestore.collection('users').doc(id).set(
      data,
      SetOptions(merge: true),
    );
  }

  Future<void> updateAuthProfile({String? displayName, String? photoUrl}) async {
    final user = _auth.currentUser;
    if (user != null) {
      if (displayName != null) await user.updateDisplayName(displayName);
      if (photoUrl != null) await user.updatePhotoURL(photoUrl);
    }
  }

  Future<void> verifyBeforeUpdateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.verifyBeforeUpdateEmail(newEmail);
    }
  }

  Future<void> updateFirestoreEmail(String id, String newEmail) {
    return _firestore.collection('users').doc(id).update({
      'email': newEmail,
    });
  }

  /// Mengunggah file ke Cloudinary (GRATIS & No Credit Card)
  Future<String> uploadProfileImage(String userId, File file) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$_cloudName/image/upload");
    
    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['public_id'] = "user_profile_$userId" // Agar menimpa foto lama
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);
    final jsonResponse = jsonDecode(responseString);

    if (response.statusCode == 200) {
      return jsonResponse['secure_url']; // URL Gambar yang sudah di-upload
    } else {
      throw Exception("Gagal upload ke Cloudinary: ${jsonResponse['error']['message']}");
    }
  }
}
