import 'package:flutter/material.dart';
import 'package:WiFinder/api/data.dart';
import 'package:WiFinder/notifier/locator.dart';

class DataSearch extends SearchDelegate<int> {
  static Data data = locator<Data>();
  var recentCities = [
  ];

  ///Suggested Wi-Fi hotspots names based on keyword entered
  @override
  Widget buildSuggestions(BuildContext context) {
    var suggestionList = query.isEmpty
        ? recentCities
        : data.unsorted.where((p) => p['name'].contains(query)).toList();
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          print(suggestionList[index]['index_test']);
        close(context,suggestionList[index]['index_test']);
        },
        leading: Icon(Icons.wifi),
        title: RichText(
            text: TextSpan(
                text: suggestionList[index]['name'].substring(0, query.length),
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                children: [
              TextSpan(
                  text: suggestionList[index]['name'].substring(query.length),
                  style: TextStyle(color: Colors.grey))
            ])),
      ),
      itemCount: suggestionList.length,
    );
  }

  ///Display Search Results
  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  ///Return to hotspot page
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  ///Actions for application bar
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }
}
