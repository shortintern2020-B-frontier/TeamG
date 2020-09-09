import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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
