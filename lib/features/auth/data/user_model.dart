class UserModel {
  final int id;
  final String name;
  final String username;
  final String nik;
  final String? npwp;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.nik,
    this.npwp,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      nik: json['nik'] as String? ?? '',
      npwp: json['npwp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'nik': nik,
      'npwp': npwp,
    };
  }
}

class LoginResponse {
  final String token;
  final UserModel user;

  LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
