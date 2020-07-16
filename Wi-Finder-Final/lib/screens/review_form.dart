import 'package:WiFinder/api/wiFinder_api.dart';
import 'package:WiFinder/model/review.dart';
import 'package:WiFinder/notifier/review_notifier.dart';
import 'package:flutter/material.dart';
import 'package:geojson/geojson.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:WiFinder/notifier/auth_notifier.dart';
import 'package:WiFinder/api/data.dart';
import 'package:WiFinder/notifier/locator.dart';

class ReviewForm extends StatefulWidget {
  final bool isUpdating;
  final GeoJsonFeature feature;

  ReviewForm({@required this.isUpdating, @required this.feature}) ;

  @override
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Data data = locator<Data>();
  Review _currentReview;
  double rating = 0.0;

  @override
  void initState() {
    super.initState();
    ReviewNotifier reviewNotifier =
        Provider.of<ReviewNotifier>(context, listen: false);
    if (reviewNotifier.currentReview != null) {
      _currentReview = reviewNotifier.currentReview;
    } else {
      _currentReview = Review();
    }
  }

  ///To capture User's username
  Widget _usernameField() {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    return TextFormField(
      initialValue: authNotifier.user.displayName,
      validator: (String value) {
        if (value.isEmpty) {
          return 'email is required';
        }
        return null;
      },
      onSaved: (String value) {
        _currentReview.username = value;
      },
    );
  }

  ///To capture selected Wi-Fi ID
  Widget _buildWifiNameField() {
    return Opacity(opacity:0, child:TextFormField(
      decoration: InputDecoration(labelText: 'Name'),
      initialValue: widget.feature.properties['Name'],
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 20),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Name is required';
        }

        if (value.length < 3 || value.length > 20) {
          return 'Name must be more than 3 and less than 20';
        }

        return null;
      },
      onSaved: (String value) {
        _currentReview.name = value;
      },
    ));
  }

  ///User's input for rating
  Widget _buildRatingField() {
    return FormField<double>(
      initialValue: _currentReview.rating,
      builder: (state) {
        return SmoothStarRating(
          color: Colors.amber,
          borderColor: Colors.grey,
          rating: rating,
          size: 32.0,
          filledIconData: Icons.star,
          allowHalfRating: false,
          spacing: 4,
          defaultIconData: Icons.star_border,
          starCount: 5,
          onRatingChanged: (value) {
            
            setState(() {
              rating = value;
            });
          },
        );
      },
      onSaved: (double value) {
        _currentReview.rating = rating;
      },
    );
  }

  ///User's input for review
  Widget _buildReviewField() {
    return TextFormField(
      decoration: InputDecoration(
          hintText: 'Describe your experience',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 16.0)),
      initialValue: _currentReview.review,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 18.0),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Review is required';
        }
        if (value.length < 2 || value.length > 100) {
          return 'Review must be more than 2 and less than 100';
        }
        return null;
      },
      onSaved: (String value) {
        _currentReview.review = value;
      },
    );
  }

  ///Notify local list that there's a new review submitted
  _onReviewUploaded(Review review) {
    ReviewNotifier reviewNotifier =
        Provider.of<ReviewNotifier>(context, listen: false);
    reviewNotifier.addReview(review);
    Navigator.pop(context);
  }

  ///Upload Review into Cloud Firestore
  _saveReview() {
    print('saveReview Called');
    if (!_formKey.currentState.validate()) {
      print('failed');
      return;
    }
    _formKey.currentState.save();
    print('form saved');
    uploadReviewAndImage(
        _currentReview, widget.isUpdating, _onReviewUploaded);
    print("name: ${_currentReview.username}");
    print("name: ${_currentReview.name}");
    print("category: ${_currentReview.review}");
    print("category: ${_currentReview.rating}");
  }

  ///Main UI for Review Form
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: Text(widget.isUpdating ? "Edit Review" : "Create Review")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Reviewing ${widget.feature.properties['LOCATION_NAME']}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 15),
                Text('Rate Your Experience',
                    style: TextStyle(color: Colors.grey, fontSize: 18.0)),
                SizedBox(height: 15),
                _buildRatingField(),
                SizedBox(height: 15),
                _buildReviewField(),
                SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.all(8),
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                Opacity(
                  opacity: 0,
                  child: _usernameField(),
                ),
                _buildWifiNameField()
              ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          _saveReview();
        },
        child: Icon(Icons.save),
        foregroundColor: Colors.white,
      ),
    );
  }

}
