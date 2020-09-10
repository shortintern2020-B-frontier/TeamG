import 'dart:async';

// not foundのエラーが出たためコメントアウト
//import 'dart:html';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:hikomaryu/chat.dart';
import 'package:search_choices/search_choices.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hikomaryu/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hikomaryu/classes.dart';

class ChatSettings extends StatelessWidget {
  final String currentUserId;
  final isMyProfile;
  ChatSettings({this.currentUserId, this.isMyProfile});

  @override
  Widget build(BuildContext context) {
    if (!isMyProfile) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          shape:
              UnderlineInputBorder(borderSide: BorderSide(color: themeColor)),
          title: Text(
            'プロフィール',
            style: TextStyle(color: themeColor, fontSize: 23,
                // fontWeight: FontWeight.bold,
                shadows: <Shadow>[
                  Shadow(
                      offset: Offset(0, 2.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(125, 0, 0, 0))
                ]),
          ),
          centerTitle: true,
        ),
        body: SettingsScreen(
            currentUserId: currentUserId, isMyProfile: isMyProfile),
      );
    } else {
      return Scaffold(
        body: SettingsScreen(
            currentUserId: currentUserId, isMyProfile: isMyProfile),
      );
    }
  }
}

class SettingsScreen extends StatefulWidget {
  final String currentUserId;
  final bool isMyProfile;
  SettingsScreen({this.currentUserId, this.isMyProfile});

  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController controllerNickname;
  // TextEditingController controllerAffiliation;
  TextEditingController controllerGrade;
  TextEditingController controllerAge;
  TextEditingController controllerResidence;
  TextEditingController controllerBirthplace;
  //TextEditingController controllerCircle;

  SharedPreferences prefs;

  String nickname = '';
  String university = '';
  String faculty = '';
  String department = '';
  String grade = '';
  String age = '';
  String residence = '';
  String birthplace = '';
  List<int> circle = [];
  List<int> travel = [];
  List<int> gourmet = [];
  List<int> sport = [];
  List<int> music = [];
  List<int> hobby = [];
  String photoUrl = '';
  // List<String> selectedItems = [];

  bool isLoading = false;
  File avatarImageFile;

  final FocusNode focusNodeNickname = FocusNode();
  // final FocusNode focusNodeAffiliation = FocusNode();
  final FocusNode focusNodeGrade = FocusNode();
  final FocusNode focusNodeAge = FocusNode();
  final FocusNode focusNodeResidence = FocusNode();
  final FocusNode focusNodeBirthplace = FocusNode();
  //final FocusNode focusNodeCircle = FocusNode();
  final FocusNode focusNodeTravel = FocusNode();
  final FocusNode focusNodeGrourmet = FocusNode();
  final FocusNode focusNodeSport = FocusNode();
  final FocusNode focusNodeMusic = FocusNode();
  final FocusNode focusNodeHobby = FocusNode();

  @override
  void initState() {
    super.initState();
    readLocal();
    readSetting();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    /*
    age = prefs.getString('age');
    residence = prefs.getString('residence');
    birthplace = prefs.getString('birthplace');
    // circle = conv_to_intList(prefs.getStringList('circle'));
    */
    controllerNickname = TextEditingController(text: nickname);
    // controllerAffiliation = TextEditingController(text: affiliation);
    controllerGrade = TextEditingController(text: grade);
    controllerAge = TextEditingController(text: age);
    controllerResidence = TextEditingController(text: residence);
    controllerBirthplace = TextEditingController(text: birthplace);
    //controllerCircle = TextEditingController(list: circle);

    // Force refresh input
    setState(() {});
  }

