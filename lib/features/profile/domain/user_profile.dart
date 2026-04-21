class UserProfile {
  final String id;
  final String? displayName;
  final String? photoUrl;
  final String? email;

  UserProfile({
    required this.id,
    this.displayName,
    this.photoUrl,
    this.email,
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? photoUrl,
    String? email,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email ?? this.email,
    );
  }
}
