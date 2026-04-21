import 'dart:io';
import 'package:finance_management/features/profile/data/repository/user_profile_repository_impl.dart';
import 'package:finance_management/features/profile/domain/user_profile.dart';

class UserProfileService {
  final UserProfileRepository _repository;

  UserProfileService(this._repository);

  Future<UserProfile> getUserProfile(String id) => _repository.getUserProfile(id);
  Future<void> updateUserProfile(UserProfile profile) => _repository.updateUserProfile(profile);
  Future<void> updateEmail(String email) => _repository.updateEmail(email);
  Future<String> uploadProfileImage(String userId, File file) => _repository.uploadProfileImage(userId, file);
}
