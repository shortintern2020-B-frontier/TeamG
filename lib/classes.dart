import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hikomaryu/const.dart';
import 'package:hikomaryu/widget/loading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:search_choices/search_choices.dart';

import 'main.dart';

class Classes extends StatelessWidget {
  final String currentUserId;
  final String university;
  final bool isMyProfile;
  Classes({this.currentUserId, this.university, this.isMyProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Classes',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ClassesScreen(
        currentUserId: currentUserId,
        university: university,
        isMyProfile: isMyProfile,
      ),
    );
  }
}

class ClassesScreen extends StatefulWidget {
  final String currentUserId;
  final String university;
  final bool isMyProfile;
  static final navKey = new GlobalKey<NavigatorState>();

  const ClassesScreen({Key key, @required this.currentUserId, this.university, this.isMyProfile})
      : super(key: key);

  @override
  State createState() =>
      ClassesScreenState(currentUserId: currentUserId, university: university, isMyProfile: isMyProfile);
}

class ClassesScreenState extends State<ClassesScreen> {
  TextEditingController controllerClassName; //n
  String className = '';

  bool asTabs = false;
  String selectedValueUpdateFromOutsideThePlugin;
  final _formKey = GlobalKey<FormState>();
  String inputString = "";
  TextFormField input;

  List<DropdownMenuItem> circleList = [
    DropdownMenuItem(child: Text('経済学'), value: '経済学'),
    DropdownMenuItem(child: Text('マクロ経済学'), value: 'マクロ経済学'),
    DropdownMenuItem(child: Text('線形代数'), value: '線形代数'),
    DropdownMenuItem(child: Text('熱力学'), value: '熱力学'),
    DropdownMenuItem(child: Text('プログラミング工学'), value: 'プログラミング工学'),
    DropdownMenuItem(child: Text('AcademicCmmunication'), value: 'プログラミング工学'),
  ];
  List<int> circle = [];
  static const String appTitle = "Search Choices demo";
  final String loremIpsum =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
//ここまで
  final FocusNode focusNodeClassName = FocusNode();

  ClassesScreenState({Key key, @required this.currentUserId, this.university, this.isMyProfile});

  final String university;
  final String currentUserId;
  final bool isMyProfile;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isMyProfile) {
      return Container();
    } else {
      return Container(
        child: Stack(
          children: <Widget>[
            // List
            Container(
              child: StreamBuilder(
                stream:
                FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                    );
                  } else {
                    return SingleChildScrollView(
                      child: Column(
                      children: <Widget>[
                        //ClassName
                        Text(
                          //title
                          '履修授業',
                          style: TextStyle(color: primaryColor, fontSize: 30),
                        ),
                        Row(
                          children: <Widget>[
                            // 授業名
                            Container(
                              //content1_title
                              width: 80,
                              height: 35,
                              margin: EdgeInsets.only(top: 15.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.orangeAccent[100]),
                              child: Text(
                                '授業名',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            // search_choices
                            Container(
                              width: 220,
                              child: SearchChoices.multiple(
                                items: circleList,
                                selectedItems: circle,
                                onChanged: (value) {
                                  setState(() {
                                    circle = value;
                                    FirebaseFirestore.instance
                                        .collection('classes')
                                        .doc("$university-$value")
                                        .update({
                                      'uids':
                                      FieldValue.arrayUnion([currentUserId])
                                    });
                                  });
                                },
                                dialogBox: false,
                                isExpanded: true,
                                menuConstraints:
                                BoxConstraints.tight(Size.fromHeight(350)),
                              ),
                              margin: EdgeInsets.only(left: 30.0, right: 30.0),
                            ),
                          ],
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    );
                  }
                },
              ),
            ),

            // Loading
            Positioned(
              child: isLoading ? const Loading() : Container(),
            )
          ],
        ),
      );
    }
  }
}
