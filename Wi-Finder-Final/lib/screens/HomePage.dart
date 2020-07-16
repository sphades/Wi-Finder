import 'dart:async';
import 'package:WiFinder/notifier/review_notifier.dart';
import 'package:WiFinder/screens/access_info.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:geojson/geojson.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'Settings.dart';
import 'package:WiFinder/api/wiFinder_api.dart';
import 'package:WiFinder/api/data.dart';
import 'SearchPage.dart';
import 'package:WiFinder/notifier/locator.dart';
import 'package:WiFinder/model/favourite.dart';
import 'package:WiFinder/model/user.dart';
import 'package:WiFinder/notifier/auth_notifier.dart';
import 'package:WiFinder/notifier/favourite_notifier.dart';
import 'package:WiFinder/screens/ReviewPage.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Data data = locator<Data>();
  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Align(
            alignment: Alignment(0, 1),
            child: Column(
              children: <Widget>[
                _googlemaps(context),
                Expanded(
                  child: _menuSelector(),
                )
              ],
            )));
  }


  @override
  void initState() {
    super.initState();
    _dropdownSortMenuItem = buildDropdownSortMenuItems(_sorting);
    _selectedSort = _dropdownSortMenuItem[0].value;
    super.initState();
    _dropdownFilterMenuItem = buildDropdownFilterMenuItems(_filtering);
    _selectedFilter = _dropdownFilterMenuItem[0].value;
    super.initState();
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///Google Maps Methods and Widget Definition
  Future<void> _moveToPosition(Position pos) async {
    final GoogleMapController mapController = await _controller.future;
    if (mapController == null) return;
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(pos.latitude, pos.longitude),
      zoom: 15.0,
    )));
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await _moveToPosition(currentLocation);
    setState(() {
      _controller.complete(controller);
    });
  }

  void _onHotspotTapped(GeoJsonFeature f) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target:
          LatLng(f.geometry.geoPoint.latitude, f.geometry.geoPoint.longitude),
      zoom: 15.0,
    )));
    mapController.showMarkerInfoWindow(MarkerId(f.hashCode.toString()));
  }

  Set<Marker> _markers = {};
  Timer _timer;
  addMarkers() {
    _timer = new Timer(const Duration(milliseconds: 10), () {
      setState(() {
        _markers.clear();
        for (GeoJsonFeature p in currentList) {
          _markers.add(Marker(
              position: LatLng(
                  p.geometry.geoPoint.latitude, p.geometry.geoPoint.longitude),
              markerId: MarkerId(p.hashCode.toString()),
              onTap: () {
                int a = currentList.indexOf(p);
                print(a);
                _scrollController.scrollTo(
                    index: a ?? 0, duration: Duration(seconds: 1));
              },
              infoWindow: InfoWindow(
                title: p.properties['LOCATION_NAME'],
                snippet: p.properties['LOCATION_TYPE'],
              )));
        }
      });
    });
  }

  var lat, lng;

  Future getLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      lat = currentLocation.latitude;
      lng = currentLocation.longitude;
    });
  }

  Widget _googlemaps(BuildContext context) {
    getLocation();
    addMarkers();
    return lat == null || lng == null
        ? Container(
            height: 300.0,
          )
        : Container(
            child: Container(
              child: SafeArea(
                child: SizedBox(
                    height: 300.0,
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(lat, lng),
                        zoom: 14.0,
                      ),
                      myLocationEnabled: true,
                      markers: _markers.toSet(),
                    )),
              ),
            ),
          );
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///Widgets and Definitions for Filtering and Sorting List of hotspots
  List<Sort> _sorting = Sort.getSortList();
  List<DropdownMenuItem<Sort>> _dropdownSortMenuItem;
  Sort _selectedSort;

  List<Filter> _filtering = Filter.getFilterList();
  List<DropdownMenuItem<Filter>> _dropdownFilterMenuItem;
  Filter _selectedFilter;

  List<DropdownMenuItem<Sort>> buildDropdownSortMenuItems(List sorting) {
    List<DropdownMenuItem<Sort>> items = List();
    for (Sort sort in sorting) {
      items.add(
        DropdownMenuItem(
          value: sort,
          child: Text(sort.method),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<Filter>> buildDropdownFilterMenuItems(List filtering) {
    List<DropdownMenuItem<Filter>> items = List();
    for (Filter filter in filtering) {
      items.add(
        DropdownMenuItem(
          value: filter,
          child: Text(filter.method),
        ),
      );
    }
    return items;
  }

  ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionListener =
      ItemPositionsListener.create();

  List _saved =
      []; // list of saved favourites. to access the name, _saved[index].properties['Name]

  initiateFavourite() {
    _saved.clear();
    FavouriteNotifier favouriteNotifier =
        Provider.of<FavouriteNotifier>(context);
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    for (Favourite f in favouriteNotifier.favouriteList) {
      if (f.username == authNotifier.user.displayName)
        for (Map i in data.getUnsorted) {
          if (f.wifiName == i['feature'].properties['Name'])
            _saved.add(i['feature']);
        }
    }
  }

  List<GeoJsonFeature> currentList = [];
  ItemScrollController _scrollController2 = ItemScrollController();
  final ItemPositionsListener _itemPositionListener2 =
      ItemPositionsListener.create();

  Widget faveList() {
    int savedlength = _saved.length;

    return savedlength != 0
        ? ScrollablePositionedList.builder(
            itemCount: _saved.length ?? 0,
            itemScrollController: _scrollController2,
            itemPositionsListener: _itemPositionListener2,
            itemBuilder: (BuildContext context, int index) {
              ReviewNotifier reviewNotifier =
                  Provider.of<ReviewNotifier>(context);
              GeoJsonFeature current = _saved.elementAt(index) ??
                  locator<Data>().getHotspots.elementAt(index);
              return ExpandableNotifier(
                  child: ScrollOnExpand(child: Builder(builder: (context) {
                ExpandableController controller =
                    ExpandableController.of(context);
                return ExpandablePanel(
                  controller: controller,
                  header: ListTile(
                      title: Text(current.properties['LOCATION_NAME'],
                          style: TextStyle(fontSize: 20)),
                      onTap: () {
                        controller.toggle();
                        if (controller.expanded == true) {
                          _onHotspotTapped(current);
                        }
                      }),
                  expanded: Container(
                      child: Column(children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                            width: 200.0,
                            child: FlatButton(onPressed: () => launch(
                              "google.navigation:q=${current.geometry.geoPoint.latitude},${current.geometry.geoPoint.longitude}"),
                              child:Text(
                              current.properties['STREET_ADDRESS'],
                              style: Theme.of(context).textTheme.subtitle,
                            ))),
                        Container(child: _buildButton(current)),
                      ],
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
                            child: RaisedButton(
                                child: Text(
                                  'Average Rating: ${reviewNotifier.averageRating(current.properties['Name']).toStringAsFixed(1)}',
                                  style: Theme.of(context).textTheme.subtitle,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ReviewPage(feature: current)));
                                }),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
                            child: RaisedButton(
                                color: Colors.blue,
                                child: Text(
                                  'Access Information',
                                  style: Theme.of(context).textTheme.subtitle,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          AccessInfo()));
                                }),
                          ),
                        ])
                  ])),
                  theme: const ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    bodyAlignment: ExpandablePanelBodyAlignment.left,
                    tapHeaderToExpand: true,
                  ),
                );
              })));
            })
        : Container(alignment: Alignment.center, child: Text("No Favourites"));
  }

  Widget favePage() {
    FavouriteNotifier favouriteNotifier =
        Provider.of<FavouriteNotifier>(context, listen: false);
    ReviewNotifier reviewNotifier =
        Provider.of<ReviewNotifier>(context, listen: false);
    getFavourites(favouriteNotifier);
    getReviews(reviewNotifier);
    initiateFavourite();

    ///Entire Wi-Fi hotspots page
    return Column(children: <Widget>[
      Expanded(
          child: new RefreshIndicator(
              onRefresh: () async {
                await new Future.delayed(const Duration(
                    seconds:
                        1)); //"refreshes" by redrawing the page, can actually change it to make it do something useful
                setState(() {});
                return;
              },
              child: faveList()
              ))
    ]);
  }

  Widget bestList() => listLength != 0
      ? ScrollablePositionedList.builder(
          itemCount: listLength ?? 0,
          itemScrollController: _scrollController,
          itemPositionsListener: _itemPositionListener,
          itemBuilder: (BuildContext context, int index) {
            ReviewNotifier reviewNotifier =
                Provider.of<ReviewNotifier>(context);
            GeoJsonFeature current = currentList.elementAt(index) ??
                locator<Data>().getHotspots.elementAt(index);
            return ExpandableNotifier(
                child: ScrollOnExpand(child: Builder(builder: (context) {
              ExpandableController controller =
                  ExpandableController.of(context);
              return ExpandablePanel(
                controller: controller,
                header: ListTile(
                    title: Text(current.properties['LOCATION_NAME'],
                        style: TextStyle(fontSize: 20)),
                    onTap: () {
                      controller.toggle();
                      if (controller.expanded == true) {
                        _onHotspotTapped(current);
                      }
                    }),
                expanded: Container(
                    child: Column(children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: FlatButton(
                          child: Text(
                            current.properties['STREET_ADDRESS'],
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          onPressed: () => launch(
                              "google.navigation:q=${current.geometry.geoPoint.latitude},${current.geometry.geoPoint.longitude}"),
                        ),
                      ),
                      Container(child: _buildButton(current)),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
                          child: RaisedButton(
                              child: Text(
                                'Average Rating: ${reviewNotifier.averageRating(current.properties['Name'] ?? 0)}',
                                style: Theme.of(context).textTheme.subtitle,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ReviewPage(feature: current)));
                              }),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
                          child: RaisedButton(
                              color: Colors.blue,
                              child: Text(
                                'Access Information',
                                style: Theme.of(context).textTheme.subtitle,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        AccessInfo()));
                              }),
                        ),
                      ])
                ])),
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  bodyAlignment: ExpandablePanelBodyAlignment.left,
                  tapHeaderToExpand: true,
                ),
              );
            })));
          })
      : Container();

  ///Filter hotspots by selection
  filterHotspots(_selectedFilter) {
    currentList.clear();
    for (Map f in data.getUnsorted) {
      if (f['feature'].properties['LOCATION_TYPE'] == _selectedFilter.method ||
          _selectedFilter.method == 'All') {
        currentList.add(f['feature']);
      }
    }
    listLength = currentList.length;
  }

  ///Sort hotspots by proximity and average users rating
  sortHotspots(_selectedSort) {
    if (_selectedSort.method == 'Proximity') {
      data.sortDistance();
      filterHotspots(_selectedFilter);
    } else {
      sortRating(context);
    }
    listLength = currentList.length;
  }

  ///Sort hotspots by proximity and average users rating
  sortRating(BuildContext context) {
    ReviewNotifier reviewNotifier =
        Provider.of<ReviewNotifier>(context, listen: false);
    currentList.sort((a, b) => reviewNotifier
        .averageRating(b.properties["Name"])
        .compareTo(reviewNotifier.averageRating(a.properties["Name"])));
  }

  List distanceList = [];
  List localHotspots = [];
  int listLength = 0;

  onChangeSortDropdownItem(Sort selectedSort) {
    setState(() {
      _selectedSort = selectedSort;
      listLength = currentList.length;
      addMarkers();
      _scrollController.scrollTo(index: 0, duration: Duration(seconds: 1));
    });
  }

  onChangeFilterDropdownItem(Filter selectedFilter) {
    setState(() {
      _selectedFilter = selectedFilter;
      listLength = currentList.length;
    });
  }

  Widget hotspotsPage() {
    filterHotspots(_selectedFilter);
    sortHotspots(_selectedSort);
    return Column(children: <Widget>[
      new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(alignment: Alignment.center, child: Text('Sort:')),
          DropdownButton(
            value: _selectedSort,
            items: _dropdownSortMenuItem,
            onChanged: onChangeSortDropdownItem,
          ),
          Text('Filter:'),
          DropdownButton(
            hint: Text('Filter'),
            value: _selectedFilter,
            items: _dropdownFilterMenuItem,
            onChanged: onChangeFilterDropdownItem,
          ),
        ],
      ),
      Expanded(
          child: new RefreshIndicator(
              onRefresh: () async {
                await new Future.delayed(const Duration(
                    seconds:
                        1)); //"refreshes" by redrawing the page, can actually change it to make it do something useful
                setState(() {});
                return;
              },
              child: bestList()

              //buildPlacesList(_selectedSort, _selectedFilter)),
              ))
    ]);
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///Menu selector definitions and widgets

  Color iconCol1 = Colors.blue[900];
  Color lineCol1 = Colors.blue[900];
  Color iconCol2 = Colors.grey;
  Color lineCol2 = Colors.grey[350];
  Color iconCol3 = Colors.grey;
  Color lineCol3 = Colors.grey[350];
  Color iconCol4 = Colors.grey;
  Color lineCol4 = Colors.grey[350];

  int _currentIndex = 0;

  ///Main function to control the menu bar
  void onTappedBar(int index) async{
    if (index == 2) {
      ///To activate the linkups
      Future<int> selected =
           showSearch(delegate: DataSearch(), context: context);
      Future<int> chosen = selected.then((a) => magic(a));
      if (_selectedSort.method == 'Ratings') {
        chosen.then((a) => _onHotspotTapped(currentList[a]));
        chosen.then((a) => _scrollController.scrollTo(
            index: a ?? 0, duration: Duration(seconds: 1)));
      } else {
        chosen.then((a) => _onHotspotTapped(data.getUnsorted[a]['feature']));
        chosen.then((a) => _scrollController.scrollTo(
            index: a ?? 0, duration: Duration(seconds: 1)));
      }
      setState(() {
        if (_currentIndex == 0) {
          _currentIndex = 0;
          iconCol1 = Colors.blue[900];
          lineCol1 = Colors.blue[900];
          iconCol2 = Colors.grey;
          lineCol2 = Colors.grey[350];
          iconCol3 = Colors.grey;
          lineCol3 = Colors.grey[350];
          iconCol4 = Colors.grey;
          lineCol4 = Colors.grey[350];
          _selectedFilter = _dropdownFilterMenuItem[0].value;
        } else {
          _currentIndex = 1;
          iconCol2 = Colors.blue[900];
          lineCol2 = Colors.blue[900];
          iconCol3 = Colors.grey;
          lineCol3 = Colors.grey[350];
          iconCol4 = Colors.grey;
          lineCol4 = Colors.grey[350];
          iconCol1 = Colors.grey;
          lineCol1 = Colors.grey[350];
          _selectedFilter = _dropdownFilterMenuItem[0].value;
        }
      });
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  User user;

  /// Menu Bar UI
  Widget _menuSelector() {
    return Container(
        child: Column(children: <Widget>[
      Row(
        children: <Widget>[
          Container(
            height: 50,
            width: 98,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: lineCol1, width: 3))),
            child: IconButton(
                icon: Icon(Icons.wifi),
                color: iconCol1,
                iconSize: 30.0,
                onPressed: () {
                  setState(() {
                    onTappedBar(0);
                    iconCol1 = Colors.blue[900];
                    lineCol1 = Colors.blue[900];
                    iconCol2 = Colors.grey;
                    lineCol2 = Colors.grey[350];
                    iconCol3 = Colors.grey;
                    lineCol3 = Colors.grey[350];
                    iconCol4 = Colors.grey;
                    lineCol4 = Colors.grey[350];
                  });
                }),
          ),
          Container(
            height: 50,
            width: 97,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: lineCol2, width: 3))),
            child: IconButton(
                icon: Icon(Icons.favorite),
                color: iconCol2,
                iconSize: 30.0,
                onPressed: () {
                  setState(() {
                    onTappedBar(1);
                    iconCol2 = Colors.blue[900];
                    lineCol2 = Colors.blue[900];
                    iconCol3 = Colors.grey;
                    lineCol3 = Colors.grey[350];
                    iconCol4 = Colors.grey;
                    lineCol4 = Colors.grey[350];
                    iconCol1 = Colors.grey;
                    lineCol1 = Colors.grey[350];
                  });
                }),
          ),
          Container(
            height: 50,
            width: 97,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: lineCol3, width: 3))),
            child: IconButton(
                icon: Icon(Icons.search),
                color: iconCol3,
                iconSize: 30.0,
                onPressed: () {
                  setState(() {
                    onTappedBar(2);
                  });
                }),
          ),
          Container(
            height: 50,
            width: 97,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: lineCol4, width: 3))),
            child: IconButton(
                icon: Icon(Icons.settings),
                color: iconCol4,
                iconSize: 30.0,
                onPressed: () {
                  setState(() {
                    onTappedBar(3);
                    iconCol4 = Colors.blue[900];
                    lineCol4 = Colors.blue[900];
                    iconCol2 = Colors.grey;
                    lineCol2 = Colors.grey[350];
                    iconCol3 = Colors.grey;
                    lineCol3 = Colors.grey[350];
                    iconCol1 = Colors.grey;
                    lineCol1 = Colors.grey[350];
                  });
                }),
          ),
        ],
      ),
      Expanded(
          //controls the seamless switching of pages
          child: IndexedStack(
        index: _currentIndex,
        children: [
          hotspotsPage(),
          favePage(),
          Settings(),
          Settings(),
        ], //missing settings page
      ))
    ]));
  }

  Favourite _currentFavourite = new Favourite();

  _saveFavourite() {
    uploadUserFavourite(_currentFavourite);
    print("name: ${_currentFavourite.username}");
    print("wifi name: ${_currentFavourite.wifiName}");
  }


  int magic(int indexTest) {
    if (_selectedSort.method == "Proximity") {
      for (Map i in data.unsorted) {
        if (i['index_test'] == indexTest) return data.unsorted.indexOf(i);
      }
    } else if (_selectedSort.method == "Ratings") {
      for (Map i in data.unsorted) {
        if (i['index_test'] == indexTest)
          for (GeoJsonFeature j in currentList) {
            if (i['feature'].properties['Name'] == j.properties['Name'])
              return currentList.indexOf(j);
          }

      }
    }
    return indexTest;
  }

  ///Favourite button UI
  Widget _buildButton(GeoJsonFeature f) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    final _isFavorited = _saved.contains(f);

    return Container(
      height: 50,
      width: 50,
      alignment: Alignment.center,
      child: IconButton(
          icon: (_isFavorited
              ? Icon(Icons.favorite)
              : Icon(Icons.favorite_border)),
          color: Colors.red,
          iconSize: 30.0,
          onPressed: () {
            setState(() {
              if (_isFavorited) {
                _currentFavourite = Favourite.fave(
                  username: authNotifier.user.displayName,
                  wifiName: f.properties['Name'],
                );
                deleteFavourite(_currentFavourite, context);
              } else {
                _currentFavourite = Favourite.fave(
                  username: authNotifier.user.displayName,
                  wifiName: f.properties['Name'],
                );
                _saveFavourite();
              }
            });
          }),
    );
  }
}

////////////////////////////////////////////////////////////////////////
///Class definitions for sort and filter, can be exported
class Sort {
  String method;
  Sort(this.method);
  static List<Sort> getSortList() {
    return <Sort>[
      Sort('Proximity'),
      Sort('Ratings'),
    ];
  }
}

class Filter {
  String method;
  Filter(this.method);
  static List<Filter> getFilterList() {
    return <Filter>[
      Filter('All'),
      Filter('Commercial'),
      Filter('Community'),
      Filter('Dormitory \/ Care Centre'),
      Filter('F&B'),
      Filter('Government'),
      Filter('Healthcare'),
      Filter('Public Transport'),
      Filter('Public Worship'),
      Filter('Retail Shop'),
      Filter('School'),
      Filter('Shopping Mall'),
      Filter('Tourist Attraction'),
      Filter('Welfare Organisation'),
    ];
  }
}
