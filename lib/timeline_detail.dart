import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hikomaryu/const.dart';
import 'package:hikomaryu/widget/full_photo.dart';
import 'package:hikomaryu/widget/input.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimelineDetail extends StatelessWidget {
  final DocumentSnapshot postDocument;

  TimelineDetail({
    Key key,
    @required this.postDocument,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
<<<<<<< HEAD
          'Timeline Detail',
=======
          'タイムライン詳細',
>>>>>>> develop
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: TimelineDetailScreen(
        postDocument: postDocument,
      ),
    );
  }
}

class TimelineDetailScreen extends StatefulWidget {
  final DocumentSnapshot postDocument;

  TimelineDetailScreen({
    Key key,
    @required this.postDocument,
  }) : super(key: key);

  @override
  State createState() => TimelineDetailScreenState(
        postDocument: postDocument,
      );
}

class TimelineDetailScreenState extends State<TimelineDetailScreen> {
  TimelineDetailScreenState({Key key, @required this.postDocument});

  DocumentSnapshot postDocument;
  String postedDate;
  DocumentSnapshot postUser;

  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  final int _limitIncrement = 20;
  SharedPreferences prefs;

  File imageFile;
  String imageUrl;

  final ScrollController listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(_scrollListener);

    imageUrl = '';
    readData();
  }

  void readData() async {
    postedDate = postDocument.data()['created_at'];
    postUser = await FirebaseFirestore.instance
        .collection('users')
        .doc(postDocument.data()['post_user_id'])
        .get();
  }

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");
        _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
            listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the top");
      setState(() {
        print("reach the top");
      });
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(document.data()['post_user_id'])
          .get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
        }

        String postUserAvator = userSnapshot.data.data()['photoUrl'];
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Material(
                    child: postUserAvator != null && postUserAvator.isNotEmpty
                        ? CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(themeColor),
                              ),
                              width: 35.0,
                              height: 35.0,
                              padding: EdgeInsets.all(10.0),
                            ),
                            imageUrl: postUserAvator,
                            width: 35.0,
                            height: 35.0,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.account_circle,
                            size: 50.0,
                            color: greyColor,
                          ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(18.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(
                            userSnapshot.data.data()['nickname'],
                            style: TextStyle(color: primaryColor, fontSize: 18),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                        ),
                        document.data()['type'] == 0
                            ? Container(
                                child: Text(
                                  document.data()['content'],
                                  style: TextStyle(color: Colors.white),
                                ),
                                padding:
                                    EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                                width: 200.0,
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(8.0)),
                                margin: EdgeInsets.only(left: 10.0),
                              )
                            : document.data()['type'] == 1
                                ? Container(
                                    child: FlatButton(
                                      child: Material(
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              Container(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      themeColor),
                                            ),
                                            width: 200.0,
                                            height: 200.0,
                                            padding: EdgeInsets.all(70.0),
                                            decoration: BoxDecoration(
                                              color: greyColor2,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Material(
                                            child: Image.asset(
                                              'images/img_not_available.jpeg',
                                              width: 200.0,
                                              height: 200.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                          ),
                                          imageUrl: document.data()['content'],
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => FullPhoto(
                                                    url: document
                                                        .data()['content'])));
                                      },
                                      padding: EdgeInsets.all(0),
                                    ),
                                    margin: EdgeInsets.only(left: 10.0),
                                  )
                                : Container(
                                    child: Image.asset(
                                      'images/${document.data()['content']}.gif',
                                      width: 100.0,
                                      height: 100.0,
                                      fit: BoxFit.cover,
                                    ),
                                    margin: EdgeInsets.only(
                                        bottom: 10.0, right: 10.0),
                                  ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 20.0),
                  ),
                ],
              ),

              // Time
              Container(
                child: Text(
                  DateFormat('MM/dd HH:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(document.data()['created_at']))),
                  style: TextStyle(
                      color: greyColor,
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic),
                ),
                margin: EdgeInsets.only(left: 80.0, top: 5.0, bottom: 5.0),
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: EdgeInsets.only(bottom: 10.0),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Input(
      peerId: '',
      onSendMessage: onSendMessage,
      listWidget: buildListMessage(),
    );
  }

  void onSendMessage(String content, int type) async {
    String date = DateTime.now().millisecondsSinceEpoch.toString();

    var documentReference = FirebaseFirestore.instance
        .collection('posts')
        .doc(postedDate)
        .collection('comments')
        .doc(date);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        {
          'post_user_id': FirebaseAuth.instance.currentUser.uid,
          'created_at': date,
          'content': content,
          'type': type
        },
      );
    });
  }

  Widget buildListMessage() {
    return Flexible(
      child: postedDate == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postedDate)
                  .collection('comments')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(themeColor)));
                } else {
                  listMessage.addAll(snapshot.data.documents);
                  return Column(children: <Widget>[
                    // 投稿内容
                    Container(
                      child: Row(
                        children: <Widget>[
                          Material(
                            child: postUser.data()['photoUrl'] != null &&
                                    postUser.data()['photoUrl'].isNotEmpty
                                ? CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                whiteColor),
                                      ),
                                      width: 50.0,
                                      height: 50.0,
                                      padding: EdgeInsets.all(15.0),
                                    ),
                                    imageUrl: postUser.data()['photoUrl'],
                                    width: 50.0,
                                    height: 50.0,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.account_circle,
                                    size: 50.0,
                                    color: greyColor,
                                  ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          Flexible(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      postUser.data()['nickname'],
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    margin:
                                        EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                                  ),
                                  Container(
                                    child: Text(
                                      postDocument.data()['content'],
                                      style: TextStyle(
                                          color: primaryColor, fontSize: 18),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.fromLTRB(
                                        10.0, 0.0, 0.0, 0.0),
                                  )
                                ],
                              ),
                              margin: EdgeInsets.only(left: 20.0),
                            ),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 1,
                    ),
                    // コメント一覧
                    Flexible(
                        child: ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) =>
                          buildItem(index, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                      controller: listScrollController,
                    ))
                  ]);
                }
              },
            ),
    );
  }
}
