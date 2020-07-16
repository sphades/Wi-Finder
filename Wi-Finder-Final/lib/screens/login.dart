import 'package:WiFinder/api/wiFinder_api.dart';
import 'package:WiFinder/model/user.dart';
import 'package:WiFinder/notifier/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AuthMode { Signup, Login, Reset }

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}


class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = new TextEditingController();
  AuthMode _authMode = AuthMode.Login;
  bool rState = true;
  bool spwState = true;
  User _user = User();
  String errorMessage = ' ';

  ///Pop up Dialog when user choose to resets their password
  void _sendPwLinkDialog(){
     showDialog(
         context: context,
         builder: (BuildContext context){
      return AlertDialog(
        title: Text("Reset password link sent to email !"),
        actions: <Widget>[
          MaterialButton(
            elevation: 5.0,
            child: Text('Close'),
            onPressed: (){
              Navigator.pop(context);
            },
          )
        ],
      );
    });
  }

  @override
  void initState() {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    initializeCurrentUser(authNotifier);
    super.initState();
  }

  ///Submits data based on user's Auth Mode
  void _submitForm() {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context, listen: false);

      if (_authMode == AuthMode.Login) {
        login(_user, authNotifier);
      }
      else if (_authMode == AuthMode.Reset) {

          sendPasswordResetEmail(_user);
        _sendPwLinkDialog();

        setState(() {
          _authMode = AuthMode.Login;
        });
      }
      else {
        signup(_user, authNotifier);
        setState(() {
          _passwordController.clear(); //Clear value
          _authMode =
          _authMode == AuthMode.Login ? AuthMode.Signup : AuthMode.Login;
        });
        _createAlertDialog(context);
      }
  }

  ///Pop up Dialog upon successful creation of Wi-Finder account
  Future<String> _createAlertDialog(BuildContext context){
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Account Created! Please verify your email address before logging in !"),
        actions: <Widget>[
          MaterialButton(
            elevation: 5.0,
            child: Text('Okay'),
            onPressed: (){
              Navigator.pop(context);
            },
          )
        ],
      );
    });
  }

  ///User's username text field with validation
  Widget _buildDisplayNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Username",
        labelStyle: TextStyle(color: Colors.blue[650]),
      ),
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 26, color: Colors.blue[650]),
      cursorColor: Colors.blue[650],
      validator: (String value) {
        if (value.isEmpty) {
          return 'Username is required';
        }
        if (value.length < 6 ){
          return 'Username is too short';
        }
        return null;
      },
      onSaved: (String value) {
        _user.username = value;
      },
    );
  }

  ///User's email text field with validation
  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Email",
        labelStyle: TextStyle(color: Colors.grey[600]),
        hintText: ' ',
      ),
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(fontSize: 26, color: Colors.grey[600]),
      cursorColor: Colors.grey[600],
      validator: (String value) {
        if (value.isEmpty) {
          return 'Email is required';
        }
        if (!RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value)) {
          return 'Please enter a valid email address';
        }

        return null;
      },
      onSaved: (String value) {
        _user.email = value;
      },
    );
  }

  ///User's password text field with validation
  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: TextStyle(color: Colors.grey[600]),
        hintText: ' ',
      ),
      style: TextStyle(fontSize: 26, color: Colors.grey[600]),
      cursorColor: Colors.grey[600],
      obscureText: true,
      controller: _passwordController,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 6 ) {
          return 'Password is too short. At least 6 characters is needed.';
        }
        if (!RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)").hasMatch(value)) {
          return 'Required: At least 1 digit, symbol, lowercase & uppercase character';
        }
        return null;
      },
      onSaved: (String value) {
        _user.password = value;
      },
    );
  }

  ///User's confirm password text field with validation
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Confirm Password",
        labelStyle: TextStyle(color: Colors.grey[600]),
      ),
      style: TextStyle(fontSize: 26, color: Colors.grey[600]),
      cursorColor: Colors.grey[600],
      obscureText: true,
      validator: (String value) {
        if (_passwordController.text != value) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  ///Checks User's Auth Mode at _submitForm() before submitting data
  String submitButton(){
    if (_authMode == AuthMode.Reset){
      return 'Reset';
    }
    else return _authMode == AuthMode.Login ? 'Login' : 'Signup';
  }

  ///Login Main UI
  @override
  Widget build(BuildContext context) {
    print("Building login screen");
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),

        decoration: BoxDecoration(color: Colors.white54),

        child: Form(
          autovalidate: true,
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(32, 96, 32, 0),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/wifisymbol.png',
                    width: 100,
                    height:100,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Wi-Finder",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, color: Colors.blue[400], fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 25),
                  _authMode == AuthMode.Signup ? _buildDisplayNameField() : Container(),
                  _buildEmailField(),
                  _authMode == AuthMode.Reset ?  Container():_buildPasswordField(),
                  _authMode == AuthMode.Signup ? _buildConfirmPasswordField() : Container(),
                  SizedBox(height: 32),

                  Visibility(
                    visible: rState,
                 child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ButtonTheme(
                        minWidth: 400,
                        child: RaisedButton(
                          padding: EdgeInsets.all(8.0),
                          onPressed: () => _submitForm(),
                          child: Text(
                            _authMode == AuthMode.Login ?  'Login With Email' : 'Create New Account' ,
                            style: TextStyle(fontSize: 21, color: Colors.white),
                          ),
                        ),
                      ),
                      ButtonTheme(
                        minWidth: 400,
                        child: RaisedButton(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            //Have switch to
                            '${_authMode == AuthMode.Signup ? 'Login With Email' : 'Create New Account'}',
                            style: TextStyle(fontSize: 21, color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              _authMode =
                              _authMode == AuthMode.Login
                                  ? AuthMode.Signup
                                  : AuthMode.Login;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  ),

                  Visibility(
                    visible: !rState,
                    child: ButtonTheme(
                      minWidth: 400,
                      child: RaisedButton(
                        padding: EdgeInsets.all(8.0),
                        onPressed: () {
                          _submitForm();
                          setState(() {
                            _authMode = AuthMode.Login;
                            rState = true;
                            spwState = true;
                          });
                        },
                        child: Text( 'Send Reset Password Link' ,
                          style: TextStyle(fontSize: 21, color: Colors.white),
                        ),
                      ),
                    ),
                  ),

              Visibility(
                visible: spwState,
                  child:ButtonTheme(
                    child: FlatButton(
                      color: Colors.white,
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(fontSize: 17, color: Colors.grey),
                      ),
                      onPressed: () {
                        spwState = false;
                        rState = false;
                        setState(() {
                          _authMode = AuthMode.Reset;
                        });
                      },
                    ),
                  ),
              ),

              Visibility(
                visible: !spwState,
                 child: ButtonTheme(
                    child: FlatButton(
                      color: Colors.white,
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        'Back To Login',
                        style: TextStyle(fontSize: 17, color: Colors.grey),
                      ),
                      onPressed: () {
                        spwState = true;
                        rState = !rState;
                        setState(() {
                          _authMode = AuthMode.Login;
                        });
                      },
                    ),
                  ),
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
