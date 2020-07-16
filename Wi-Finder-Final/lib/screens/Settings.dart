import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:WiFinder/api/wiFinder_api.dart';
import 'package:WiFinder/api/data.dart';
import 'package:WiFinder/notifier/locator.dart';
import 'package:WiFinder/notifier/auth_notifier.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Data data = locator<Data>();
  onChange() {
    setState(() {});
  }

  ///Main UI for Settings; consist of Log out button
  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    return Container(
        alignment: Alignment.center,
        child: FlatButton(
            onPressed: () => signout(authNotifier),
            child: Text(
              "Logout",
              style: TextStyle(fontSize: 20, color: Colors.blue),
            ),
          ),
    );
  }
}
