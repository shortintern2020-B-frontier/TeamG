import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';
import 'package:hikomaryu/settings.dart';

import 'api.dart';
import 'chat.dart';
import 'const.dart';
import 'widget/search_classes.dart';
import 'widget/search_ufd.dart';

class TabInfo {
  String label;
  Widget widget;
  TabInfo(this.label, this.widget);
}

class SearchScreen extends StatelessWidget {
  static final navKey = new GlobalKey<NavigatorState>();
  final String currentUserId;
  final String university;

  SearchScreen(
      {Key key, @required this.currentUserId, @required this.university})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, Widget> _tabs = {
      "大学・学部・学科検索":
          UdfSearchScreen(currentUserId: currentUserId, university: university),
      "授業検索": ClassesSearchScreen(
          currentUserId: currentUserId, university: university),
    };
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: greyColor2,
            child: Center(
              child: TabBar(
                indicatorColor: themeColor,
                tabs: _tabs.keys
                    .map((k) => Tab(
                          child: Text(
                            k,
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.black,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
        body: TabBarView(children: _tabs.values.map((v) => v).toList()),
      ),
    );
  }
}
