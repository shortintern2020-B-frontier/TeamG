import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hikomaryu/const.dart';
import 'package:hikomaryu/home.dart';
import 'package:hikomaryu/widget/loading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:search_choices/search_choices.dart';

import 'const.dart';
import 'api.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SharedPreferences _prefs;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  bool _isLoading = false;
  bool _signupButtonPressed = false;
  bool _cannotSelectFaculty = false;
  bool _cannotSelectDepartment = false;
  String _gradeValue = '1';
  String _prefecturesValue;
  String _universityValue;
  String _facultyValue;
  String _departmentValue;
  List<DropdownMenuItem<String>> _prefecturesItems = [];
  List<DropdownMenuItem<String>> _dummyItems = [];

  StreamController<List<DropdownMenuItem<String>>> _universityEvents;
  StreamController<List<DropdownMenuItem<String>>> _facultyEvents;
  StreamController<List<DropdownMenuItem<String>>> _departmentEvents;

  @override
  void initState() {
    final List<String> prefecturesKeys = [];
    prefectures.forEach((k, _) => prefecturesKeys.add(k));

    _prefecturesItems = makeDropdowmMenuFromStringList(prefecturesKeys);
    _dummyItems = makeDropdowmMenuFromStringList(['']);

    _universityEvents = StreamController<List<DropdownMenuItem<String>>>();
    _facultyEvents = StreamController<List<DropdownMenuItem<String>>>();
    _departmentEvents = StreamController<List<DropdownMenuItem<String>>>();

    _universityEvents.add(_dummyItems);
    _facultyEvents.add(_dummyItems);
    _departmentEvents.add(_dummyItems);

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  String isEmptyValidator(String value) {
    if (value.isEmpty) {
      return textFieldMsgs['required'];
    }
    return null;
  }

  bool checkDummyMenu(List<DropdownMenuItem<String>> snapshotData) {
    if (snapshotData.length == 1 && snapshotData[0].value.length == 0)
      return true;
    return false;
  }

  Future<Null> _handleSingUp() async {
    _prefs = await SharedPreferences.getInstance();

    this.setState(() {
      _isLoading = true;
    });

    // 新規登録時にフォームから取得
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);

      // Update data to server if new user
      FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user.uid)
          .set({
        'nickname': _nicknameController.text,
        'university': _universityValue,
        'faculty': _facultyValue,
        'department': _departmentValue,
        'grade': _gradeValue,
        'id': userCredential.user.uid,
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        'photoUrl': null,
        'chattingWith': null
      });
      // 成功した場合は表示させない
      // Fluttertoast.showToast(
      //     msg: signUpMsgs['success'], backgroundColor: themeColor);
      this.setState(() {
        _isLoading = false;
      });

      // Write data to local
      await _prefs.setString('id', userCredential.user.uid);
      await _prefs.setString('nickname', _nicknameController.text);

      // TODO - プロフィール詳細設定画面へ遷移するようにする
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(currentUserId: userCredential.user.uid)));
      return null;
    } on FirebaseAuthException catch (e) {
      print(signUpMsgs[e.code]);
      Fluttertoast.showToast(
          msg: signUpMsgs[e.code], backgroundColor: themeColor);
      this.setState(() {
        _isLoading = false;
      });
      return null;
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(
          msg: signUpMsgs['other'], backgroundColor: themeColor);
      this.setState(() {
        _isLoading = false;
      });
      // print('新規登録失敗!!!!!!');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _emailController,
                          decoration:
                              const InputDecoration(labelText: 'メールアドレス'),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return textFieldMsgs['required'];
                            } else if (!RegExp(r"[\w\-\._]+@[\w\-\._]+\.ac\.jp")
                                .hasMatch(value)) {
                              return textFieldMsgs['uni-email-need'];
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                            obscureText: true,
                            controller: _passwordController,
                            decoration:
                                const InputDecoration(labelText: 'パスワード'),
                            validator: (String value) =>
                                isEmptyValidator(value)),
                        SizedBox(height: 20.0),
                        TextFormField(
                            controller: _nicknameController,
                            decoration:
                                const InputDecoration(labelText: 'ニックネーム'),
                            validator: (String value) =>
                                isEmptyValidator(value)),
                        SizedBox(height: 50.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(8),
                              child: const Text('都道府県'),
                              decoration: BoxDecoration(
                                color: greyColor2,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            SearchChoices.single(
                              hint: choiceMsgs['ph'],
                              searchHint: choiceMsgs['psh'],
                              items: _prefecturesItems,
                              value: _prefecturesValue,
                              dialogBox: false,
                              isExpanded: true,
                              menuConstraints:
                                  BoxConstraints.tight(Size.fromHeight(350)),
                              onChanged: (value) {
                                setState(() {
                                  _prefecturesValue = value;
                                  makeDropdownMenu(_universityEvents,
                                      apiMode.university, _prefecturesValue);
                                  _universityEvents.add(_dummyItems);
                                  _facultyEvents.add(_dummyItems);
                                  _departmentEvents.add(_dummyItems);
                                  _universityValue = null;
                                  _facultyValue = null;
                                  _departmentValue = null;
                                });
                              },
                              validator: (String value) {
                                if (value == null && _signupButtonPressed)
                                  return textFieldMsgs['required'];
                                return null;
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 20.0),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(8),
                                child: const Text('大学'),
                                decoration: BoxDecoration(
                                  color: greyColor2,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              StreamBuilder(
                                stream: _universityEvents.stream,
                                builder: (BuildContext context, snapshot) {
                                  return AbsorbPointer(
                                    absorbing: _prefecturesValue == null,
                                    child: SearchChoices.single(
                                      hint: _prefecturesValue == null
                                          ? '先に都道府県を入力してください'
                                          : choiceMsgs['uh'],
                                      searchHint: choiceMsgs['ush'],
                                      items: _prefecturesValue == null
                                          ? _dummyItems
                                          : snapshot.data,
                                      value: _universityValue,
                                      dialogBox: false,
                                      isExpanded: true,
                                      menuConstraints: BoxConstraints.tight(
                                          Size.fromHeight(350)),
                                      onChanged: (value) {
                                        setState(() {
                                          _universityValue = value;
                                          _facultyEvents.add(_dummyItems);
                                          _departmentEvents.add(_dummyItems);
                                          _facultyValue = null;
                                          _departmentValue = null;
                                          makeDropdownMenu(
                                              _facultyEvents,
                                              apiMode.faculty,
                                              _prefecturesValue,
                                              _universityValue);
                                        });
                                      },
                                      validator: (String value) {
                                        if (value == null &&
                                            _signupButtonPressed)
                                          return textFieldMsgs['required'];
                                        return null;
                                      },
                                    ),
                                  );
                                },
                              ),
                            ]),
                        SizedBox(height: 20.0),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(8),
                                child: const Text('学部'),
                                decoration: BoxDecoration(
                                  color: greyColor2,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              StreamBuilder(
                                  stream: _facultyEvents.stream,
                                  builder: (BuildContext context, snapshot) {
                                    _cannotSelectFaculty =
                                        checkDummyMenu(snapshot.data);
                                    return AbsorbPointer(
                                      absorbing: _prefecturesValue == null ||
                                          _universityValue == null ||
                                          _cannotSelectFaculty,
                                      child: SearchChoices.single(
                                        hint: _prefecturesValue == null
                                            ? '先に都道府県を入力してください'
                                            : (_universityValue == null
                                                ? '先に大学を入力してください'
                                                : (_cannotSelectFaculty
                                                    ? '項目がないため選択できません'
                                                    : choiceMsgs['fh'])),
                                        searchHint: choiceMsgs['fsh'],
                                        items: _prefecturesValue == null ||
                                                _universityValue == null ||
                                                _cannotSelectFaculty
                                            ? _dummyItems
                                            : snapshot.data,
                                        value: _facultyValue,
                                        dialogBox: false,
                                        isExpanded: true,
                                        menuConstraints: BoxConstraints.tight(
                                            Size.fromHeight(350)),
                                        onChanged: (value) {
                                          setState(() {
                                            _facultyValue = value;
                                            _departmentValue = null;
                                            if (_facultyValue != null)
                                              makeDropdownMenu(
                                                  _departmentEvents,
                                                  apiMode.department,
                                                  _prefecturesValue,
                                                  _universityValue,
                                                  _facultyValue);
                                            // _departmentEvents.add(_dummyItems);
                                          });
                                        },
                                      ),
                                    );
                                  }),
                            ]),
                        SizedBox(height: 20.0),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(8),
                                child: const Text('学科'),
                                decoration: BoxDecoration(
                                  color: greyColor2,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              StreamBuilder(
                                stream: _departmentEvents.stream,
                                builder: (BuildContext context, snapshot) {
                                  // print(snapshot.data);
                                  _cannotSelectDepartment =
                                      checkDummyMenu(snapshot.data);
                                  print('debug');
                                  print(_cannotSelectFaculty);
                                  print(_cannotSelectDepartment);
                                  return AbsorbPointer(
                                    absorbing: _prefecturesValue == null ||
                                        _universityValue == null ||
                                        _facultyValue == null ||
                                        _cannotSelectFaculty ||
                                        _cannotSelectDepartment,
                                    child: SearchChoices.single(
                                      hint: _prefecturesValue == null
                                          ? '先に都道府県を入力してください'
                                          : (_universityValue == null
                                              ? '先に大学を入力してください'
                                              : (_facultyValue == null
                                                  ? '先に学部を入力してください'
                                                  : (_cannotSelectFaculty ||
                                                          _cannotSelectDepartment
                                                      ? '項目がないため選択できません'
                                                      : choiceMsgs['dh']))),
                                      searchHint: choiceMsgs['dsh'],
                                      items: _prefecturesValue == null ||
                                              _universityValue == null ||
                                              _facultyValue == null ||
                                              _cannotSelectFaculty ||
                                              _cannotSelectDepartment
                                          ? _dummyItems
                                          : snapshot.data,
                                      value: _departmentValue,
                                      dialogBox: false,
                                      isExpanded: true,
                                      menuConstraints: BoxConstraints.tight(
                                          Size.fromHeight(350)),
                                      onChanged: (value) {
                                        setState(() {
                                          _departmentValue = value;
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ]),
                        SizedBox(height: 20.0),
                        Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(8),
                              child: const Text('学年'),
                              decoration: BoxDecoration(
                                color: greyColor2,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            SizedBox(width: 20),
                            Flexible(
                              child: DropdownButton<String>(
                                value: _gradeValue,
                                items: <String>['1', '2', '3', '4']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String value) {
                                  setState(() {
                                    _gradeValue = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: MaterialButton(
                    child: const Text('新規登録'),
                    minWidth: 200,
                    color: themeColor,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onPressed: () async {
                      setState(() {
                        _signupButtonPressed = true;
                      });
                      if (_formKey.currentState.validate() &&
                          _universityValue != null) {
                        _handleSingUp();
                      }
                    },
                  ),
                ),
              ],
            ),
            // Loading
            Positioned(child: _isLoading ? const Loading() : Container())
          ],
        ));
  }
}
