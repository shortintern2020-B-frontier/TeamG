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

import './signup.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
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

  Future<Null> handleSignIn() async {
    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    // TODO - 新規登録時にフォームから取得.
    String _nickname = 'test';

    // TODO - 新規登録時にはこっちを使う。
    // User firebaseUser = (await FirebaseAuth.instance
    //         .createUserWithEmailAndPassword(email: _email, password: _password))
    //     .user;
    User firebaseUser = (await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text))
        .user;

    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.length == 0) {
        // TODO - ユーザがありませんエラーを出す
        // // Update data to server if new user
        // FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(firebaseUser.uid)
        //     .set({
        //   'nickname': _nickname,
        //   'id': firebaseUser.uid,
        //   'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        //   'photoUrl': null,
        //   'chattingWith': null
        // });

        // // Write data to local
        // currentUser = firebaseUser;
        // await prefs.setString('id', currentUser.uid);
        // await prefs.setString('nickname', _nickname);
      } else {
        // Write data to local
        await prefs.setString('id', documents[0].data()['id']);
        await prefs.setString('nickname', documents[0].data()['nickname']);
        await prefs.setString('photoUrl', documents[0].data()['photoUrl']);
        await prefs.setString('aboutMe', documents[0].data()['aboutMe']);
      }
      Fluttertoast.showToast(msg: "Sign in success");
      this.setState(() {
        isLoading = false;
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(currentUserId: firebaseUser.uid)));
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
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
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
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
                    handleSignIn();
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
