import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';

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

void getItem(apiMode mode, Response res, String faculty, List<String> list) {
  if (res.statusCode != 200) return;

  var jsRes = convert.jsonDecode(res.body);
  if (mode == apiMode.university) {
    jsRes['results']['school'].forEach((item) => list.add(item['name']));
  } else if (mode == apiMode.faculty) {
    jsRes['results']['school'][0]['faculty']
        .forEach((item) => list.add(item['name']));
  } else if (mode == apiMode.department) {
    jsRes['results']['school'][0]['faculty'].forEach((item) {
      if (item['name'] == faculty) {
        list.addAll(item['department'].cast<String>() as List<String>);
      }
    });
  }
}

Future<List<String>> getList(
    apiMode mode, String prefCd, String university, String faculty) async {
  String url = baseApiUrl +
      '&pref_cd=$prefCd&name=$university&faculty=$faculty&count=100';
  List<String> list = [];
  Response res = await http.get(url);

  if (res.statusCode == 200) {
    var jsRes = convert.jsonDecode(res.body);
    getItem(mode, res, faculty, list);

    // 取得結果が100個以上の時に、残りを取得.
    int resultsCount = jsRes['results']['results_available'];
    resultsCount = (resultsCount / 100).ceil();

    for (var i = 1; i < resultsCount; i++) {
      String requestUrl = url + '&start=${i * 100}';
      res = await http.get(requestUrl);
      getItem(mode, res, faculty, list);
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
