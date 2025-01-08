class UserModel {
  final String id;
  final String email;
  final String username;
  final String profileImageUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'profileImageUrl': profileImageUrl,
    };
  }
}
