import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';

import '../api.dart';
import '../chat.dart';
import '../const.dart';
import 'nothing_display.dart';

class ClassesSearchScreen extends StatefulWidget {
  static final navKey = new GlobalKey<NavigatorState>();
  final String currentUserId;
  final String university;

  ClassesSearchScreen(
      {Key key, @required this.currentUserId, @required this.university})
      : super(key: key);

  @override
  ClassesSearchScreenState createState() => ClassesSearchScreenState();
}

class ClassesSearchScreenState extends State<ClassesSearchScreen> {
  StreamController<List<DropdownMenuItem<String>>> _universityEvents;
  StreamController<List<DropdownMenuItem<String>>> _facultyEvents;
  StreamController<List<DropdownMenuItem<String>>> _departmentEvents;

  final _formKey = GlobalKey<FormState>();
  String inputString = '';
  TextFormField input;

  List<int> lessonSelectedItems = [];
  List<String> stringLessonSelectedItems = [];
  List<DropdownMenuItem<String>> _dummyItems = [];
  List<DropdownMenuItem<String>> _lessonItems = [];

  @override
  void initState() {
    _dummyItems = makeDropdowmMenuFromStringList(['']);

    _universityEvents = StreamController<List<DropdownMenuItem<String>>>();
    _facultyEvents = StreamController<List<DropdownMenuItem<String>>>();
    _departmentEvents = StreamController<List<DropdownMenuItem<String>>>();

    getDataFromFireStore(_universityEvents, apiMode.university);
    _facultyEvents.add(_dummyItems);
    _departmentEvents.add(_dummyItems);

    super.initState();
  }

  bool checkDummyMenu(List<DropdownMenuItem<String>> snapshotData) {
    if (snapshotData.length == 1 && snapshotData[0].value.length == 0)
      return true;
    return false;
  }

  String makeUserBelongs(DocumentSnapshot document) {
    String userBelongs = '';
    if (document.data()['university'] != null) {
      userBelongs += document.data()['university'];
    }
    if (document.data()['faculty'] != null) {
      userBelongs += document.data()['faculty'];
    }
    if (document.data()['department'] != null) {
      userBelongs += document.data()['department'];
    }
    if (document.data()['grade'] != null) {
      userBelongs += '   ' + document.data()['grade'].toString() + '年';
    }
    return userBelongs;
  }

  Widget buildLabel(String textValue) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Text(textValue),
      decoration: BoxDecoration(
        color: greyColor2,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget buildListItem(BuildContext context, DocumentSnapshot document) {
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
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
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
                alignment: Alignment.centerLeft,
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
                      child: Text(
                        makeUserBelongs(document),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(left: 20.0),
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Chat(peerDoc: document)));
        },
        color: greyColor2,
        padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
    );
  }

  addItemDialog() async {
    return await showDialog(
      context: ClassesSearchScreen.navKey.currentState.overlay.context,
      builder: (BuildContext alertContext) {
        return (AlertDialog(
          title: Text('授業を追加'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                input,
                FlatButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        _lessonItems.add(DropdownMenuItem(
                          child: Text(inputString),
                          value: inputString,
                        ));
                        if (_lessonItems.length == 0)
                          _lessonItems = _dummyItems;
                      });
                      Navigator.pop(alertContext, inputString);
                    }
                  },
                  child: Text('Ok'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(alertContext, null);
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ),
        ));
      },
    );
  }

  Widget buildMultiMenu() {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('classes')
            .orderBy(FieldPath.documentId)
            .startAt([widget.university]).endAt(
                [widget.university + '\uf8ff']).get(),
        builder: (context, lessonSnapshot) {
          if (!lessonSnapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          }

          _lessonItems = [];
          lessonSnapshot.data.docs.forEach((document) {
            String lesson = document.id.split('-')[1];
            _lessonItems
                .add(DropdownMenuItem(child: Text(lesson), value: lesson));
          });
          if (_lessonItems.length == 0) _lessonItems = _dummyItems;
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: AbsorbPointer(
              absorbing: checkDummyMenu(_lessonItems),
              child: SearchChoices.multiple(
                items: _lessonItems,
                selectedItems: lessonSelectedItems,
                hint: checkDummyMenu(_lessonItems) ? '選択できません' : '選択してください',
                searchHint: '選択してください',
                disabledHint: (Function updateParent) {
                  return (FlatButton(
                    onPressed: () {
                      addItemDialog().then((value) async {
                        if (value != null) {
                          lessonSelectedItems = [0];
                          updateParent(lessonSelectedItems);
                        }
                      });
                    },
                    child: Text('選択してください'),
                  ));
                },
                onChanged: (values) {
                  setState(() {
                    if (!(values is NotGiven)) {
                      lessonSelectedItems = values;
                      stringLessonSelectedItems = [];
                      for (int i in lessonSelectedItems) {
                        stringLessonSelectedItems.add(_lessonItems[i].value);
                      }
                    }
                  });
                },
                displayItem: (item, selected, Function updateParent) {
                  return (Row(children: <Widget>[
                    selected
                        ? Icon(
                            Icons.check_box,
                            color: Colors.black,
                          )
                        : Icon(
                            Icons.check_box_outline_blank,
                            color: Colors.black,
                          ),
                    SizedBox(width: 7),
                    Expanded(
                      child: item,
                    ),
                  ]));
                },
                dialogBox: true,
                isExpanded: true,
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildLabel('授業名'),
                Flexible(child: buildMultiMenu()),
              ],
            ),
          ),
          Divider(color: Colors.black),
          Expanded(
            child: FutureBuilder(
                future: getUsersClassesFromFireStore(widget.currentUserId,
                    widget.university, stringLessonSelectedItems),
                builder: (BuildContext context, snapshot) {
                  return checkDummyMenu(_lessonItems)
                      ? CannotSelect()
                      : (snapshot.data == null
                          ? NothingDisplay()
                          : ListView.builder(
                              padding: EdgeInsets.all(10.0),
                              itemBuilder: (context, index) => buildListItem(
                                  context, snapshot.data.documents[index]),
                              itemCount: snapshot.data.documents.length,
                            ));
                }),
          ),
        ],
      ),
    );
  }
}
