import 'package:WiFinder/api/wiFinder_api.dart';
import 'package:WiFinder/model/review.dart';
import 'package:WiFinder/notifier/auth_notifier.dart';
import 'package:WiFinder/notifier/review_notifier.dart';
import 'package:WiFinder/screens/review_form.dart';
import 'package:flutter/material.dart';
import 'package:geojson/geojson.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ReviewPage extends StatefulWidget {

  final GeoJsonFeature feature;

  ReviewPage({Key key, @required this.feature}) : super(key: key);
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

/// Method will be called if its the first time a stateful widget is inserted in the widget-tree
class _ReviewPageState extends State<ReviewPage> {
  @override
  void initState() {
    ReviewNotifier reviewNotifier =
        Provider.of<ReviewNotifier>(context, listen: false);
    getReviews(reviewNotifier);
    super.initState();
  }

  /// Main UI for Review Page
  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    ReviewNotifier reviewNotifier = Provider.of<ReviewNotifier>(context);
    _onReviewDeleted(Review review) {
      reviewNotifier.deleteReview(review);
    }

    ///Retrieve reviews and ratings for selected Wi-Fi
    Future<void> _refreshList() async {
      getReviews(reviewNotifier);
    }

    List<Review> localList = [];

    initiateLocalList(){
      ReviewNotifier reviewNotifier = Provider.of<ReviewNotifier>(context);
      for (Review r in reviewNotifier.reviewList){
      if(r.name == widget.feature.properties['Name']){
        localList.add(r);
      }
      }
    }

    ///To edit & delete review and rating
    _reviewPopup(int index) => PopupMenuButton<int>(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 1,
              child: Text(
                "Edit",
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: Text("Delete"),
            ),
          ],
          onSelected: (value) {
            if (value == 1) {
              /// To edit review
              reviewNotifier.currentReview = localList[index];
              Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return ReviewForm(
                    isUpdating: true,feature:widget.feature
                  );
                }),
              );
            }
            if (value == 2) {
              /// To delete review
              deleteReview(localList[index], _onReviewDeleted);
            }
          },
        );

    ///Refresh page everytime it is loaded
    _refreshList();
    initiateLocalList();

    return Scaffold(
      appBar: AppBar(title:Text('Ratings and Reviews'),actions: <Widget>[
      ]
      ),
      body: new RefreshIndicator(
        child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return localList.isNotEmpty ? ListTile(
                leading: Icon(Icons.account_circle, size: 45.0),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(localList[index].username),
                    SmoothStarRating(
                        rating: localList[index].rating)
                  ],
                ),
                subtitle: Text(localList[index].review),
                trailing: Visibility(
                  visible: localList[index].username == authNotifier.user.displayName ? true:false,
                  child: _reviewPopup(index),
                )
                ): Center(child:Text("No Reviews Yet",style:TextStyle(color:Colors.black, fontSize: 40)));
          },
          itemCount: localList.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              color: Colors.black,
            );
          },
        ),
        onRefresh: _refreshList,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          reviewNotifier.currentReview = null;
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return ReviewForm(
              isUpdating: false, feature:widget.feature,
            );
          }));
        },
        child: Icon(Icons.add),
        foregroundColor: Colors.white,
      ),
    );
  }
}
