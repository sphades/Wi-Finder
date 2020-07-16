import 'package:WiFinder/screens/HomePage.dart';
import 'package:WiFinder/notifier/review_notifier.dart';
import 'package:WiFinder/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:WiFinder/notifier/locator.dart';
import 'notifier/auth_notifier.dart';
import 'notifier/favourite_notifier.dart';

///Notify Auth, Review and Favourite Notifiers
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  dataLocator();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          builder: (context) => AuthNotifier(),
        ),
        ChangeNotifierProvider(
          builder: (context) => ReviewNotifier(),
        ),
        ChangeNotifierProvider(
          builder: (context) => FavouriteNotifier(),
        ),
      ],
      child: MyApp(),
    ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //routes: routes,
      debugShowCheckedModeBanner: false,
      title: 'WiFinder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.lightBlue,
      ),
      home: Consumer<AuthNotifier>(
        builder: (context, notifier, child) {
          return notifier.user != null ? HomePage() : Login();
        },
      ),
    );
  }
}