  void readSetting() async {
    final setting = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .get();
    final data = setting.data();
    setState(() {
      controllerNickname.text =
          (data['nickname'] != null) ? data['nickname'] : '';
      nickname = (data['nickname'] != null) ? data['nickname'] : '';
      university = (data['university'] != null) ? data['university'] : '';
      faculty = (data['faculty'] != null) ? data['faculty'] : '';
      department = (data['department'] != null) ? data['department'] : '';
      grade = (data['grade'] != null) ? data['grade'] : '';
      age = (data['age'] != null) ? data['age'] : '';
      residence = (data['residence'] != null) ? data['residence'] : '';
      birthplace = (data['birthplace'] != null) ? data['birthplace'] : '';
      controllerGrade.text = (data['grade'] != null) ? data['grade'] : '';
      controllerAge.text = (data['age'] != null) ? data['age'] : '';
      controllerResidence.text =
          (data['residence'] != null) ? data['residence'] : '';
      controllerBirthplace.text =
          (data['birthplace'] != null) ? data['birthplace'] : '';
      circle = (data['circle'] != null)
          ? conv_to_intList(data['circle'].cast<String>())
          : [];
      travel = (data['travel'] != null)
          ? conv_to_intList(data['travel'].cast<String>())
          : [];
      gourmet = (data['gourmet'] != null)
          ? conv_to_intList(data['gourmet'].cast<String>())
          : [];
      sport = (data['sport'] != null)
          ? conv_to_intList(data['sport'].cast<String>())
          : [];
      music = (data['music'] != null)
          ? conv_to_intList(data['music'].cast<String>())
          : [];
      hobby = (data['hobby'] != null)
          ? conv_to_intList(data['hobby'].cast<String>())
          : [];
      photoUrl = data['photoUrl'];
    });
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
    String fileName = widget.currentUserId;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;

          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.currentUserId)
              .update({'photoUrl': photoUrl}).then((data) async {
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
    // focusNodeAffiliation.unfocus();
    focusNodeGrade.unfocus();
    focusNodeResidence.unfocus();
    //focusNodeCircle.unfocus();
    focusNodeTravel.unfocus();
    focusNodeGrourmet.unfocus();
    focusNodeSport.unfocus();
    focusNodeMusic.unfocus();
    focusNodeHobby.unfocus();
    setState(() {
      isLoading = true;
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .update({
      'nickname': nickname,
      'grade': grade,
      'age': controllerAge.text,
      'residence': controllerResidence.text,
      'birthplace': controllerBirthplace.text,
      'circle': conv_to_stringList(circle),
      'travel': conv_to_stringList(travel),
      'gourmet': conv_to_stringList(gourmet),
      'sport': conv_to_stringList(sport),
      'music': conv_to_stringList(music),
      'hobby': conv_to_stringList(hobby),
      'photoUrl': photoUrl
    }).then((data) async {
      await prefs.setString('nickname', nickname);
      // await prefs.setString('affiliation', affiliation);
      await prefs.setString('university', university);
      await prefs.setString('faculty', faculty);
      await prefs.setString('department', department);
      await prefs.setString('grade', grade);
      await prefs.setString('age', age);
      await prefs.setString('residence', residence);
      await prefs.setString('birthplace', birthplace);
      //await prefs.setStringList('circle', conv_to_stringList(circle));
      /*
      await prefs.setStringList('circle', conv_to_stringList());
      await prefs.setStringList('circle', conv_to_stringList(circle));
      await prefs.setStringList('circle', conv_to_stringList(circle));
      await prefs.setStringList('circle', conv_to_stringList(circle));
      await prefs.setStringList('circle', conv_to_stringList(circle));
      await prefs.setString('photoUrl', photoUrl);
*/
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

  List<String> conv_to_stringList(List<int> l) {
    List<String> ret = [];
    for (int i = 0; i < l.length; i++) {
      ret.add(l[i].toString());
    }
    return ret;
  }

  List<int> conv_to_intList(List<String> l) {
    List<int> ret = [];
    for (int i = 0; i < l.length; i++) {
      ret.add(int.parse(l[i]));
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    //controllerNickname.text = 'hoge';
    //print('build::nickname: ' + controllerNickname.text);
    List<DropdownMenuItem> circleList = [
      DropdownMenuItem(child: Text('サッカー'), value: 'サッカー'),
      DropdownMenuItem(child: Text('野球'), value: '野球'),
      DropdownMenuItem(child: Text('バスケットボール'), value: 'バスケットボール'),
      DropdownMenuItem(child: Text('アカペラ'), value: 'アカペラ'),
      DropdownMenuItem(child: Text('管弦楽団'), value: '管弦楽団'),
    ];

    List<DropdownMenuItem> travelList = [
      DropdownMenuItem(child: Text('東京'), value: '東京'),
      DropdownMenuItem(child: Text('京都'), value: '京都'),
      DropdownMenuItem(child: Text('イスタンブール'), value: 'イスタンブール'),
      DropdownMenuItem(child: Text('パリ'), value: 'パリ'),
      DropdownMenuItem(child: Text('マドリード'), value: 'マドリード'),
    ];

    List<DropdownMenuItem> gourmetList = [
      DropdownMenuItem(child: Text('寿司'), value: '寿司'),
      DropdownMenuItem(child: Text('焼肉'), value: '焼肉'),
      DropdownMenuItem(child: Text('ハンバーグ'), value: 'ハンバーグ'),
      DropdownMenuItem(child: Text('うどん'), value: 'うどん'),
      DropdownMenuItem(child: Text('ラーメン'), value: 'ラーメン'),
    ];

    List<DropdownMenuItem> sportList = [
      DropdownMenuItem(child: Text('野球'), value: '野球'),
      DropdownMenuItem(child: Text('サッカー'), value: 'サッカー'),
      DropdownMenuItem(child: Text('バスケットボール'), value: 'バスケットボール'),
      DropdownMenuItem(child: Text('テニス'), value: 'テニス'),
      DropdownMenuItem(child: Text('ホッケー'), value: 'ホッケー'),
    ];

    List<DropdownMenuItem> musicList = [
      DropdownMenuItem(child: Text('J-POP'), value: 'J-POP'),
      DropdownMenuItem(child: Text('K-POP'), value: 'K-POP'),
      DropdownMenuItem(child: Text('レゲエ'), value: 'レゲエ'),
      DropdownMenuItem(child: Text('R&B'), value: 'R&B'),
      DropdownMenuItem(child: Text('クラシック'), value: 'クラシック'),
    ];

    List<DropdownMenuItem> hobbyList = [
      DropdownMenuItem(child: Text('ランニング'), value: 'ランニング'),
      DropdownMenuItem(child: Text('サイクリング'), value: 'サイクリング'),
      DropdownMenuItem(child: Text('キャンプ'), value: 'キャンプ'),
      DropdownMenuItem(child: Text('手芸'), value: '手芸'),
      DropdownMenuItem(child: Text('読書'), value: '読書'),
    ];

    if (!widget.isMyProfile) {
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
                              ? (photoUrl != null && photoUrl != ''
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(45.0)),
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
                        // controllerNickname.text,
                        style: TextStyle(fontSize: 23),
                      ),
                      width: 200,
                      margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    ),
                  ],
                ),

                // Cardのリスト
                Column(
                  children: <Widget>[
                    // 大学情報
                    Container(
                      child: Text(
                        '大学情報',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: primaryColor),
                      ),
                      alignment: Alignment.topLeft,
                      margin:
                          EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                    ),
                    // 大学名
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Container(
                        height: 60,
                        child: Card(
                          color: orangeColor,
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '大学',
                                  style: TextStyle(fontSize: 23),
                                ),
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Flexible(
                                child: Text(
                                  university,
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ),
                    ),
                    // 学部名
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Container(
                        height: 60,
                        child: Card(
                          color: orangeColor,
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '学部',
                                  style: TextStyle(fontSize: 23),
                                ),
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Flexible(
                                child: Text(
                                  faculty,
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ),
                    ),
                    // 学科名
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Container(
                        height: 60,
                        child: Card(
                          color: orangeColor,
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '学科',
                                  style: TextStyle(fontSize: 23),
                                ),
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Flexible(
                                child: Text(
                                  department,
                                  style: TextStyle(fontSize: 17),
                                ),
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
                        height: 55,
                        child: Card(
                          color: orangeColor,
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '学年',
                                  style: TextStyle(fontSize: 23),
                                ),
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Flexible(
                                child: Text(
                                  grade,
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ),
                    ),
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
                      margin:
                          EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                    ),
                    // 年齢
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
                                  '年齢',
                                  style: TextStyle(fontSize: 23),
                                ),
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Text(
                                age,
                                // controllerAge.text,
                                style: TextStyle(fontSize: 17),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ),
                    ),
                    //居住地
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
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Text(
                                residence,
                                // controllerResidence.text,
                                style: TextStyle(fontSize: 17),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ),
                    ),
                    // 出身地
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
                                  '出身地',
                                  style: TextStyle(fontSize: 23),
                                ),
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Text(
                                birthplace,
                                // controllerBirthplace.text,
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
                        width: 400,
                        child: Card(
                          color: orangeColor,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  'サークル',
                                  style: TextStyle(fontSize: 23),
                                ),
                                alignment: Alignment.topLeft,
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Column(
                                children: <Widget>[
                                  for (var i in circle)
                                    Text(
                                      circleList[i].value,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 17),
                                    )
                                ],
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ),
                    ),
                    // その他
                    Container(
                      child: Text(
                        'その他',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: primaryColor),
                      ),
                      alignment: Alignment.topLeft,
                      margin:
                          EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                    ),
                    // 旅行
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Container(
                        width: 400,
                        child: Card(
                          color: orangeColor,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '旅行',
                                  style: TextStyle(fontSize: 23),
                                ),
                                alignment: Alignment.topLeft,
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Column(
                                children: <Widget>[
                                  for (var i in travel)
                                    Text(
                                      travelList[i].value,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 17),
                                    )
                                ],
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ),
                    ),
                    // グルメ
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Container(
                        width: 400,
                        child: Card(
                          color: orangeColor,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  'グルメ',
                                  style: TextStyle(fontSize: 23),
                                ),
                                alignment: Alignment.topLeft,
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Column(
                                children: <Widget>[
                                  for (var i in gourmet)
                                    Text(
                                      gourmetList[i].value,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 17),
                                    )
                                ],
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ),
                    ),
                    // スポーツ
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Container(
                        width: 400,
                        child: Card(
                          color: orangeColor,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  'スポーツ',
                                  style: TextStyle(fontSize: 23),
                                ),
                                alignment: Alignment.topLeft,
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Column(
                                children: <Widget>[
                                  for (var i in sport)
                                    Text(
                                      sportList[i].value,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 17),
                                    )
                                ],
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ),
                    ),
                    // 音楽
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Container(
                        width: 400,
                        child: Card(
                          color: orangeColor,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '音楽',
                                  style: TextStyle(fontSize: 23),
                                ),
                                alignment: Alignment.topLeft,
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Column(
                                children: <Widget>[
                                  for (var i in music)
                                    Text(
                                      musicList[i].value,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 17),
                                    )
                                ],
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ),
                    ),
                    // 趣味
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Container(
                        width: 400,
                        child: Card(
                          color: orangeColor,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '趣味',
                                  style: TextStyle(fontSize: 23),
                                ),
                                alignment: Alignment.topLeft,
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                              ),
                              Column(
                                children: <Widget>[
                                  for (var i in hobby)
                                    Text(
                                      hobbyList[i].value,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 17),
                                    )
                                ],
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ),
                    ),
                    // 授業をみる
                    Container(
                      child: FlatButton(
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Text(
                          '授業情報を見る',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Classes(
                                      currentUserId: widget.currentUserId,
                                      university: university,
                                      isMyProfile: false)));
                        },
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
                              ? (photoUrl != null && photoUrl != ''
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(45.0)),
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
                    // Nickname
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
                // 大学情報
                Container(
                  child: Text(
                    '大学情報',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: primaryColor),
                  ),
                  margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                ),
                // 大学名
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Container(
                    height: 60,
                    child: Card(
                      color: orangeColor,
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Text(
                              '大学',
                              style: TextStyle(fontSize: 23),
                            ),
                            margin: EdgeInsets.only(left: 10.0, right: 10.0),
                          ),
                          Flexible(
                            child: Text(
                              university,
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                  ),
                ),
                // 学部名
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Container(
                    height: 60,
                    child: Card(
                      color: orangeColor,
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Text(
                              '学部',
                              style: TextStyle(fontSize: 23),
                            ),
                            margin: EdgeInsets.only(left: 10.0, right: 10.0),
                          ),
                          Flexible(
                            child: Text(
                              faculty,
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                  ),
                ),
                // 学科名
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Container(
                    height: 60,
                    child: Card(
                      color: orangeColor,
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Text(
                              '学科',
                              style: TextStyle(fontSize: 23),
                            ),
                            margin: EdgeInsets.only(left: 10.0, right: 10.0),
                          ),
                          Flexible(
                            child: Text(
                              department,
                              style: TextStyle(fontSize: 17),
                            ),
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
                  child: Card(
                    color: orangeColor,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            '学年',
                            style: TextStyle(fontSize: 23),
                            textAlign: TextAlign.left,
                          ),
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: primaryColor),
                          child: SearchChoices.single(
                            items: [
                              DropdownMenuItem(
                                child: Text('1年'),
                                value: '1年',
                              ),
                              DropdownMenuItem(
                                child: Text('2年'),
                                value: '2年',
                              ),
                              DropdownMenuItem(
                                child: Text('3年'),
                                value: '3年',
                              ),
                              DropdownMenuItem(
                                child: Text('4年'),
                                value: '4年',
                              ),
                              DropdownMenuItem(
                                child: Text('卒業生'),
                                value: '卒業生',
                              ),
                            ],
                            value: grade,
                            displayClearIcon: false,
                            onChanged: (value) {
                              setState(() {
                                grade = value;
                              });
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.currentUserId)
                                  .update({
                                'grade': grade,
                              }).then((data) async {
                                setState(() {
                                  isLoading = false;
                                });
                              }).catchError((err) {
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            },
                            dialogBox: false,
                            isExpanded: true,
                            menuConstraints:
                                BoxConstraints.tight(Size.fromHeight(350)),
                          ),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ),
                // 基本情報
                Container(
                  child: Text(
                    '基本情報',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: primaryColor),
                  ),
                  margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                ),
                // 年齢
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Card(
                    color: orangeColor,
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Text(
                            '年齢',
                            style: TextStyle(fontSize: 23),
                          ),
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: primaryColor),
                          child: Flexible(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: '23',
                                contentPadding: EdgeInsets.all(5.0),
                                hintStyle: TextStyle(color: greyColor),
                              ),
                              controller: controllerAge,
                              onChanged: (value) {
                                age = value;
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.currentUserId)
                                    .update({
                                  'age': age,
                                }).then((data) async {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }).catchError((err) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              },
                              focusNode: focusNodeAge,
                            ),
                          ),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ),
                // 居住地
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
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
                        Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: primaryColor),
                          child: Flexible(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: '東京',
                                contentPadding: EdgeInsets.all(5.0),
                                hintStyle: TextStyle(color: greyColor),
                              ),
                              controller: controllerResidence,
                              onChanged: (value) {
                                residence = value;
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.currentUserId)
                                    .update({
                                  'residence': residence,
                                }).then((data) async {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }).catchError((err) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              },
                              focusNode: focusNodeResidence,
                            ),
                          ),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ),
                // 出身地
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Card(
                    color: orangeColor,
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Text(
                            '出身地',
                            style: TextStyle(fontSize: 23),
                          ),
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: primaryColor),
                          child: Flexible(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: '東京',
                                contentPadding: EdgeInsets.all(5.0),
                                hintStyle: TextStyle(color: greyColor),
                              ),
                              controller: controllerBirthplace,
                              onChanged: (value) {
                                birthplace = value;
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.currentUserId)
                                    .update({
                                  'birthplace': birthplace,
                                }).then((data) async {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }).catchError((err) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              },
                              focusNode: focusNodeBirthplace,
                            ),
                          ),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ),
                // サークル
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Card(
                    color: orangeColor,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            'サークル',
                            style: TextStyle(fontSize: 23),
                          ),
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: primaryColor),
                          child: SearchChoices.multiple(
                            items: circleList,
                            selectedItems: circle,
                            onChanged: (value) {
                              setState(() {
                                circle = value;
                              });
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.currentUserId)
                                  .update({
                                'circle': conv_to_stringList(circle),
                              }).then((data) async {
                                setState(() {
                                  isLoading = false;
                                });
                              }).catchError((err) {
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            },
                            dialogBox: false,
                            isExpanded: true,
                            menuConstraints:
                                BoxConstraints.tight(Size.fromHeight(350)),
                          ),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ),
                // その他
                Container(
                  child: Text(
                    'その他',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: primaryColor),
                  ),
                  margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                ),
                // 旅行
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Card(
                    color: orangeColor,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            '旅行',
                            style: TextStyle(fontSize: 23),
                          ),
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: primaryColor),
                          child: SearchChoices.multiple(
                            items: travelList,
                            selectedItems: travel,
                            onChanged: (value) {
                              setState(() {
                                travel = value;
                              });
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.currentUserId)
                                  .update({
                                'travel': conv_to_stringList(travel),
                              }).then((data) async {
                                setState(() {
                                  isLoading = false;
                                });
                              }).catchError((err) {
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            },
                            dialogBox: false,
                            isExpanded: true,
                            menuConstraints:
                                BoxConstraints.tight(Size.fromHeight(350)),
                          ),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ),
                // グルメ
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Card(
                    color: orangeColor,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            'グルメ',
                            style: TextStyle(fontSize: 23),
                          ),
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: primaryColor),
                          child: SearchChoices.multiple(
                            items: gourmetList,
                            selectedItems: gourmet,
                            onChanged: (value) {
                              setState(() {
                                gourmet = value;
                              });
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.currentUserId)
                                  .update({
                                'gourmet': conv_to_stringList(gourmet),
                              }).then((data) async {
                                setState(() {
                                  isLoading = false;
                                });
                              }).catchError((err) {
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            },
                            dialogBox: false,
                            isExpanded: true,
                            menuConstraints:
                                BoxConstraints.tight(Size.fromHeight(350)),
                          ),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ),
                // スポーツ
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Card(
                    color: orangeColor,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            'スポーツ',
                            style: TextStyle(fontSize: 23),
                          ),
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: primaryColor),
                          child: SearchChoices.multiple(
                            items: sportList,
                            selectedItems: sport,
                            onChanged: (value) {
                              setState(() {
                                sport = value;
                              });
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.currentUserId)
                                  .update({
                                'sport': conv_to_stringList(sport),
                              }).then((data) async {
                                setState(() {
                                  isLoading = false;
                                });
                              }).catchError((err) {
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            },
                            dialogBox: false,
                            isExpanded: true,
                            menuConstraints:
                                BoxConstraints.tight(Size.fromHeight(350)),
                          ),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ),
                // 音楽
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Card(
                    color: orangeColor,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            '音楽',
                            style: TextStyle(fontSize: 23),
                          ),
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: primaryColor),
                          child: SearchChoices.multiple(
                            items: musicList,
                            selectedItems: music,
                            onChanged: (value) {
                              setState(() {
                                music = value;
                              });
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.currentUserId)
                                  .update({
                                'music': conv_to_stringList(music),
                              }).then((data) async {
                                setState(() {
                                  isLoading = false;
                                });
                              }).catchError((err) {
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            },
                            dialogBox: false,
                            isExpanded: true,
                            menuConstraints:
                                BoxConstraints.tight(Size.fromHeight(350)),
                          ),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ),
                // 趣味
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Card(
                    color: orangeColor,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            '趣味',
                            style: TextStyle(fontSize: 23),
                          ),
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(primaryColor: primaryColor),
                          child: SearchChoices.multiple(
                            items: hobbyList,
                            selectedItems: hobby,
                            onChanged: (value) {
                              setState(() {
                                hobby = value;
                              });
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.currentUserId)
                                  .update({
                                'hobby': conv_to_stringList(hobby),
                              }).then((data) async {
                                setState(() {
                                  isLoading = false;
                                });
                              }).catchError((err) {
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            },
                            dialogBox: false,
                            isExpanded: true,
                            menuConstraints:
                                BoxConstraints.tight(Size.fromHeight(350)),
                          ),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ),
                // Button
                /*
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
                 */
                // 授業をみる
                Container(
                  child: FlatButton(
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Text(
                      '授業情報を見る',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Classes(
                                  currentUserId: widget.currentUserId,
                                  university: university,
                                  isMyProfile: true)));
                    },
                  ),
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(themeColor)),
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
