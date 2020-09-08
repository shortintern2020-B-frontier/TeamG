import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hikomaryu/const.dart';
import 'package:hikomaryu/widget/full_photo.dart';
import 'package:hikomaryu/widget/loading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Comment extends StatelessWidget {
  final String postId;

  Comment({Key key, @required this.post})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post detail',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: PostDetail(
        postId: postId,
      ),
    );
  }
}

class PostDetail extends StatefulWidget {
  final String postId;

  ChatScreen({Key key, @required this.postId})
      : super(key: key);

  @override
  State createState() =>
      PostState(postId: postId);
}

class PostState extends State<PostDetail> {
  PostDetailState({Key key, @required this.postId});
}