import 'package:cloud_firestore/cloud_firestore.dart';

///Favourite Attributes
class Favourite {

  String id;
  String username;
  String wifiName;
  Timestamp createdAt;

  Favourite();

   Favourite.fave({this.username,this.wifiName,this.createdAt,this.id});

  Favourite.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    username = data['username'];
    wifiName = data['wifiName'];
    createdAt = data['createdAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'wifiName': wifiName,
      'createdAt': createdAt,
    };
  }
}
