import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';

import 'api.dart';
import 'const.dart';

class Search extends StatefulWidget {
  static final navKey = new GlobalKey<NavigatorState>();
  Search({Key navKey, this.title}) : super(key: navKey);

  final String title;

  @override
  SearchState createState() => SearchState();
}

class SearchState extends State<Search> {
  List<String> dropdownList = ["大学", "学部", "専攻", "学年"];
  String selectedItem = "大学";
  String searchWord;
  List<String> dropdownFaculty = [];
  String _selectedUniversity;
  // List<int> selectedClasses;
  String _selectedFaculty;
  List<String> selectedDepartment;
  String selectedSearchWord = "university";
  List<String> universitesList = [];
  List<String> classesList = [];
  List<String> usersList = [];
  var userList;
  // List<DropdownMenuItem> items = [];
  // List<DropdownMenuItem> classItems = [];
  String inputString = "";
  TextFormField input;
  List<DropdownMenuItem> editableItems = [];
  final _formKey = GlobalKey<FormState>();
  bool asTabs = false;
  final List<String> university = ["東京大学", "京都大学"];
  List<int> selectedItemsMultiDialog = [];

  List<DropdownMenuItem<String>> _emptyItems = [];

  StreamController<List<DropdownMenuItem<String>>> _universityEvents;
  StreamController<List<DropdownMenuItem<String>>> _facultyEvents;

  @override
  void initState() {
    _emptyItems = makeDropdowmMenuFromStringList(['']);

    _universityEvents = StreamController<List<DropdownMenuItem<String>>>();
    _facultyEvents = StreamController<List<DropdownMenuItem<String>>>();

    // _universityEvents.add(_emptyItems);
    getUniversitiesFireStore(_universityEvents);
    _facultyEvents.add(_emptyItems);

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

  void initiateSearch(String val) {
    setState(() {
      searchWord = val.toLowerCase().trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: const Text('大学名'),
            decoration: BoxDecoration(
              color: greyColor2,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          StreamBuilder(
              // future: getUniversitiesFireStore(),
              stream: _universityEvents.stream,
              builder: (BuildContext context, snapshot) {
                return SearchChoices.single(
                  items: snapshot.data,
                  value: _selectedUniversity,
                  hint: "選択してください",
                  searchHint: "選択してください",
                  onChanged: (value) {
                    setState(() {
                      _selectedUniversity = value;
                      // getFacultyFireStore(value);
                      getFacultyFireStore(_facultyEvents, _selectedUniversity);
                      // if (_selectedUniversity == null) {
                      // _facultyEvents.add(_emptyItems);
                      _selectedFaculty = null;
                      // }
                    });
                  },
                  isExpanded: true,
                );
              }),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(8),
            child: const Text('学部名'),
            decoration: BoxDecoration(
              color: greyColor2,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          StreamBuilder(
              // future: getFacultyFireStore(_selectedUniversity),
              stream: _facultyEvents.stream,
              builder: (BuildContext context, snapshot) {
                return AbsorbPointer(
                    absorbing: _selectedUniversity == null,
                    child: SearchChoices.single(
                      items: _selectedUniversity == null
                          ? _emptyItems
                          : snapshot.data,
                      // items: makeDropdowmMenuFromStringList(
                      //     snapshot.hasData ? dropdownFaculty : ['東京']),
                      value: _selectedFaculty,
                      hint: "選択してください",
                      searchHint: "選択してください",
                      onChanged: (value) {
                        setState(() {
                          _selectedFaculty = value;
                        });
                      },
                      isExpanded: true,
                    ));
              }),
          Expanded(
            child: FutureBuilder(
                // future: getUsersFireStore(_selectedUniversity, _selectedFaculty),
                future: _selectedUniversity == null || _selectedFaculty == null
                    ? null
                    : getUsersFireStore(_selectedUniversity, _selectedFaculty),
                builder: (BuildContext context, snapshot) {
                  // print('hello!!!!!');
                  // print(snapshot.data);
                  return snapshot.data == null ||
                          _selectedUniversity == null ||
                          _selectedFaculty == null
                      ? Container()
                      : ListView(
                          children: snapshot.data.docs.map<Widget>((document) {
                          // print(document.data()["university"]);
                          // print(_selectedUniversity);
                          // if (!universityList.contains(document.data()['university'])) {universityList.add(document.data()['university']);}
                          // print(universityList);
                          if (document
                                  .data()["university"]
                                  .contains(_selectedUniversity) &&
                              document
                                  .data()["faculty"]
                                  .contains(_selectedFaculty)) {
                            return ListTile(
                              title: Text(document.data()['nickname']),
                              subtitle: Text(document.data()['university'] +
                                  document.data()["faculty"] +
                                  document.data()["department"] +
                                  " " +
                                  document.data()["grade"].toString() +
                                  "年"),
                            );
                          } else if (searchWord == null) {
                            return ListTile(
                              title: Text(document.data()['nickname']),
                              subtitle: Text(document.data()['university'] +
                                  document.data()["faculty"] +
                                  document.data()["department"] +
                                  " " +
                                  document.data()["grade"].toString() +
                                  "年"),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        }).toList());
                }),
          )
        ],
      ),
    );
  }
}
