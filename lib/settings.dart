import 'dart:async';

// not foundのエラーが出たためコメントアウト
//import 'dart:html';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hikomaryu/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

List cardList = [['Affiliation', '所属'], ['Grade', '学年'], ['Residence', '居住地'], ['circle', 'サークル']];

class ChatSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'プロフィール',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController controllerNickname;
  TextEditingController controllerAffiliation;
  TextEditingController controllerGrade;
  TextEditingController controllerResidence;
  TextEditingController controllerCircle;
  List<TextEditingController> controllerList = new List(cardList.length);

  SharedPreferences prefs;

  String id = '';
  String nickname = '';

  List<String> categoryList = new List(cardList.length);
  String affiliation = '';
  String grade = '';
  String residence = '';
  String circle = '';

  String photoUrl = '';
  bool isMyProfile = true;

  bool isLoading = false;
  File avatarImageFile;

  final FocusNode focusNodeNickname = FocusNode();
  List<FocusNode> focusNodeList = new List.generate(cardList.length, (i) => FocusNode());
  final FocusNode focusNodeAffiliation = FocusNode();
  final FocusNode focusNodeGrade = FocusNode();
  final FocusNode focusNodeResidence = FocusNode();
  final FocusNode focusNodeCircle = FocusNode();

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    nickname = prefs.getString('nickname') ?? '';
    for (int i = 0; i < cardList.length; i++) {
      categoryList[i] = prefs.getString(cardList[i][0].toLowerCase()) ?? '';
    }
    photoUrl = prefs.getString('photoUrl') ?? '';

    controllerNickname = TextEditingController(text: nickname);
    for (int i = 0; i < cardList.length; i++) {
      controllerList[i] = TextEditingController(text: categoryList[i]);
    }

    // Force refresh input
    setState(() {});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

    File image = File(pickedFile.path);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = id;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
   
          FirebaseFirestore.instance.collection('users').doc(id).update({
            'photoUrl': photoUrl
          }).then((data) async {
            await prefs.setString('photoUrl', photoUrl);
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Upload success");
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: err.toString());
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'This file is not an image');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void handleUpdateData() {
    focusNodeNickname.unfocus();
    for (int i = 0; i < focusNodeList.length; i++) {
      print(i);
      print(focusNodeList[i]);
      print(focusNodeAffiliation);
      focusNodeList[i].unfocus();
    }
    setState(() {
      isLoading = true;
    });


    List<Future<void>> futureList = [];
    for (int i = 0; i < cardList.length; i++) {
      futureList.add(FirebaseFirestore.instance.collection('users').doc(id).update({cardList[i][0].toLowerCase(): categoryList[i]}));
    }
    var futureWait = Future.wait(futureList).then((content) async {
      for (int i = 0;i < categoryList.length; i++) {
        await prefs.setString(cardList[i][0].toLowerCase(), categoryList[i]);
      }
    });

    FirebaseFirestore.instance.collection('users').doc(id).update({
      'nickname': nickname,
      'photoUrl': photoUrl
    }).then((data) async {
      await prefs.setString('nickname', nickname);
      await prefs.setString('photoUrl', photoUrl);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Update success");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }

  Widget makeBasicInfomationCard(
      BuildContext context,
      int categoryIdx,
      String displayName)
  {
    print(categoryList[categoryIdx]);
    return Padding(
      padding: EdgeInsets.only(top: 15, bottom: 15),
      child: Card(
        color: orangeColor,
        child: Row(
          children: <Widget>[
            Container(
              child: Text(
                displayName,
                style: TextStyle(fontSize: 23),
              ),
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
            ),
            Theme(
              data: Theme.of(context).copyWith(primaryColor: primaryColor),
              child: Flexible(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Sweetie',
                    contentPadding: EdgeInsets.all(5.0),
                    hintStyle: TextStyle(color: greyColor),
                  ),
                  controller: controllerList[categoryIdx],
                  onChanged: (value) {
                      categoryList[categoryIdx] = value;
                  },
                  focusNode: focusNodeList[categoryIdx],
                ),
              ),
            ),
          ],
        ),
        margin: EdgeInsets.only(left: 30.0, right: 30.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isMyProfile) {
      return Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Avatar
                    Container(
                      child: Stack(
                        children: <Widget>[
                          (avatarImageFile == null)
                              ? (photoUrl != ''
                              ? Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) =>
                                  Container(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          themeColor),
                                    ),
                                    width: 90.0,
                                    height: 90.0,
                                    padding: EdgeInsets.all(20.0),
                                  ),
                              imageUrl: photoUrl,
                              width: 90.0,
                              height: 90.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                            BorderRadius.all(Radius.circular(45.0)),
                            clipBehavior: Clip.hardEdge,
                          )
                              : Icon(
                            Icons.account_circle,
                            size: 90.0,
                            color: greyColor,
                          ))
                              : Material(
                            child: Image.file(
                              avatarImageFile,
                              width: 90.0,
                              height: 90.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                            BorderRadius.all(Radius.circular(45.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                        ],
                      ),
                      width: 90,
                      margin: EdgeInsets.all(20.0),
                    ),
                    Container(
                      child: Text(
                        nickname,
                        style: TextStyle(fontSize: 23),
                      ),
                      width: 200,
                      margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    ),
                  ],
                ),

                // Input
                Column(
                  children: <Widget>[
                    // 基本情報
                    Container(
                      child: Text(
                        '基本情報',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: primaryColor),
                      ),
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(
                          left: 10.0, bottom: 5.0, top: 10.0),
                    ),
                    // 所属
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Container(
                      height: 45,
                      child: Card(
                        color: orangeColor,

                        child: Row(
                          children: <Widget>[
                            Container(
                            child: Text(
                              '所属',
                              style: TextStyle(fontSize: 23),
                              ),
                              margin: EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Text(
                                affiliation,
                                style: TextStyle(fontSize: 17),
                                ),
                            ],
                          ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ),
                    ),
                    // 学年
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Container(
                      height: 45,
                      child: Card(
                        color: orangeColor,

                        child: Row(
                          children: <Widget>[
                            Container(
                            child: Text(
                              '学年',
                              style: TextStyle(fontSize: 23),
                              ),
                              margin: EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Text(
                                grade,
                                style: TextStyle(fontSize: 17),
                                ),
                            ],
                          ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ),
                    ),

                    // 居住地
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Container(
                      height: 45,
                      child: Card(
                        color: orangeColor,

                        child: Row(
                          children: <Widget>[
                            Container(
                            child: Text(
                              '居住地',
                              style: TextStyle(fontSize: 23),
                              ),
                              margin: EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Text(
                                residence,
                                style: TextStyle(fontSize: 17),
                                ),
                            ],
                          ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ),
                    ),

                    // サークル
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Container(
                      height: 45,
                      child: Card(
                        color: orangeColor,

                        child: Row(
                          children: <Widget>[
                            Container(
                            child: Text(
                              'サークル',
                              style: TextStyle(fontSize: 23),
                              ),
                              margin: EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Text(
                                circle,
                                style: TextStyle(fontSize: 17),
                                ),
                            ],
                          ),
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
          ),
        ],
      );
    } else {
      return Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Avatar
                    Container(
                      child: Stack(
                        children: <Widget>[
                          (avatarImageFile == null)
                              ? (photoUrl != ''
                              ? Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) =>
                                  Container(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          themeColor),
                                    ),
                                    width: 90.0,
                                    height: 90.0,
                                    padding: EdgeInsets.all(20.0),
                                  ),
                              imageUrl: photoUrl,
                              width: 90.0,
                              height: 90.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                            BorderRadius.all(Radius.circular(45.0)),
                            clipBehavior: Clip.hardEdge,
                          )
                              : Icon(
                            Icons.account_circle,
                            size: 90.0,
                            color: greyColor,
                          ))
                              : Material(
                            child: Image.file(
                              avatarImageFile,
                              width: 90.0,
                              height: 90.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                            BorderRadius.all(Radius.circular(45.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: primaryColor.withOpacity(0.5),
                            ),
                            onPressed: getImage,
                            padding: EdgeInsets.all(30.0),
                            splashColor: Colors.transparent,
                            highlightColor: greyColor,
                            iconSize: 30.0,
                          ),
                        ],
                      ),
                      width: 90,
                      margin: EdgeInsets.all(20.0),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(primaryColor: primaryColor),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Sweetie',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: greyColor),
                          ),
                          controller: controllerNickname,
                          onChanged: (value) {
                            nickname = value;
                          },
                          focusNode: focusNodeNickname,
                        ),
                      ),
                      width: 200,
                      margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    ),
                  ],
                ),

                // Input
                Column(
                  children: <Widget>[
                    // 基本情報
                    Container(
                      child: Text(
                        '基本情報',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: primaryColor),
                      ),
                      margin: EdgeInsets.only(
                          left: 10.0, bottom: 5.0, top: 10.0),
                    ),

                    for (int i = 0; i < cardList.length; i++) {
                      makeBasicInfomationCard(context, i, cardList[i][1]),
                    }


                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),

                // Button
                Container(
                  child: FlatButton(
                    onPressed: handleUpdateData,
                    child: Text(
                      'UPDATE',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    color: primaryColor,
                    highlightColor: Color(0xff8d93a0),
                    splashColor: Colors.transparent,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                  ),
                  margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
                ),
              ],
            ),
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
          ),

          // Loading
          Positioned(
            child: isLoading
                ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
                : Container(),
          ),
        ],
      );
    }
  }
}
