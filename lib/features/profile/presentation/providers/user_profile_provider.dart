import 'dart:io';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/profile/application/user_profile_service.dart';
import 'package:finance_management/features/profile/data/datasource/user_profile_datasource.dart';
import 'package:finance_management/features/profile/data/repository/user_profile_repository_impl.dart';
import 'package:finance_management/features/profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// Providers for profile
final userProfileDatasourceProvider = Provider<UserProfileFirestoreDatasource>((ref) {
  return UserProfileFirestoreDatasource();
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final datasource = ref.watch(userProfileDatasourceProvider);
  return UserProfileRepositoryImpl(datasource);
});

final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService(ref.watch(userProfileRepositoryProvider));
});

// State for Profile
class UserProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? errorMessage;

  UserProfileState({this.profile, this.isLoading = false, this.errorMessage});

  UserProfileState copyWith({UserProfile? profile, bool? isLoading, String? errorMessage}) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final UserProfileService _service;
  final Ref _ref;
  final ImagePicker _picker = ImagePicker();

  UserProfileNotifier(this._service, this._ref) : super(UserProfileState()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final profile = await _service.getUserProfile(user.uid);
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (state.profile == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final updatedProfile = state.profile!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      await _service.updateUserProfile(updatedProfile);
      state = state.copyWith(profile: updatedProfile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateEmail(String newEmail) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.updateEmail(newEmail);
      if (state.profile != null) {
        state = state.copyWith(
          profile: state.profile!.copyWith(email: newEmail),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Memilih gambar dari galeri dan mengunggahnya
  Future<void> pickAndUploadImage() async {
    if (state.profile == null) return;

    // BOSS, Untuk Galeri, image_picker sebenarnya sudah menghandle permission dasar.
    // Tapi di Android 13+ kita butuh request eksplisit READ_MEDIA_IMAGES.
    
    bool isPermissionGranted = false;

    if (Platform.isAndroid) {
      // Cek apakah Android 13 atau lebih baru
      // Secara teknis image_picker >= 1.0.0 tidak butuh permission_handler jika cuma ambil gambar
      // Tapi kita pastikan saja demi BOSS
      if (await Permission.photos.request().isGranted || await Permission.storage.request().isGranted) {
        isPermissionGranted = true;
      }
    } else {
      isPermissionGranted = true; // iOS ditangani otomatis saat picker dibuka
    }

    // Jika di Android permission masih 'denied' padahal BOSS sudah setuju di sistem,
    // Kita coba buka picker saja langsung karena plugin image_picker punya fallback.
    
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        state = state.copyWith(isLoading: true);
        
        final imageUrl = await _service.uploadProfileImage(
          state.profile!.id,
          File(image.path),
        );

        await updateProfile(photoUrl: imageUrl);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Picker Error: $e");
    }
  }
}

final userProfileNotifierProvider = StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  return UserProfileNotifier(ref.watch(userProfileServiceProvider), ref);
});
