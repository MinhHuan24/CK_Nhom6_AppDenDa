class ApiEndpoints {
  // Đổi thành 'http://10.0.2.2:5019/api' nếu test bằng máy ảo Android Emulator
  //web 'http://localhost:5019/api'
  static const String baseUrl = 'http://10.0.2.2:5019/api'; 
  
  static const String login = '$baseUrl/Auth/login';
  static const String register = '$baseUrl/Auth/register';
  static const forgotPassword =
    '$baseUrl/Auth/forgot-password';

  static const verifyOtp =
      '$baseUrl/Auth/verify-otp';

  static const resetPassword =
      '$baseUrl/Auth/reset-password';

  static const String createReview =
      '$baseUrl/Review';

  static const String getReviews =
      '$baseUrl/Review';

  static String checkReview(
    int productId,
    int orderId,
  ) =>
      '$baseUrl/Review/check?productId=$productId&orderId=$orderId';
}