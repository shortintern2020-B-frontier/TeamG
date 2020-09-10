import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hikomaryu/const.dart';
import 'package:search_choices/search_choices.dart';
import 'package:flutter/material.dart';

import 'classes2.dart';

class Classes extends StatelessWidget {
  final String currentUserId;
  final String university;

  Classes(this.currentUserId, this.university);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          'Classes',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ClassesScreen(
        currentUserId: currentUserId,
        university: university,
      ),
    );
  }
}

class ClassesScreen extends StatefulWidget {
  final String currentUserId;
  final String university;
  static final navKey = new GlobalKey<NavigatorState>();

  const ClassesScreen({Key key, @required this.currentUserId, this.university})
      : super(key: key);

  @override
  State createState() =>
      ClassesScreenState(currentUserId: currentUserId, university: university);
}

class ClassesScreenState extends State<ClassesScreen> {
  bool asTabs = false;

  List<int> lessonSelectedItems = [];
  List<DropdownMenuItem> items = [];
  List<DropdownMenuItem> lessonItems = [];
  final _formKey = GlobalKey<FormState>();
  String inputString = "";
  TextFormField input;

  ClassesScreenState({Key key, @required this.currentUserId, this.university});

  final String university;
  final String currentUserId;

  final String loremIpsum =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

  @override
  void initState() {
    input = TextFormField(
      validator: (value) {
        return (value.length < 4 ? "must be at least 4 characters long" : null);
      },
      initialValue: inputString,
      onChanged: (value) {
        inputString = value;
      },
      autofocus: true,
    );
    super.initState();
  }

  addItemDialog() async {
    return await showDialog(
      context: ClassesScreen.navKey.currentState.overlay.context,
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

  @override
  Widget build(BuildContext context) {
    Map<String, Widget> widgets;
    widgets = {
      "授業を検索": SearchChoices.multiple(
        items: lessonItems,
        selectedItems: lessonSelectedItems,
        hint: "Select any",
        searchHint: "Select any",
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
            child: Text("No choice, click to add one"),
          ));
        },
        closeButton: (List<int> values, BuildContext closeContext,
            Function updateParent) {
          return (lessonItems.length >= 100
              ? "Close"
              : FlatButton(
                  onPressed: () {
                    addItemDialog().then((value) async {
                      if (value != null) {
                        int itemIndex = lessonItems
                            .indexWhere((element) => element.value == value);
                        if (itemIndex != -1) {
                          lessonSelectedItems.add(itemIndex);
                          Navigator.pop(ClassesScreen
                              .navKey.currentState.overlay.context);
                          updateParent(lessonSelectedItems);
                        }
                      }
                    });

                    // value.forEach((int index) {
                    //   setState(() {
                    //     lessonSelectedItems = value;

                    //     DocumentReference lesson = FirebaseFirestore.instance
                    //         .collection('classes')
                    //         .doc("$university-${lessonItems[index].value}");
                    //     lesson.get().then((snapshot) => {
                    //           if (snapshot.data() == null)
                    //             {
                    //               lesson.set({
                    //                 'uids':
                    //                     FieldValue.arrayUnion([currentUserId])
                    //               })
                    //             }
                    //           else
                    //             {
                    //               lesson.update({
                    //                 'uids':
                    //                     FieldValue.arrayUnion([currentUserId])
                    //               })
                    //             }
                    //         });
                    //   });
                    // });
                  },
                  child: Text("Add and select item"),
                ));
        },
        onChanged: (values) {
          setState(() {
            if (!(values is NotGiven)) {
              lessonSelectedItems = values;
            }
          });
        },
        displayItem: (item, selected, Function updateParent) {
          return (Row(children: [
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
        doneButton: "Done",
      ),
    };

    return MaterialApp(
      navigatorKey: ClassesScreen.navKey,
      home: asTabs
          ? DefaultTabController(
              length: widgets.length,
              child: Scaffold(
                body: Container(
                  padding: EdgeInsets.all(20),
                  child: TabBarView(
                    children: widgets
                        .map((k, v) {
                          return (MapEntry(
                              k,
                              SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(children: [
                                  Text(k),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  v,
                                ]),
                              )));
                        })
                        .values
                        .toList(),
                  ),
                ),
              ),
            )
          : Scaffold(
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 15.0),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 2.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                          width: 220,
                          height: 60,
                          color: orangeColor,
                          child: Center(
                            child: Text(
                              //title
                              '履修授業登録',
                              style: TextStyle(
                                color: primaryColor,
                                backgroundColor: orangeColor,
                                fontSize: 30,
                              ),
                            ),
                          )),
                    ),
                    Column(
                      children: widgets
                          .map((k, v) {
                            return (MapEntry(
                                k,
                                Center(
                                    child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: BorderSide(
                                            color: Colors.grey,
                                            width: 1.0,
                                          ),
                                        ),
                                        margin: EdgeInsets.all(20),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            children: <Widget>[
                                              Text("$k:"),
                                              v,
                                            ],
                                          ),
                                        )))));
                          })
                          .values
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
