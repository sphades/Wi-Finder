import 'dart:collection';
import 'package:WiFinder/model/favourite.dart';
import 'package:flutter/cupertino.dart';

///2nd Tier Database layer for favourite Wi-Fi hotspots
class FavouriteNotifier with ChangeNotifier {
  List<Favourite> _favouriteList = [];
  Favourite _currentFavourite;

  UnmodifiableListView<Favourite> get favouriteList => UnmodifiableListView(_favouriteList);

  Favourite get currentFavourite => _currentFavourite;

  set favouriteList(List<Favourite> favouriteList) {
    _favouriteList = favouriteList;
    notifyListeners();
  }

  set currentFavourite(Favourite favourite) {
    _currentFavourite = favourite;
    notifyListeners();
  }

  addFavourite(Favourite favourite) {
    _favouriteList.insert(0, favourite);
    
    notifyListeners();
    for (Favourite i in _favouriteList){
      print('hi'+i.wifiName);
    }
  }

  String findFavourite(Favourite favourite){
    List<Favourite> favourites = new List<Favourite>.from(_favouriteList.where((_favourite) => _favourite.wifiName == favourite.wifiName));
    print(favourites.first.id);
    return favourites.first.id;
  }

}
