import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hikomaryu/const.dart';
import 'package:hikomaryu/widget/loading.dart';
import 'package:search_choices/search_choices.dart';

class Classes extends StatelessWidget {
  final String currentUserId;
  final String university;
  final bool isMyProfile;

  Classes({this.currentUserId, this.university, this.isMyProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: primaryColor),
        shape: UnderlineInputBorder(borderSide: BorderSide(color: themeColor)),
        title: Text(
          '授業登録',
          style: TextStyle(color: themeColor, fontSize: 23, letterSpacing: 2.0,
              // fontWeight: FontWeight.bold,
              shadows: <Shadow>[
                Shadow(
                    offset: Offset(0, 2.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(125, 0, 0, 0))
              ]),
        ),
        centerTitle: true,
      ),
      body: ClassesScreen(
        currentUserId: currentUserId,
        university: university,
        isMyProfile: isMyProfile,
      ),
    );
  }
}

class ClassesScreen extends StatefulWidget {
  final String currentUserId;
  final String university;
  final bool isMyProfile;
  static final navKey = new GlobalKey<NavigatorState>();

  const ClassesScreen(
      {Key key,
      @required this.currentUserId,
      this.university,
      this.isMyProfile})
      : super(key: key);

  @override
  State createState() => ClassesScreenState(
      currentUserId: currentUserId,
      university: university,
      isMyProfile: isMyProfile);
}

class ClassesScreenState extends State<ClassesScreen> {
  List<DropdownMenuItem> lessonItems = [];
  List<int> lessonSelectedItems = [];

  final _formKey = GlobalKey<FormState>();
  String inputString = "";
  TextFormField input;

  ClassesScreenState(
      {Key key,
      @required this.currentUserId,
      this.university,
      this.isMyProfile});

  final String university;
  final String currentUserId;
  final bool isMyProfile;

  @override
  void initState() {
    input = TextFormField(
      validator: (value) {
        return (value.length == 0 ? "授業名が未入力です" : null);
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

  Map<String, Widget> getWidgets() {
    return {
      "授業を登録": SearchChoices.multiple(
        items: lessonItems,
        selectedItems: lessonSelectedItems,
        readOnly: !isMyProfile,
        displayClearIcon: false,
        hint: "授業を選択してください",
        searchHint: "授業を選択してください",
        disabledHint: (Function updateParent) {
          return isMyProfile
              ? FlatButton(
                  onPressed: () {
                    addItemDialog().then((value) async {
                      if (value != null) {
                        lessonSelectedItems = [0];
                        updateParent(lessonSelectedItems);
                      }
                    });
                  },
                  child: Text("授業を選択してください"),
                )
              : Text("授業が登録されていません");
        },
        closeButton: (List<int> values, BuildContext closeContext,
            Function updateParent) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  addItemDialog().then((value) async {
                    if (value == null) return;

                    DocumentReference lesson = FirebaseFirestore.instance
                        .collection('classes')
                        .doc("$university-$value");
                    lesson.get().then((snapshot) {
                      if (snapshot.data() == null) {
                        lesson.set({
                          'uids': FieldValue.arrayUnion([currentUserId])
                        });
                      } else {
                        lesson.update({
                          'uids': FieldValue.arrayUnion([currentUserId])
                        });
                      }
                    });

                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUserId)
                        .update({
                      'classes': FieldValue.arrayUnion([value])
                    });

                    Navigator.pop(closeContext);
                  });
                },
                child: Text("授業を追加"),
              ),
              RaisedButton(
                  onPressed: () {
                    setState(() {
                      lessonSelectedItems = values;
                    });

                    List<String> selectedLessonNames = [];
                    values.forEach((int index) {
                      selectedLessonNames.add(lessonItems[index].value);
                    });

                    lessonItems.forEach((lessonItem) {
                      DocumentReference lesson = FirebaseFirestore.instance
                          .collection('classes')
                          .doc("$university-${lessonItem.value}");

                      if (selectedLessonNames.contains(lessonItem.value)) {
                        lesson.update({
                          'uids': FieldValue.arrayUnion([currentUserId])
                        });
                      } else {
                        lesson.update({
                          'uids': FieldValue.arrayRemove([currentUserId])
                        });
                      }
                    });

                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUserId)
                        .update({'classes': selectedLessonNames});

                    Navigator.pop(closeContext);
                    setState(() {});
                  },
                  child: Text("保存"))
            ],
          );
        },
        onChanged: (values) {},
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
            // 削除はしない
            // IconButton(
            //   icon: Icon(
            //     Icons.delete,
            //     color: Colors.red,
            //   ),
            //   onPressed: () {
            //     int indexOfItem = lessonItems.indexOf(item);
            //     lessonItems.removeWhere((element) => item == element);
            //     lessonSelectedItems
            //         .removeWhere((element) => element == indexOfItem);
            //     for (int i = 0; i < lessonSelectedItems.length; i++) {
            //       if (lessonSelectedItems[i] > indexOfItem) {
            //         lessonSelectedItems[i]--;
            //       }
            //     }
            //     updateParent(lessonSelectedItems);
            //     setState(() {});
            //   },
            // ),
          ]));
        },
        dialogBox: true,
        isExpanded: true,
        doneButton: (selectedItemsDone, doneContext) {
          return FlatButton(
              onPressed: () {
                Navigator.pop(doneContext);
                setState(() {});
              },
              child: Icon(Icons.close));
        },
      )
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .orderBy(FieldPath.documentId)
            .startAt([university]).endAt([university + '\uf8ff']).snapshots(),
        builder: (context, lessonSnapshot) {
          if (!lessonSnapshot.hasData) {
            return Loading();
          }

          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUserId)
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return Loading();
                }

                lessonItems = [];
                lessonSelectedItems = [];
                var docs = lessonSnapshot.data.docs;
                for (var i = 0; i < docs.length; i++) {
                  String lesson = docs[i].id.split('-')[1];
                  lessonItems.add(
                      DropdownMenuItem(child: Text(lesson), value: lesson));
                  if (userSnapshot.data.data()['classes'].contains(lesson)) {
                    lessonSelectedItems.add(i);
                  }
                }

                Map<String, Widget> widgets = getWidgets();
                return MaterialApp(
                    navigatorKey: ClassesScreen.navKey,
                    debugShowCheckedModeBanner: false,
                    home: Scaffold(
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
                                ),
                              ),
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
                                          ),
                                        ),
                                      ),
                                    ));
                                  })
                                  .values
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ));
              });
        });
  }
}
