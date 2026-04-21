import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/features/profile/domain/user_profile.dart';

class UserProfileDTO {
  final String id;
  final String? displayName;
  final String? photoUrl;
  final String? email;

  UserProfileDTO({
    required this.id,
    this.displayName,
    this.photoUrl,
    this.email,
  });

  factory UserProfileDTO.fromMap(String id, Map<String, dynamic> map) {
    return UserProfileDTO(
      id: id,
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'photoUrl': photoUrl,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserProfile toDomain() {
    return UserProfile(
      id: id,
      displayName: displayName,
      photoUrl: photoUrl,
      email: email,
    );
  }

  factory UserProfileDTO.fromDomain(UserProfile domain) {
    return UserProfileDTO(
      id: domain.id,
      displayName: domain.displayName,
      photoUrl: domain.photoUrl,
      email: domain.email,
    );
  }
}
