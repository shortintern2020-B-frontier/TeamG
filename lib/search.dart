import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';

import 'api.dart';
import 'chat.dart';
import 'const.dart';

class Search extends StatefulWidget {
  static final navKey = new GlobalKey<NavigatorState>();
  final String currentUserId;
  Search({Key navKey, this.title, @required this.currentUserId})
      : super(key: navKey);

  final String title;

  @override
  SearchState createState() => SearchState(currentUserId: currentUserId);
}

class SearchState extends State<Search> {
  SearchState({Key navKey, @required this.currentUserId});

  final String currentUserId;
  final List<String> dropdownList = ["大学", "学部", "専攻", "学年"];
  final List<String> university = ["東京大学", "京都大学"];
  String selectedItem = "大学";
  List<String> dropdownFaculty = [];
  String _selectedUniversity;
  String _selectedFaculty;
  String _selectedDepartment;
  String selectedSearchWord = "university";
  List<String> universitesList = [];
  List<String> classesList = [];
  List<String> usersList = [];
  var userList;
  String inputString = "";
  TextFormField input;
  List<DropdownMenuItem> editableItems = [];
  final _formKey = GlobalKey<FormState>();
  bool asTabs = false;
  List<int> selectedItemsMultiDialog = [];

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

    // getUniversitiesFireStore(_universityEvents);
    getDataFromFireStore(_universityEvents, apiMode.university);
    _facultyEvents.add(_emptyItems);
    _departmentEvents.add(_emptyItems);

    super.initState();
  }

  Future handleSearch(word) async {
    userList = await FirebaseFirestore.instance.collection("users").get();
    final usersList = userList.docs.map((doc) {
      if (doc.data()[selectedSearchWord].contains(word)) {
        return doc.data();
      }
    });
    print(usersList);
  }

  List<Widget> get appBarActions {
    return ([
      Center(child: Text("Tabs:")),
      Switch(
        activeColor: Colors.white,
        value: asTabs,
        onChanged: (value) {
          setState(() {
            asTabs = value;
          });
        },
      )
    ]);
  }

  addItemDialog() async {
    return await showDialog(
      context: Search.navKey.currentState.overlay.context,
      builder: (BuildContext alertContext) {
        return (AlertDialog(
          title: Text("Add an item"),
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
                        editableItems.add(DropdownMenuItem(
                          child: Text(inputString),
                          value: inputString,
                        ));
                      });
                      Navigator.pop(alertContext, inputString);
                    }
                  },
                  child: Text("Ok"),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(alertContext, null);
                  },
                  child: Text("Cancel"),
                ),
              ],
            ),
          ),
        ));
      },
    );
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
    return FlatButton(
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
                      document.data()['university'] +
                          document.data()["faculty"] +
                          document.data()["department"] +
                          " " +
                          document.data()["grade"].toString() +
                          "年",
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildLabel('大学名'),
          StreamBuilder(
              stream: _universityEvents.stream,
              builder: (BuildContext context, snapshot) {
                return SearchChoices.single(
                  items: snapshot.data == null ? _emptyItems : snapshot.data,
                  value: _selectedUniversity,
                  hint: "選択してください",
                  searchHint: "選択してください",
                  onChanged: (value) {
                    setState(() {
                      _selectedUniversity = value;
                      getDataFromFireStore(
                          _facultyEvents, apiMode.faculty, _selectedUniversity);
                      _selectedFaculty = null;
                      _selectedDepartment = null;
                    });
                  },
                  isExpanded: true,
                );
              }),
          SizedBox(height: 20),
          buildLabel('学部名'),
          StreamBuilder(
              stream: _facultyEvents.stream,
              builder: (BuildContext context, snapshot) {
                return AbsorbPointer(
                    absorbing: _selectedUniversity == null,
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
                          getDataFromFireStore(
                              _departmentEvents,
                              apiMode.department,
                              _selectedUniversity,
                              _selectedDepartment);
                          _selectedDepartment = null;
                        });
                      },
                      isExpanded: true,
                    ));
              }),
          SizedBox(height: 20),
          buildLabel('学科名'),
          StreamBuilder(
              stream: _departmentEvents.stream,
              builder: (BuildContext context, snapshot) {
                return AbsorbPointer(
                    absorbing:
                        _selectedUniversity == null || _selectedFaculty == null,
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
