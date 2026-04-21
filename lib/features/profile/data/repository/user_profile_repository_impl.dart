import 'dart:io';
import 'package:finance_management/features/profile/data/datasource/user_profile_datasource.dart';
import 'package:finance_management/features/profile/data/dto/user_profile_dto.dart';
import 'package:finance_management/features/profile/domain/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile> getUserProfile(String id);
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> updateEmail(String newEmail);
  Future<String> uploadProfileImage(String userId, File file);
}

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileFirestoreDatasource _datasource;

  UserProfileRepositoryImpl(this._datasource);

  @override
  Future<UserProfile> getUserProfile(String id) async {
    final doc = await _datasource.getUserDoc(id);
    if (doc.exists) {
      return UserProfileDTO.fromMap(id, doc.data() as Map<String, dynamic>).toDomain();
    } else {
      final user = _datasource.currentUser;
      return UserProfile(
        id: id,
        displayName: user?.displayName,
        photoUrl: user?.photoURL,
        email: user?.email,
      );
    }
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await _datasource.updateAuthProfile(
      displayName: profile.displayName,
      photoUrl: profile.photoUrl,
    );

    final dto = UserProfileDTO.fromDomain(profile);
    await _datasource.updateFirestoreProfile(profile.id, dto.toMap());
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    final user = _datasource.currentUser;
    if (user != null) {
      await _datasource.verifyBeforeUpdateEmail(newEmail);
      await _datasource.updateFirestoreEmail(user.uid, newEmail);
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, File file) {
    return _datasource.uploadProfileImage(userId, file);
  }
}
