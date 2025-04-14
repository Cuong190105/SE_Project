class User {
  int? id;
  String name;
  String email;
  String password;
  bool isSynced;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.isSynced = false,
  });

  // Convert User to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // Create User from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      isSynced: map['is_synced'] == 1,
    );
  }
}
