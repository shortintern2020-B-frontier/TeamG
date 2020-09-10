import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'const.dart';

List<DropdownMenuItem<String>> makeDropdowmMenuFromStringList(
    List<String> list) {
  List<DropdownMenuItem<String>> menu = [];
  for (String item in list) {
    menu.add(DropdownMenuItem<String>(
      child: Text(item),
      value: item,
    ));
  }
  return menu;
}

Future<List<String>> getList(
    apiMode mode, String prefCd, String university, String faculty) async {
  String url =
      baseApiUrl + '&pref_cd=$prefCd&name=$university&faculty=$faculty';
  List<String> list = [];
  var res = await http.get(url);
  if (res.statusCode == 200) {
    var jsRes = convert.jsonDecode(res.body);
    if (mode == apiMode.university) {
      var jsRes = convert.jsonDecode(res.body);
      jsRes['results']['school'].forEach((item) => list.add(item['name']));
    } else if (mode == apiMode.faculty) {
      var jsRes = convert.jsonDecode(res.body);
      jsRes['results']['school'][0]['faculty']
          .forEach((item) => list.add(item['name']));
    } else if (mode == apiMode.department) {
      jsRes['results']['school'][0]['faculty'].forEach((item) {
        if (item['name'] == faculty) {
          list = item['department'].cast<String>() as List<String>;
        }
      });
    }
  }
  return list;
}

void makeDropdownMenu(StreamController<List<DropdownMenuItem<String>>> events,
    apiMode mode, String prefecture,
    [String university = '', String faculty = '']) async {
  List<String> list =
      await getList(mode, prefectures[prefecture], university, faculty);
  events.add(makeDropdowmMenuFromStringList(list));
}

// この関数は一旦放置
// Future<void> getClassesFireStore() async {
//   QuerySnapshot classSnapShot =
//       await FirebaseFirestore.instance.collection("classes").get();
//   for (var i = 0; i < classSnapShot.docs.length; i++) {
//     if (!classesList.contains(classSnapShot.docs[i].data()["class"]))
//       classesList.add(classSnapShot.docs[i].data()["class"]);
//   }
//   return classesList;
// }

void getUserUniversityAndClasses(String userId, String uni,
    List<DropdownMenuItem<String>> classesList) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .get()
      .then((doc) {
    uni = doc.data()["university"];
    // print('getUserUniversityAndClasses');
    // print(doc.data()["classes"].runtimeType);
    // print(doc.data()["classes"]);
    // print(uni);
    // print(userId);
    classesList = makeDropdowmMenuFromStringList(
        doc.data()["classes"].cast<String>() as List<String>);
  });
}

void getDataFromFireStore(
    StreamController<List<DropdownMenuItem<String>>> events, apiMode mode,
    [String universityName = '', String faculityName = '']) async {
  List<String> list = [];
  if (mode == apiMode.university) {
    await FirebaseFirestore.instance.collection("users").get().then((content) {
      content.docs.forEach((doc) {
        if (!list.contains(doc.data()["university"]) &&
            doc.data()["university"] != null) {
          list.add(doc.data()["university"]);
        }
      });
    });
  } else if (mode == apiMode.faculty) {
    await FirebaseFirestore.instance
        .collection("users")
        .where("university", isEqualTo: universityName)
        .get()
        .then((content) {
      content.docs.forEach((doc) {
        if (!list.contains(doc.data()["faculty"]) &&
            doc.data()["faculty"] != null) list.add(doc.data()["faculty"]);
      });
    });
  } else if (mode == apiMode.department) {
    await FirebaseFirestore.instance
        .collection("users")
        .where("university", isEqualTo: universityName)
        .where("faculty", isEqualTo: faculityName)
        .get()
        .then((content) {
      content.docs.forEach((doc) {
        if (!list.contains(doc.data()["department"]) &&
            doc.data()["department"] != null)
          list.add(doc.data()["department"]);
      });
    });
  }
  if (list.length == 0) list.add('');
  events.add(makeDropdowmMenuFromStringList(list));
}

Future<QuerySnapshot> getUsersClassesFromFireStore(
    String currentUserId, String university, List<String> classesList) async {
  if (classesList == null || classesList.length == 0) {
    return null;
  } else {
    List<String> userIds = [];
    await Future.forEach(classesList, (classItem) async {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc("$university-$classItem")
          .get()
          .then((content) {
        if (content.data()["uids"] != null &&
            content.data()["uids"].length != 0) {
          for (String uid in content.data()["uids"]) {
            // if (!userIds.contains(uid) && uid != currentUserId) {
            userIds.add(uid);
            // }
          }
        }
      });
    });
    // print('getUsersClassesFromFireStore');
    // print(userIds);
    if (userIds.length == 0) return null;
    QuerySnapshot userSnapShot = await FirebaseFirestore.instance
        .collection("users")
        .where('id', whereIn: userIds)
        .get();
    // print(userSnapShot);
    return userSnapShot;
  }
}

Future<QuerySnapshot> getUsersFromFireStore(
    String selectedUni, String selectedFac, String selectedDep) async {
  if (selectedUni == null && selectedFac == null && selectedDep == null) {
    return null;
  } else if (selectedFac == null && selectedDep == null) {
    QuerySnapshot userSnapShot = await FirebaseFirestore.instance
        .collection("users")
        .where("university", isEqualTo: selectedUni)
        .get();
    return userSnapShot;
  } else if (selectedDep == null) {
    QuerySnapshot userSnapShot = await FirebaseFirestore.instance
        .collection("users")
        .where("university", isEqualTo: selectedUni)
        .where("faculty", isEqualTo: selectedFac)
        .get();
    return userSnapShot;
  } else {
    QuerySnapshot userSnapShot = await FirebaseFirestore.instance
        .collection("users")
        .where("university", isEqualTo: selectedUni)
        .where("faculty", isEqualTo: selectedFac)
        .where("department", isEqualTo: selectedDep)
        .get();
    return userSnapShot;
  }
}
