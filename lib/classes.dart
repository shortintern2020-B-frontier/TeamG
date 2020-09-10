import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hikomaryu/const.dart';
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
        title: Text(
          '授業登録',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
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
  bool asTabs = false;

  List<DropdownMenuItem> lessonItems = [];
  // List<DropdownMenuItem> lessonItems = [
  //   DropdownMenuItem(child: Text('経済学'), value: '経済学'),
  //   DropdownMenuItem(child: Text('マクロ経済学'), value: 'マクロ経済学'),
  //   DropdownMenuItem(child: Text('線形代数'), value: '線形代数'),
  //   DropdownMenuItem(child: Text('複素関数'), value: '複素関数'),
  //   DropdownMenuItem(child: Text('熱力学'), value: '熱力学'),
  //   DropdownMenuItem(child: Text('プログラミング工学'), value: 'プログラミング工学'),
  //   DropdownMenuItem(child: Text('English1'), value: 'English1'),
  // ];

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
    super.initState();

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

    loadClasses();
  }

  void loadClasses() async {
    // await FirebaseFirestore.instance
    //     .collection('classes')
    //     .orderBy(FieldPath.documentId)
    //     .startAt([university])
    //     .endAt([university + '\uf8ff'])
    //     .get()
    //     .then((value) => {
    //           value.docs.forEach((document) {
    //             String lesson = document.id.split('-')[1];
    //             lessonItems
    //                 .add(DropdownMenuItem(child: Text(lesson), value: lesson));
    //           })
    //         });
    // await FirebaseFirestore.instance.collection('users').doc(currentUserId).get().then((value) => {
    //   lessonSelectedItems =
    // });
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
        hint: "授業を選択してください",
        searchHint: "授業を選択してください",
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
            child: Text("授業を選択してください"),
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
                  },
                  child: Text("授業を追加"),
                ));
        },
        onChanged: (values) {
          setState(() {
            if (!(values is NotGiven)) {
              lessonSelectedItems = values;
            }
          });
          values.forEach((int index) {
            setState(() {
              lessonSelectedItems = values;

              DocumentReference lesson = FirebaseFirestore.instance
                  .collection('classes')
                  .doc("$university-${lessonItems[index].value}");
              lesson.get().then((snapshot) => {
                    if (snapshot.data() == null)
                      {
                        lesson.set({
                          'uids': FieldValue.arrayUnion([currentUserId])
                        })
                      }
                    else
                      {
                        lesson.update({
                          'uids': FieldValue.arrayUnion([currentUserId])
                        })
                      }
                  });
            });
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
      )
    };
  }

  @override
  Widget build(BuildContext context) {
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

          Map<String, Widget> widgets = getWidgets();
          return asTabs
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
                                              padding:
                                                  const EdgeInsets.all(20.0),
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
                );
        });
  }
}
