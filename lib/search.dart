import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';

import 'api.dart';
import 'chat.dart';
import 'const.dart';

class SearchScreen extends StatefulWidget {
  static final navKey = new GlobalKey<NavigatorState>();
  final String currentUserId;

  SearchScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  String _selectedUniversity;
  String _selectedFaculty;
  String _selectedDepartment;

  List<DropdownMenuItem<String>> _emptyItems = [];

  StreamController<List<DropdownMenuItem<String>>> _universityEvents;
  StreamController<List<DropdownMenuItem<String>>> _facultyEvents;
  StreamController<List<DropdownMenuItem<String>>> _departmentEvents;
  StreamController<List<DropdownMenuItem<String>>> _classesEvents;

  final _formKey = GlobalKey<FormState>();
  String inputString = "";
  TextFormField input;
  List<DropdownMenuItem<String>> _classesList = [
    // DropdownMenuItem(child: Text('経済学'), value: '経済学'),
    // DropdownMenuItem(child: Text('マクロ経済学'), value: 'マクロ経済学'),
    // DropdownMenuItem(child: Text('線形代数'), value: '線形代数'),
    // DropdownMenuItem(child: Text('複素関数'), value: '複素関数'),
    // DropdownMenuItem(child: Text('熱力学'), value: '熱力学'),
    // DropdownMenuItem(child: Text('プログラミング工学'), value: 'プログラミング工学'),
    // DropdownMenuItem(child: Text('English1'), value: 'English1'),
  ];
  List<int> _classes = [];
  String university;

  List<DropdownMenuItem> lessonItems = [];
  List<int> lessonSelectedItems = [];
  List<String> stringLessonSelectedItems = [];

  @override
  void initState() {
    _emptyItems = makeDropdowmMenuFromStringList(['']);

    _universityEvents = StreamController<List<DropdownMenuItem<String>>>();
    _facultyEvents = StreamController<List<DropdownMenuItem<String>>>();
    _departmentEvents = StreamController<List<DropdownMenuItem<String>>>();
    _classesEvents = StreamController<List<DropdownMenuItem<String>>>();

    getDataFromFireStore(_universityEvents, apiMode.university);
    _facultyEvents.add(_emptyItems);
    _departmentEvents.add(_emptyItems);

    getUserUniversityAndClasses(widget.currentUserId, university, _classesList);
    print('initState university');
    print(university); // todo:なぜかnull
    university = '大阪大学';
    _classesEvents.add(_classesList);

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
      context: SearchScreen.navKey.currentState.overlay.context,
      builder: (BuildContext alertContext) {
        return (AlertDialog(
          title: Text("授業を追加"),
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
                        lessonItems.add(DropdownMenuItem(
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

  Widget test() {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('classes')
            .orderBy(FieldPath.documentId)
            .startAt([university]).endAt([university + '\uf8ff']).get(),
        builder: (context, lessonSnapshot) {
          if (!lessonSnapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          }

          lessonItems = [];
          lessonSnapshot.data.docs.forEach((document) {
            String lesson = document.id.split('-')[1];
            lessonItems
                .add(DropdownMenuItem(child: Text(lesson), value: lesson));
          });

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: <Widget>[
                SearchChoices.multiple(
                  items: lessonItems,
                  selectedItems: lessonSelectedItems,
                  hint: "選択してください",
                  searchHint: "選択してください",
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
                      child: Text("選択してください"),
                    ));
                  },
                  onChanged: (values) {
                    setState(() {
                      if (!(values is NotGiven)) {
                        lessonSelectedItems = values;
                        print('lessonSelectedItems');
                        print(values);
                        stringLessonSelectedItems = [];
                        for (int i in lessonSelectedItems) {
                          stringLessonSelectedItems.add(lessonItems[i].value);
                        }
                        print(stringLessonSelectedItems);
                        // getUsersClassesFromFireStore(widget.currentUserId,
                        //     university, stringLessonSelectedItems);
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
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          int indexOfItem = lessonItems.indexOf(item);
                          lessonItems.removeWhere((element) => item == element);
                          lessonSelectedItems
                              .removeWhere((element) => element == indexOfItem);
                          for (int i = 0; i < lessonSelectedItems.length; i++) {
                            if (lessonSelectedItems[i] > indexOfItem) {
                              lessonSelectedItems[i]--;
                            }
                          }
                          updateParent(lessonSelectedItems);
                          setState(() {});
                        },
                      ),
                    ]));
                  },
                  dialogBox: true,
                  isExpanded: true,
                )
              ],
            ),
          );
        });
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
                              checkDummyMenu(snapshot.data),
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
                              checkDummyMenu(snapshot.data),
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
          SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildLabel('授業名'),
              Flexible(
                child: test(),
              ),
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
          ),
          Expanded(
            child: FutureBuilder(
                future: getUsersClassesFromFireStore(widget.currentUserId,
                    university, stringLessonSelectedItems),
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
          ),
        ],
      ),
    );
  }
}
