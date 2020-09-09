import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hikomaryu/widget/input.dart';
import 'package:hikomaryu/timeline_detail.dart';
import 'package:hikomaryu/const.dart';

class Timeline extends StatefulWidget {
  final String currentUserId;
  Timeline({this.currentUserId});

  @override
  State<StatefulWidget> createState() {
    return TimelineState();
  }
}

class TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(document.data()['post_user_id'])
          .snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(whiteColor)));
        } else {
          return Container(
            child: FlatButton(
              child: Row(
                children: <Widget>[
                  Material(
                    child: userSnapshot.data.data()['photoUrl'] != null &&
                            userSnapshot.data.data()['photoUrl'].isNotEmpty
                        ? CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(whiteColor),
                              ),
                              width: 50.0,
                              height: 50.0,
                              padding: EdgeInsets.all(15.0),
                            ),
                            imageUrl: userSnapshot.data.data()['photoUrl'],
                            width: 50.0,
                            height: 50.0,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.account_circle,
                            size: 50.0,
                            color: greyColor,
                          ),
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  Flexible(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              userSnapshot.data.data()['nickname'],
                              style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                          ),
                          Container(
                            child: Text(
                              document.data()['content'],
                              style:
                                  TextStyle(color: primaryColor, fontSize: 18),
                            ),
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                          )
                        ],
                      ),
                      margin: EdgeInsets.only(left: 20.0),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TimelineDetail(
                              postDocument: document,
                            )));
              },
              color: whiteColor,
              padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
              shape: UnderlineInputBorder(
                  borderSide: BorderSide(color: greyColor2)),
            ),
            margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
          );
        }
      },
    );
  }

  void onSendMessage(String content, int type) {
    String date = DateTime.now().millisecondsSinceEpoch.toString();

    var documentReference =
        FirebaseFirestore.instance.collection('posts').doc(date);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        {
          'post_user_id': widget.currentUserId,
          'created_at': date,
          'content': content,
          'type': type
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, postSnapshot) {
        if (!postSnapshot.hasData) {
          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(whiteColor)));
        } else {
          return Input(
            peerId: '',
            onSendMessage: onSendMessage,
            isTimeline: true,
            listWidget: Flexible(
                child: ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (content, index) =>
                        buildItem(content, postSnapshot.data.documents[index]),
                    itemCount: postSnapshot.data.documents.length)),
          );
        }
      },
    );
  }
}
