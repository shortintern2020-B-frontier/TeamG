import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hikomaryu/chat.dart';
import 'package:hikomaryu/const.dart';

class ChatList extends StatefulWidget {
  final String currentUserId;
  final AsyncSnapshot snapshot;
  ChatList({this.currentUserId, this.snapshot});

  @override
  State<StatefulWidget> createState() {
    return ChatListState();
  }
}

class ChatListState extends State<ChatList> {
  @override
  void initState() {
    super.initState();
  }

  String getGroupChatId(String otherId) {
    String id = widget.currentUserId;
    if (id.hashCode <= otherId.hashCode) {
      return '$id-$otherId';
    }
    return '$otherId-$id';
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document.data()['id'] == widget.currentUserId) {
      return Container();
    } else {
      String groupChatId = getGroupChatId(document.data()['id']);
      return Container(
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
                          document.data()['nickname'],
                          style: TextStyle(color: primaryColor, fontSize: 18),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('messages')
                              .doc(groupChatId)
                              .collection(groupChatId)
                              .orderBy('timestamp', descending: true)
                              .limit(1)
                              .snapshots(),
                          builder: (context, messageSnapshot) {
                            if (!messageSnapshot.hasData) {
                              return Center(
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          themeColor)));
                            } else {
                              return Text(
                                messageSnapshot.data.documents.length == 0
                                    ? ''
                                    : messageSnapshot.data.documents[0]
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                          peerId: document.id,
                          peerAvatar: document.data()['photoUrl'],
                        )));
          },
          color: greyColor2,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(10.0),
      itemBuilder: (context, index) =>
          buildItem(context, widget.snapshot.data.documents[index]),
      itemCount: widget.snapshot.data.documents.length,
    );
  }
}
