class ReviewModel {
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReviewModel(
      userName: json['userName'] ?? 'Ẩn danh',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'],
      ),
    );
  }
}