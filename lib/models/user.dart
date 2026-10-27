class User {
  final int id;
  final String username;

  const User({required this.id, required this.username});

  factory User.fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as int,
      username: map['username'] as String,
    );
  }
}
