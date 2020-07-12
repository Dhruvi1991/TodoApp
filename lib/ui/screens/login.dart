import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/ui/approutes.dart';
import 'package:todo/ui/uihelpers/size_config.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  final _firebaseAuth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(title: Text('Authentication')),
        body: Padding(
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
            // Align widgets in a vertical column
            child: Column(
              // Passing multiple widgets as children to Column
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                        bottom: SizeConfig.blockSizeHorizontal * 4),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Email'),
                    )),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: SizeConfig.blockSizeHorizontal * 4),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Password'),
                    )),
                RaisedButton(
                  // Calling the callback with the supplied email and password
                  onPressed: () async {
                    final user = await login(
                        emailController.text, passwordController.text);
                    if (user != null) {
                      Navigator.pushReplacementNamed(context, todoList);
                    } else {
                      _showAuthFailedDialog();
                    }
                  },
                  child: Text('LOGIN', style: TextStyle(color: Colors.white),),
                  // Setting the primary color on the button
                  color: Colors.teal,
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
            )));
  }

  Future<FirebaseUser> login(String email, String password) async {
    try {
      AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      return result.user;
    } catch (e) {
      return null;
    }
  }

  // Show error if login unsuccessfull
  void _showAuthFailedDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text('Could not log in'),
          content: Text('Double check your credentials and try again'),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
