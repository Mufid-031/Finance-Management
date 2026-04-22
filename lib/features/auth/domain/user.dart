class User {
  final String id;
  final String email;
  final bool isNewUser;

  User({
    required this.id,
    required this.email,
    this.isNewUser = false,
  });
}
