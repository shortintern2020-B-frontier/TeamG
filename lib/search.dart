import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';


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
  String selectedUniversity;
  List<int> selectedClasses;
  String selectedFaculty;
  List<String> selectedDepartment;
  String selectedSearchWord = "university";
  List<String> universitesList = [];
  List<String> classesList = [];
  List<String> usersList = [];
  var userList;
  List<DropdownMenuItem> items = [];
  List<DropdownMenuItem> classItems = [];
  String inputString = "";
  TextFormField input;
  List<DropdownMenuItem> editableItems = [];
  final _formKey = GlobalKey<FormState>();
  bool asTabs = false;
  final List<String> university = ["東京大学", "京都大学"];
  List<int> selectedItemsMultiDialog = [];

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

  Future<void> getUniversitiesFireStore() async {
    QuerySnapshot  universitySnapShot = await FirebaseFirestore.instance.collection("users").get();
    universitesList.removeRange(0, universitesList.length);
    universitySnapShot.docs.forEach((doc) {
      if (!universitesList.contains(doc.data()["university"]) && doc.data()["university"] != null){
        universitesList.add(doc.data()["university"]);
      }
    });
    return universitesList;
  }

  Future<void> getClassesFireStore() async {
    QuerySnapshot  classSnapShot = await FirebaseFirestore.instance.collection("classes").get();
    for (var i = 0; i < classSnapShot.docs.length; i++) {
      if (!classesList.contains(classSnapShot.docs[i].data()["class"]))
      classesList.add(classSnapShot.docs[i].data()["class"]);
    }
    return classesList;
  }

  Future<void> getFacultyFireStore(universityName) async {
    print("wwww");
    dropdownFaculty.removeRange(0, dropdownFaculty.length);

    // var resultFaculty = 
    await FirebaseFirestore.instance.collection("users").where("university", isEqualTo: universityName).get()
                              .then((contents) {
                                print(contents);
                                contents.docs.forEach((e) {
                                  dropdownFaculty.add(e.data()["faculty"]);
                                  });
                                // .then((resp) {
                                //   print(resp.docs[0].data()["name"]);
                                //   return resp.docs[0].data()["name"];
                                // });
                              });     
       print(dropdownFaculty);
    return dropdownFaculty;

    // resultFaculty.docs.forEach((e) {
    //   dropdownFaculty.add(e.data()["name"]);
    // });
  }

  Future<QuerySnapshot> getUsersFireStore(selectUni, selectFac) async {
    if (selectFac == null) {
      QuerySnapshot  userSnapShot = await FirebaseFirestore.instance.collection("users").where("university", isEqualTo: selectUni).get();
      return userSnapShot;
    } else {
      QuerySnapshot  userSnapShot = await FirebaseFirestore.instance.collection("users").where("university", isEqualTo: selectUni).where("faculty", isEqualTo: selectFac).get();
      return userSnapShot;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
                  FutureBuilder(
                    future: getUniversitiesFireStore(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        items.removeRange(0, items.length);
                        snapshot.data.forEach((uni) {                          
                            items.add(DropdownMenuItem(
                              child: Text(uni),
                              value: uni,
                            ));
                        });
                        return SearchChoices.single(
                          items: items,
                          value: selectedUniversity,
                          hint: "Select one",
                          searchHint: "Select one",
                          onChanged: (value) {
                            setState(() {
                              selectedUniversity = value;
                            });
                            getFacultyFireStore(value);
                          },
                          isExpanded: true,
                        );
                      } 
                    }
                  ),
                      FutureBuilder(
                        future: selectedUniversity != null ? getFacultyFireStore(selectedUniversity) : null,
                        builder: (context, snapshot) {
                          return DropdownButton(
                            value: selectedFaculty,
                            onChanged: (result) {
                              setState(() {
                                selectedFaculty = result;
                              });
                              print('helloworld!!!!!!!');
                              print(selectedFaculty);
                            } ,
                            selectedItemBuilder: (context) {
                              return dropdownFaculty.map((String item) {
                                return Text(
                                  item,
                                  style: TextStyle(color: Colors.black),
                                );
                              }).toList();
                            },
                            items: dropdownFaculty.map((item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item,
                                  style: item == selectedFaculty
                                    ? TextStyle(fontWeight: FontWeight.bold)
                                    : TextStyle(fontWeight: FontWeight.normal),
                                )
                              );
                            }).toList(),
                          );
                        }
                      ),
                      Expanded(child:
                      FutureBuilder(
                      // future: getUsersFireStore(selectedUniversity, selectedFaculty),
                      future: selectedUniversity == null || selectedFaculty == null ? null : getUsersFireStore(selectedUniversity, selectedFaculty) ,
                      builder: (context, snapshot) {
                        // print('hello!!!!!');
                        // print(snapshot.data);
                            return snapshot.data == null || selectedUniversity == null || selectedFaculty == null  ? 
                              Container()
                              :ListView(
                              children: snapshot.data.docs.map<Widget>((document) {
                                // print(document.data()["university"]);
                                // print(selectedUniversity);
                                // if (!universityList.contains(document.data()['university'])) {universityList.add(document.data()['university']);}
                                // print(universityList);
                                if (document.data()["university"].contains(selectedUniversity) && document.data()["faculty"].contains(selectedFaculty)) {
                                  return ListTile(
                                    title: Text(document.data()['nickname']),
                                    subtitle: Text(document.data()['university'] + document.data()["faculty"] + document.data()["department"] + " " + document.data()["grade"].toString() + "年"),
                                  );
                                } else if (searchWord == null) {
                                  return ListTile(
                                    title: Text(document.data()['nickname']),
                                    subtitle: Text(document.data()['university'] + document.data()["faculty"] + document.data()["department"] + " " + document.data()["grade"].toString() + "年"),
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              }).toList() 
                            );
                      }
                    ),)
                    // Expanded(
                    // child: 
                    // ListView.builder(
                    //   itemCount: 50,
                    //   itemBuilder: (context, index){
                    //     return Container(
                    //       height: 50,
                    //       child: Text(index.toString()),
                    //       color: Colors.red,
                    //     );
                    //   })
                    // )
                    // Expanded(child: Container())//)
        ],
      ),
    );
  }
}