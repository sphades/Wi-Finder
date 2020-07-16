import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AccessInfo extends StatefulWidget {
  @override
  _AccessInfoState createState() => _AccessInfoState();
}

/// Wireless@SG access information UI
class _AccessInfoState extends State<AccessInfo> {
  _linkURL() async {
    const url = 'https://www.imda.gov.sg/wireless-sg';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Access Infomation'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20.0),
              child: Text('Log on to Wireless@SG now, and enjoy FREE wireless Internet access in public places across Singapore with a surfing speed of at least 5Mbps!',
                style: TextStyle(fontStyle: FontStyle.italic,),
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              child: new Image.asset('assets/images/wireless-sg.png', height: 70.0, fit: BoxFit.cover,),
            ),
            SizedBox(height: 30.0),
            Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('For supported devices (Android, iOS, Windows 7 and above):', style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.blue), textAlign: TextAlign.center,),
                  SizedBox(height: 40.0),
                  Text('Step 1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),),
                  SizedBox(height: 15.0),
                  Text('Download Wireless@SG App.', style: TextStyle(fontSize: 15),),
                  SizedBox(height: 5.0),
                  InkWell(child: Text('Download >', style: TextStyle(fontSize: 15, color: Colors.blueAccent, decoration: TextDecoration.underline),), onTap: _linkURL),
                  SizedBox(height: 25.0),
                  Text('Step 2', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),),
                  SizedBox(height: 15.0),
                  Text('Select "Setup" from drop-down menu.', style: TextStyle(fontSize: 15),),
                  SizedBox(height: 25.0),
                  Text('Step 3', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),),
                  SizedBox(height: 15.0),
                  Text('Select your mobile operator and key in your mobile number.', style: TextStyle(fontSize: 15), textAlign: TextAlign.center,),
                  SizedBox(height: 25.0),
                  Text('Step 4', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),),
                  SizedBox(height: 15.0),
                  Text('A one-time pin will be sent to the registered mobile number. Key in the one-time pin to connect to Wireless@SG.', style: TextStyle(fontSize: 15), textAlign: TextAlign.center,),
                  SizedBox(height: 30.0),
                  Container(width: 20, height: 2, color: Colors.blueAccent,),
                  SizedBox(height: 60.0),
                  Text('For foreign visitors and non-supported devices:', style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.blue), textAlign: TextAlign.center,),
                  SizedBox(height: 40.0),
                  Text('Step 1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),),
                  SizedBox(height: 15.0),
                  Text('Locate a Wireless@SG hotspot and sign in with your moblie number.', style: TextStyle(fontSize: 15), textAlign: TextAlign.center,),
                  SizedBox(height: 5.0),
                  InkWell(child: Text('Sign in >', style: TextStyle(fontSize: 15, color: Colors.blueAccent, decoration: TextDecoration.underline),), onTap: _linkURL),
                  SizedBox(height: 25.0),
                  Text('Step 2', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),),
                  SizedBox(height: 15.0),
                  Text('Key in your mobile number and verification code indicated on the screen.', style: TextStyle(fontSize: 15), textAlign: TextAlign.center,),
                  SizedBox(height: 25.0),
                  Text('Step 3', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),),
                  SizedBox(height: 15.0),
                  Text('A one-time pin will be sent to the registered mobile number. Key in the one-time pin to connect to Wireless@SG.', style: TextStyle(fontSize: 15), textAlign: TextAlign.center,),
                  SizedBox(height: 30.0),
                  Container(width: 20, height: 2, color: Colors.blueAccent,),
                  SizedBox(height: 50.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
