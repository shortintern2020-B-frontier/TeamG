import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hikomaryu/const.dart';
import 'package:hikomaryu/home.dart';
import 'package:hikomaryu/widget/loading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'signup.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SharedPreferences prefs;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;
  bool isLoggedIn = false;
  User currentUser;

  @override
  void initState() {
    super.initState();
    isSignedIn();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });

    prefs = await SharedPreferences.getInstance();

    User user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomeScreen(currentUserId: prefs.getString('id'))),
      );
    }

    this.setState(() {
      isLoading = false;
    });
  }

  String isEmptyValidator(String value) {
    if (value.isEmpty) {
      return textFieldMsgs['required'];
    }
    return null;
  }

  Future<Null> _handleSignIn() async {
    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);

      Fluttertoast.showToast(
          msg: loginMsgs['success'], backgroundColor: themeColor);
      this.setState(() {
        isLoading = false;
      });
      // print('ログイン成功!!!!!!');

      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: userCredential.user.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;

      // Write data to local
      await prefs.setString('id', documents[0].data()['id']);
      await prefs.setString('nickname', documents[0].data()['nickname']);
      await prefs.setString('photoUrl', documents[0].data()['photoUrl']);
      await prefs.setString('aboutMe', documents[0].data()['aboutMe']);

      Fluttertoast.showToast(
          msg: loginMsgs['success'], backgroundColor: themeColor);
      this.setState(() {
        isLoading = false;
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(currentUserId: userCredential.user.uid)));
      return null;
    } on FirebaseAuthException catch (e) {
      // print(e.toString());
      print(loginMsgs[e.code]);
      Fluttertoast.showToast(
          msg: loginMsgs[e.code], backgroundColor: themeColor);
      this.setState(() {
        isLoading = false;
      });
      return null;
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(
          msg: loginMsgs['other'], backgroundColor: themeColor);
      this.setState(() {
        isLoading = false;
      });
      // print('ログイン失敗!!!!!!');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: ListView(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (String value) => isEmptyValidator(value),
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (String value) => isEmptyValidator(value),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: MaterialButton(
                child: const Text('Log in'),
                minWidth: 200,
                color: themeColor,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    _handleSignIn();
                  }
                },
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: MaterialButton(
                child: const Text('Sign up'),
                minWidth: 200,
                textColor: themeColor,
                shape: OutlineInputBorder(
                  borderSide: BorderSide(color: themeColor),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignUpScreen(title: 'echo')));
                },
              ),
            ),
            // Loading
            Positioned(
              child: isLoading ? const Loading() : Container(),
            ),
          ],
        ));
  }
}
