import 'dart:collection';
import 'package:WiFinder/model/review.dart';
import 'package:flutter/cupertino.dart';

///2nd Tier Database layer for reviews & ratings
class ReviewNotifier with ChangeNotifier {
  List<Review> _reviewList = [];
  Review _currentReview;

  UnmodifiableListView<Review> get reviewList => UnmodifiableListView(_reviewList);

  Review get currentReview => _currentReview;

  set reviewList(List<Review> reviewList) {
    _reviewList = reviewList;
    notifyListeners();
  }

  set currentReview(Review review) {
    _currentReview = review;
    notifyListeners();
  }

  double averageRating(String wifiName){
    double averageRating = 0;
    int noOfItems = 0;
    for (Review r in _reviewList){
      if(r.name == wifiName){
        averageRating += r.rating;
        noOfItems++;
      }
    }
    if (averageRating == 0) return 0.0;
    else return (averageRating/noOfItems);
  }

  addReview(Review review) {
    _reviewList.insert(0, review);
    notifyListeners();
  }

  deleteReview(Review review) {
    _reviewList.removeWhere((_review) => _review.id == review.id);
    notifyListeners();
  }
}
