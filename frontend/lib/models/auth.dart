class LoginResponse {
  final User? user;
  final String? accessToken;
  final String? refreshToken;

  LoginResponse({required this.user, required this.accessToken, required this.refreshToken});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Bắt cả 2 kiểu key: snake_case và camelCase
    final accessToken = json['access_token'] ?? json['accessToken'];
    final refreshToken = json['refresh_token'] ?? json['refreshToken'];
    final userData = json['user'];

    // De
    //bug log
    print(' LoginResponse.fromJson(): $json');

    if (accessToken == null || refreshToken == null) {
      print(' Missing token(s) in response!');
    }

    return LoginResponse(
      user: userData != null ? User.fromJson(userData) : null,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
class User {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? role;

  User({required this.id, required this.fullName, required this.email, this.phoneNumber, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      fullName: json['full_name'] ?? json['fullName'],
      email: json['email'],
      phoneNumber: json['phone_number'] ?? json['phoneNumber'],
      role: json['role'],
    );
  }
}

class RegisterRequest {
  final String fullName;
  final String email;
  final String password;
  final String? phoneNumber;
  final String role;

  RegisterRequest({required this.fullName, required this.email, required this.password, this.phoneNumber, this.role = 'user'});

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'email': email,
    'password': password,
    'phone_number': phoneNumber,
    'role': role,
  };
}