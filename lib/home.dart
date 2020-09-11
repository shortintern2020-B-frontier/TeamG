import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hikomaryu/chat_list.dart';
import 'package:hikomaryu/timeline.dart';
import 'package:hikomaryu/const.dart';
import 'package:hikomaryu/settings.dart';
import 'package:hikomaryu/search.dart';
import 'package:hikomaryu/widget/loading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  HomeScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => HomeScreenState(currentUserId: currentUserId);
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState({Key key, @required this.currentUserId});

  final String currentUserId;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool isLoading = false;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'ログアウト', icon: Icons.exit_to_app),
  ];
  List<String> titles = ['友達を探す', 'トークルーム', 'Timeline', 'アカウント'];

  PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    // 通知機能を実装する際に必要となるので残しておく。
    // registerNotification();
    // configLocalNotification();
    _pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  // void registerNotification() {
  //   firebaseMessaging.requestNotificationPermissions();

  //   firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
  //     print('onMessage: $message');
  //     Platform.isAndroid
  //         ? showNotification(message['notification'])
  //         : showNotification(message['aps']['alert']);
  //     return;
  //   }, onResume: (Map<String, dynamic> message) {
  //     print('onResume: $message');
  //     return;
  //   }, onLaunch: (Map<String, dynamic> message) {
  //     print('onLaunch: $message');
  //     return;
  //   });

  //   firebaseMessaging.getToken().then((token) {
  //     print('token: $token');
  //     FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(currentUserId)
  //         .update({'pushToken': token});
  //   }).catchError((err) {
  //     Fluttertoast.showToast(
  //         msg: err.message.toString(), backgroundColor: Colors.red);
  //   });
  // }

  // void configLocalNotification() {
  //   var initializationSettingsAndroid =
  //       new AndroidInitializationSettings('app_icon');
  //   var initializationSettingsIOS = new IOSInitializationSettings();
  //   var initializationSettings = new InitializationSettings(
  //       initializationSettingsAndroid, initializationSettingsIOS);
  //   flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // }

  // void showNotification(message) async {
  //   var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
  //     'com.hikomaryu.echo',
  //     'Flutter chat demo',
  //     'your channel description',
  //     playSound: true,
  //     enableVibration: true,
  //     importance: Importance.Max,
  //     priority: Priority.High,
  //   );
  //   var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  //   var platformChannelSpecifics = new NotificationDetails(
  //       androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  //   await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
  //       message['body'].toString(), platformChannelSpecifics,
  //       payload: json.encode(message));
  // }

  void onItemMenuPress(Choice choice) {
    if (choice.title == 'ログアウト') {
      handleSignOut();
    }
  }

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: primaryColor),
        shape: UnderlineInputBorder(borderSide: BorderSide(color: themeColor)),
        title: Text(
          titles[_page],
          style: TextStyle(color: themeColor, fontSize: 23, letterSpacing: 2.0,
              // fontWeight: FontWeight.bold,
              shadows: <Shadow>[
                Shadow(
                    offset: Offset(0, 2.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(125, 0, 0, 0))
              ]),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          color: primaryColor,
                        ),
                        Container(
                          width: 10.0,
                        ),
                        Text(
                          choice.title,
                          style: TextStyle(color: primaryColor),
                        ),
                      ],
                    ));
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            // List
            Container(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                    );
                  } else {
                    return new PageView(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          this._page = page;
                        });
                      },
                      children: [
                        new SearchScreen(
                            currentUserId: currentUserId,
                            university: snapshot.data.docs
                                .firstWhere((doc) => doc.id == currentUserId)
                                .data()["university"]),
                        new ChatList(
                            currentUserId: currentUserId, snapshot: snapshot),
                        new Timeline(currentUserId: currentUserId),
                        new ChatSettings(
                            currentUserId: currentUserId, isMyProfile: true),
                      ],
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('探す'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            title: Text('トーク'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            title: Text('タイムライン'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            title: Text('アカウント'),
          ),
        ],
        currentIndex: _page,
        selectedItemColor: Colors.red[800],
        unselectedItemColor: Colors.red[100],
        onTap: (int page) {
          _pageController.animateToPage(page,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        },
      ),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}
