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
      if (res.statusCode == 200) {
        var jsRes = convert.jsonDecode(res.body);
        jsRes['results']['school'][0]['faculty']
            .forEach((item) => list.add(item['name']));
      }
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
  List<DropdownMenuItem<String>> menu = makeDropdowmMenuFromStringList(list);
  events.add(menu);
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

// 大学一覧はこの関数でfirebaseから取得する
void getUniversitiesFireStore(
    StreamController<List<DropdownMenuItem<String>>> events) async {
  List<String> universitesList = [];
  QuerySnapshot universitySnapShot =
      await FirebaseFirestore.instance.collection("users").get();
  universitySnapShot.docs.forEach((doc) {
    if (!universitesList.contains(doc.data()["university"]) &&
        doc.data()["university"] != null) {
      universitesList.add(doc.data()["university"]);
    }
  });
  events.add(makeDropdowmMenuFromStringList(universitesList));
}

// 学科一覧はこの関数でfirebaseから取得する
void getFacultyFireStore(
    StreamController<List<DropdownMenuItem<String>>> events,
    String universityName) async {
  print("wwww");
  List<String> facultiesList = [];
  print(universityName);
  await FirebaseFirestore.instance
      .collection("users")
      .where("university", isEqualTo: universityName)
      .get()
      .then((contents) {
    print(contents);
    contents.docs.forEach((doc) {
      if (!facultiesList.contains(doc.data()["university"]) &&
          doc.data()["faculty"] != null) facultiesList.add(doc.data()["faculty"]);
    });
  });
  print(facultiesList);
  events.add(makeDropdowmMenuFromStringList(facultiesList));
}

// この関数は一旦放置
Future<QuerySnapshot> getUsersFireStore(selectUni, selectFac) async {
  if (selectFac == null) {
    QuerySnapshot userSnapShot = await FirebaseFirestore.instance
        .collection("users")
        .where("university", isEqualTo: selectUni)
        .get();
    return userSnapShot;
  } else {
    QuerySnapshot userSnapShot = await FirebaseFirestore.instance
        .collection("users")
        .where("university", isEqualTo: selectUni)
        .where("faculty", isEqualTo: selectFac)
        .get();
    return userSnapShot;
  }
}
