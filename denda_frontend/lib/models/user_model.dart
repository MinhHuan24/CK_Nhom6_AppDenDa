class LoginResponse {
  final String token;
  final String message;

  LoginResponse({required this.token, required this.message});

  // Hàm chuyển đổi từ dữ liệu JSON của Backend thành Object trong Dart
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      message: json['message'] ?? '',
    );
  }
}