import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  //static so it can be accessed without building the Welcome Screen object
  //const so it can't accidentally be changed somewhere else
  static const String id = 'LoginScreen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email;
  String password;
  bool showSpinner = false;

  //create new authentication instance as final (not going to change it)
  //using _ to keep it private so other classes can't mess with this variable
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              //use flexible to make sure when keyboard pops up, everything else flexes to fit
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    //stays at 200, but will shrink a bit because of "Flexible" widget
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                //makes it easier to put in email address with keyboard
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  email = value;
                },
//              decoration: InputDecoration(
////                hintText: 'Enter your email',
////                contentPadding:
////                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
////                border: OutlineInputBorder(
////                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
////                ),
////                enabledBorder: OutlineInputBorder(
////                  borderSide:
////                      BorderSide(color: Colors.lightBlueAccent, width: 1.0),
////                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
////                ),
////                focusedBorder: OutlineInputBorder(
////                  borderSide:
////                      BorderSide(color: Colors.lightBlueAccent, width: 2.0),
////                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
////                ),
////              ),
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your email',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                //make the letters all show as astrix
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  password = value;
                },
//              decoration: InputDecoration(
//              hintText: 'Enter your password.',
//              contentPadding:
//              EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//              border: OutlineInputBorder(
//                borderRadius: BorderRadius.all(Radius.circular(32.0)),
//              ),
//              enabledBorder: OutlineInputBorder(
//                borderSide:
//                BorderSide(color: Colors.lightBlueAccent, width: 1.0),
//                borderRadius: BorderRadius.all(Radius.circular(32.0)),
//              ),
//              focusedBorder: OutlineInputBorder(
//                borderSide:
//                BorderSide(color: Colors.lightBlueAccent, width: 2.0),
//                borderRadius: BorderRadius.all(Radius.circular(32.0)),
//              ),
//            ),
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password.',
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                color: Colors.lightBlueAccent,
                buttonTitle: 'Log In',
                goToPage: () async {
                  setState(() {
                    //turn ModalProgressHUD loading screen on
                    showSpinner = true;
                  });
                  //this can fail for many reasons, so we keep it ready to report errors
                  try {
                    //recognize user with Firebase instance (returns a Future)
                    //save as a variable
                    //don't continue on until newUser is done being recognized
                    final knownUser = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    //if the we get a knownUser back successfully...
                    if (knownUser != null) {
                      //navigate user to the chat screen
                      Navigator.pushNamed(context, ChatScreen.id);
                    }
                    setState(() {
                      //turn ModalProgressHUD loading screen off
                      showSpinner = false;
                    });
                  } catch (e) {
                    print(e);
                    setState(() {
                      //turn ModalProgressHUD loading screen off
                      showSpinner = false;
                    });
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
