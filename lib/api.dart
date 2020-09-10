import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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

<<<<<<< HEAD
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
=======
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
>>>>>>> develop
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
