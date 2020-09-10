import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';
import 'package:hikomaryu/settings.dart';

import 'api.dart';
import 'chat.dart';
import 'const.dart';

class Search extends StatefulWidget {
  static final navKey = new GlobalKey<NavigatorState>();
  Search({Key navKey, this.title}) : super(key: navKey);

  final String title;

  @override
  SearchState createState() => SearchState();
}

class SearchState extends State<Search> {
  String _selectedUniversity;
  String _selectedFaculty;
  String _selectedDepartment;

  List<DropdownMenuItem<String>> _emptyItems = [];

  StreamController<List<DropdownMenuItem<String>>> _universityEvents;
  StreamController<List<DropdownMenuItem<String>>> _facultyEvents;
  StreamController<List<DropdownMenuItem<String>>> _departmentEvents;

  @override
  void initState() {
    _emptyItems = makeDropdowmMenuFromStringList(['']);

    _universityEvents = StreamController<List<DropdownMenuItem<String>>>();
    _facultyEvents = StreamController<List<DropdownMenuItem<String>>>();
    _departmentEvents = StreamController<List<DropdownMenuItem<String>>>();

    getDataFromFireStore(_universityEvents, apiMode.university);
    _facultyEvents.add(_emptyItems);
    _departmentEvents.add(_emptyItems);

    super.initState();
  }

  bool checkDamiMenu(List<DropdownMenuItem<String>> snapshotData) {
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
      userBelongs += '   ' + document.data()["grade"].toString() + "年";
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
            InkWell(
              child: Material(
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
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => ChatSettings(currentUserId: document.data()['id'], isMyProfile: false)));
              },
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildLabel('大学名'),
              Flexible(
                child: StreamBuilder(
                    stream: _universityEvents.stream,
                    builder: (BuildContext context, snapshot) {
                      return SearchChoices.single(
                        items:
                            snapshot.data == null ? _emptyItems : snapshot.data,
                        value: _selectedUniversity,
                        hint: "選択してください",
                        searchHint: "選択してください",
                        onChanged: (value) {
                          setState(() {
                            _selectedUniversity = value;
                            _selectedFaculty = null;
                            _selectedDepartment = null;
                            if (_selectedUniversity != null)
                              getDataFromFireStore(_facultyEvents,
                                  apiMode.faculty, _selectedUniversity);
                          });
                        },
                        isExpanded: true,
                      );
                    }),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildLabel('学部名'),
              Flexible(
                child: StreamBuilder(
                    stream: _facultyEvents.stream,
                    builder: (BuildContext context, snapshot) {
                      return AbsorbPointer(
                          absorbing: _selectedUniversity == null ||
                              checkDamiMenu(snapshot.data),
                          child: SearchChoices.single(
                            items: _selectedUniversity == null
                                ? _emptyItems
                                : snapshot.data,
                            value: _selectedFaculty,
                            hint: "選択してください",
                            searchHint: "選択してください",
                            onChanged: (value) {
                              setState(() {
                                _selectedFaculty = value;
                                _selectedDepartment = null;
                                if (_selectedFaculty != null)
                                  getDataFromFireStore(
                                      _departmentEvents,
                                      apiMode.department,
                                      _selectedUniversity,
                                      _selectedFaculty);
                              });
                            },
                            isExpanded: true,
                          ));
                    }),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildLabel('学科名'),
              Flexible(
                child: StreamBuilder(
                    stream: _departmentEvents.stream,
                    builder: (BuildContext context, snapshot) {
                      return AbsorbPointer(
                          absorbing: _selectedUniversity == null ||
                              _selectedFaculty == null ||
                              checkDamiMenu(snapshot.data),
                          child: SearchChoices.single(
                            items: _selectedUniversity == null ||
                                    _selectedFaculty == null
                                ? _emptyItems
                                : snapshot.data,
                            value: _selectedDepartment,
                            hint: "選択してください",
                            searchHint: "選択してください",
                            onChanged: (value) {
                              setState(() {
                                _selectedDepartment = value;
                              });
                            },
                            isExpanded: true,
                          ));
                    }),
              )
            ],
          ),
          Expanded(
            child: FutureBuilder(
                future: getUsersFromFireStore(
                    _selectedUniversity, _selectedFaculty, _selectedDepartment),
                builder: (BuildContext context, snapshot) {
                  return snapshot.data == null
                      ? Container()
                      : ListView.builder(
                          padding: EdgeInsets.all(10.0),
                          itemBuilder: (context, index) => buildListItem(
                              context, snapshot.data.documents[index]),
                          itemCount: snapshot.data.documents.length,
                        );
                }),
          )
        ],
      ),
    );
  }
}
