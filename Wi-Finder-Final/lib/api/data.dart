import 'dart:math';
import 'package:flutter/services.dart';
import 'package:geojson/geojson.dart';
import 'package:geolocator/geolocator.dart';

/// Store all Wi-Fi hotspots retrieved from Wireless@SG into JSON File
class Data {
  List<GeoJsonFeature> _hotspots = [];
  List unsorted = [];
  List<GeoJsonFeature> get getHotspots {
    return _hotspots;
  }

  List get getUnsorted {
    return unsorted;
  }

  Data() {
    parse();
    sortDistance();
  }

  double getDistance(GeoJsonFeature f, Position pos)  {
    var lat2 = f.geometry.geoPoint.latitude;
    var lon2 = f.geometry.geoPoint.longitude;
    var lat1 = pos.latitude;
    var lon1 = pos.longitude;
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
    c(lat1 * p) * c(lat2 * p) *
    (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  void sortDistance(){
    unsorted.sort((a,b)=>a['distance'].compareTo(b['distance']));
  }
  void sortReview(){
    unsorted.sort((a,b)=>a['index_test'].compareTo(b['index_test']));
  }

  Future<void> parse() async {
    
  
    ///setup geojson parser
    final geo = GeoJson();
    ///var currentLocation = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    ///setup "listeners" to listen for signals/events
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    geo.processedFeatures.listen((GeoJsonFeature feature) {
      _hotspots.add(feature);
      unsorted.add({
        'feature': feature,
        'distance': getDistance(feature,currentLocation),
        'name': feature.properties['LOCATION_NAME'].toString().toLowerCase(),
        'index_test': unsorted.length,
      });
      
    });
    
    ///clean up geojson parser assignment
    geo.endSignal.listen((_) {
      geo.dispose();
    });

    final data = await rootBundle.loadString('data/d.geojson');
    await geo.parse(data, verbose: true);
  }
}
