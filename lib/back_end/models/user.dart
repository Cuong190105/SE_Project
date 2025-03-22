class User {
  int? userID;
  String email;
  String passwordHash;
  String? fullName;
  String role;

  User({this.userID, required this.email, required this.passwordHash, this.fullName, this.role = "user"});

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'email': email,
      'fullName': fullName,
      'role': role,
    };
  }
}
