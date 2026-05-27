import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../models/review_model.dart';

class ReviewService {
  // ==========================
  // CREATE REVIEW
  // ==========================
  Future<bool> createReview({
    required String token,
    required int productId,
    required int orderId,
    required int rating,
    required String comment,
  }) async {
    try {
      final url =
          ApiEndpoints.createReview;

      debugPrint(
          '========= REVIEW =========');

      debugPrint('URL: $url');

      debugPrint(
          'TOKEN: $token');

      debugPrint(jsonEncode({
        'productId': productId,
        'orderId': orderId,
        'rating': rating,
        'comment': comment,
      }));

      final response =
          await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type':
              'application/json',
          'Authorization':
              'Bearer $token',
        },
        body: jsonEncode({
          'productId': productId,
          'orderId': orderId,
          'rating': rating,
          'comment': comment,
        }),
      );

      debugPrint(
          'STATUS: ${response.statusCode}');
      debugPrint(
          'BODY: ${response.body}');

      return response.statusCode ==
          200;
    } catch (e) {
      debugPrint(
          'REVIEW ERROR: $e');
      return false;
    }
  }

  // ==========================
  // GET REVIEWS BY PRODUCT
  // ==========================
  Future<List<ReviewModel>>
      getReviewsByProduct(
    String productId,
  ) async {
    try {
      final url =
          '${ApiEndpoints.getReviews}/$productId';

      debugPrint(
          'GET REVIEW URL: $url');

      final response =
          await http.get(
        Uri.parse(url),
      );

      debugPrint(
          'GET REVIEW STATUS: ${response.statusCode}');
      debugPrint(
          'GET REVIEW BODY: ${response.body}');

      if (response.statusCode ==
          200) {
        final List<dynamic>
            jsonData = jsonDecode(
          response.body,
        );

        return jsonData
            .map(
              (e) =>
                  ReviewModel
                      .fromJson(e),
            )
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint(
          'GET REVIEW ERROR: $e');

      return [];
    }
  }

  Future<bool> hasReviewed({
    required String token,
    required int productId,
    required int orderId,
  }) async {
    try {
      final response =
          await http.get(
        Uri.parse(
          ApiEndpoints
              .checkReview(
            productId,
            orderId,
          ),
        ),
        headers: {
          'Authorization':
              'Bearer $token',
        },
      );

      if (response.statusCode ==
          200) {
        final data =
            jsonDecode(
                response.body);

        return data[
                'isReviewed'] ??
            false;
      }

      return false;
    } catch (e) {
      debugPrint(
        'CHECK REVIEW ERROR: $e',
      );
      return false;
    }
  }
}