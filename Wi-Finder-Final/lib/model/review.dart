import 'package:cloud_firestore/cloud_firestore.dart';

///Review Attributes
class Review {
  String id;
  String username;
  String name;
  double rating;
  String review;
  Timestamp createdAt;
  Timestamp updatedAt;

  Review();

  Review.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    username = data['username'];
    name = data['name'];
    rating = data['rating'];
    review = data['review'];
    createdAt = data['createdAt'];
    updatedAt = data['updatedAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'review': review,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'username': username
    };
  }
}
