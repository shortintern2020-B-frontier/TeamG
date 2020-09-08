import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hikomaryu/comment.dart';
import 'package:hikomaryu/const.dart';

class Timeline extends StatefulWidget {
  final String currentUserId;
  final AsyncSnapshot snapshot;
  Timeline({this.currentUserId, this.snapshot});

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
      Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: document.data()['photoUrl'] != null &&
                        document.data()['photoUrl'].isNotEmpty
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(themeColor),
                          ),
                          width: 50.0,
                          height: 50.0,
                          padding: EdgeInsets.all(15.0),
                        ),
                        imageUrl: document.data()['photoUrl'],
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
                          document.data()['content'],
                          style: TextStyle(color: primaryColor, fontSize: 18),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .orderBy('created_at', descending: true)
                              .limit(1)
                              .snapshots(),
                          builder: (context, postSnapshot) {
                            if (!postSnapshot.hasData) {
                              return Center(
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          themeColor)));
                            } else {
                              return Text(
                                postSnapshot.data.documents.length == 0
                                    ? ''
                                    : postSnapshot.data.documents[0]
                                        .data()['content'],
                                style: TextStyle(color: Colors.grey[700]),
                              );
                            }
                          },
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
          //   Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => Post(
          //                 peerId: document.id,
          //                 peerAvatar: document.data()['photoUrl'],
          //               )));
          },
          color: greyColor2,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }


  @override
  Widget build(BuildContext context) {
    // return PostView.builder(
    //   padding: EdgeInsets.all(10.0),
    //   itemBuilder: (content, index) =>
    //       buildItem(content, widget.snapshot.data.documents[index]),
    //   itemCount: widget.snapshot.data.documents.length,
    // );
  }

}