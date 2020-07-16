import 'package:WiFinder/model/favourite.dart';
import 'package:WiFinder/model/review.dart';
import 'package:WiFinder/model/user.dart';
import 'package:WiFinder/notifier/auth_notifier.dart';
import 'package:WiFinder/notifier/favourite_notifier.dart';
import 'package:WiFinder/notifier/review_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

///User login ; will only be granted after user verify their email address.
login(User user, AuthNotifier authNotifier) async {
  AuthResult authResult = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: user.email, password: user.password)
      .catchError((error) => print(error.code));

  FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();

  if (authResult != null) {
    FirebaseUser firebaseUser = authResult.user;

    if (firebaseUser != null) {
      if(currentUser.isEmailVerified){
        print("Log In: $firebaseUser");
        authNotifier.setUser(firebaseUser);
      }
      else{
        print("notify user to verify account");
      }
      }

    }
  }

///Forget Password; Allow user to reset their password with the link send to their email address.
Future sendPasswordResetEmail(User user) async {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: user.email).catchError((error) => print(error.code));
  }

///To create a new account with a valid email address.
signup(User user, AuthNotifier authNotifier) async {
  AuthResult authResult = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: user.email, password: user.password)
      .catchError((error) => print(error.code));

  if (authResult != null) {
    UserUpdateInfo updateInfo = UserUpdateInfo();
    updateInfo.displayName = user.username;

    FirebaseUser firebaseUser = authResult.user;

    if (firebaseUser != null) {
      await firebaseUser.updateProfile(updateInfo);

      await firebaseUser.reload();

      print("Sign up: $firebaseUser");

      FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();

      try {
        currentUser.sendEmailVerification();
      } catch (e) {
        print("An error occured while trying to send email verification");
        print(e.message);
      }
      if(currentUser.isEmailVerified){

      }
    }
  }
}

/// User Log Out.
signout(AuthNotifier authNotifier) async {
  await FirebaseAuth.instance.signOut().catchError((error) => print(error.code));
  authNotifier.setUser(null);
}

///Determine which state user is in, SignUp, Login or Reset
initializeCurrentUser(AuthNotifier authNotifier) async {
  FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();

  if (firebaseUser != null) {
    print(firebaseUser);
    authNotifier.setUser(firebaseUser);
  }
}

///Retrieve a list of review and rating for selected Wi-Fi hotspot
getReviews(ReviewNotifier reviewNotifier) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection('Reviews')
      .orderBy("createdAt", descending: true)
      .getDocuments();

  List<Review> _reviewList = [];

  snapshot.documents.forEach((document) {
    Review review = Review.fromMap(document.data);
    _reviewList.add(review);
  });

  reviewNotifier.reviewList = _reviewList;
}

///Upload User's Review
uploadReviewAndImage(Review review, bool isUpdating, Function reviewUploaded) async {
    print('...skipping image upload');
    _uploadReview(review, isUpdating, reviewUploaded);
}

///Upload User's Review
_uploadReview(Review review, bool isUpdating, Function reviewUploaded) async {
  CollectionReference reviewRef = Firestore.instance.collection('Reviews');

  if (isUpdating) {
    review.updatedAt = Timestamp.now();

    await reviewRef.document(review.id).updateData(review.toMap());

    reviewUploaded(review);
    print('updated review with id: ${review.id}');
  } else {
    review.createdAt = Timestamp.now();

    DocumentReference documentRef = await reviewRef.add(review.toMap());

    review.id = documentRef.documentID;

    print('uploaded review successfully: ${review.toString()}');

    await documentRef.setData(review.toMap(), merge: true);

    reviewUploaded(review);
  }
}

///Delete User's Review using ID
deleteReview(Review review, Function reviewDeleted) async {
  await Firestore.instance.collection('Reviews').document(review.id).delete();
  reviewDeleted(review);
}

///Retrieve User's favourite Wi-Fi hotspots
getFavourites(FavouriteNotifier favouriteNotifier) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection('Favourites')
      .orderBy("createdAt", descending: true)
      .getDocuments();

  List<Favourite> _favouriteList = [];

  snapshot.documents.forEach((document) {
    Favourite favourite = Favourite.fromMap(document.data);
    _favouriteList.add(favourite);
  });

  favouriteNotifier.favouriteList = _favouriteList;
}

///Upload User's favourite Wi-Fi hotspots
uploadUserFavourite(Favourite favourite) async {
    print('uploading favourites');
    _uploadFavourite(favourite);
}

///Upload User's favourite Wi-Fi hotspots
_uploadFavourite(Favourite favourite) async {
  CollectionReference reviewRef = Firestore.instance.collection('Favourites');
  favourite.createdAt = Timestamp.now();

    DocumentReference documentRef = await reviewRef.add(favourite.toMap());

  favourite.id = documentRef.documentID;
    print(favourite.id);

    print('Favourite wifi successfully: ${favourite.toString()}');

    await documentRef.setData(favourite.toMap(), merge: true);
}

///Delete User's favourite Wi-Fi hotpots using ID
deleteFavourite(Favourite favourite,BuildContext context) async {
  FavouriteNotifier favouriteNotifier = Provider.of<FavouriteNotifier>(context);
  await Firestore.instance.collection('Favourites').document(favouriteNotifier.findFavourite(favourite)).delete();
  print("fav deleted");
}