import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< HEAD
// import 'package:firebase_core/firebase_core.dart';
=======
>>>>>>> develop
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

  String _gradeValue = '1';
  bool _isLoading = false;

  String _prefecturesValue;
  String _universityValue;
  String _facultyValue;
  String _departmentValue;
  List<DropdownMenuItem<String>> _prefecturesItems = [];
  List<DropdownMenuItem<String>> _emptyItems = [];

  StreamController<List<DropdownMenuItem<String>>> _universityEvents;
  StreamController<List<DropdownMenuItem<String>>> _facultyEvents;
  StreamController<List<DropdownMenuItem<String>>> _departmentEvents;

  @override
  void initState() {
    final List<String> prefecturesKeys = [];
    prefectures.forEach((k, _) => prefecturesKeys.add(k));

    _prefecturesItems = makeDropdowmMenuFromStringList(prefecturesKeys);
    _emptyItems = makeDropdowmMenuFromStringList(['']);

    _universityEvents = StreamController<List<DropdownMenuItem<String>>>();
    _facultyEvents = StreamController<List<DropdownMenuItem<String>>>();
    _departmentEvents = StreamController<List<DropdownMenuItem<String>>>();

    _universityEvents.add(_emptyItems);
    _facultyEvents.add(_emptyItems);
    _departmentEvents.add(_emptyItems);

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
<<<<<<< HEAD
      Fluttertoast.showToast(
          msg: signUpMsgs['success'], backgroundColor: themeColor);
      this.setState(() {
        _isLoading = false;
      });
      // print('新規登録成功!!!!!!');
=======
      // 成功した場合は表示させない
      // Fluttertoast.showToast(
      //     msg: signUpMsgs['success'], backgroundColor: themeColor);
      this.setState(() {
        _isLoading = false;
      });
>>>>>>> develop

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
<<<<<<< HEAD
                          decoration: const InputDecoration(labelText: 'Email'),
=======
                          decoration:
                              const InputDecoration(labelText: 'メールアドレス'),
>>>>>>> develop
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
<<<<<<< HEAD
                                const InputDecoration(labelText: 'Password'),
=======
                                const InputDecoration(labelText: 'パスワード'),
>>>>>>> develop
                            validator: (String value) =>
                                isEmptyValidator(value)),
                        SizedBox(height: 20.0),
                        TextFormField(
                            controller: _nicknameController,
                            decoration:
<<<<<<< HEAD
                                const InputDecoration(labelText: 'Nickname'),
=======
                                const InputDecoration(labelText: 'ニックネーム'),
>>>>>>> develop
                            validator: (String value) =>
                                isEmptyValidator(value)),
                        SizedBox(height: 50.0),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(8),
<<<<<<< HEAD
                                child: const Text('Prefecture'),
=======
                                child: const Text('都道府県'),
>>>>>>> develop
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
                                    _universityEvents.add(_emptyItems);
                                    _facultyEvents.add(_emptyItems);
                                    _departmentEvents.add(_emptyItems);
                                    _universityValue = null;
                                    _facultyValue = null;
                                    _departmentValue = null;
                                  });
                                },
                              ),
                            ]),
                        SizedBox(height: 20.0),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(8),
<<<<<<< HEAD
                                child: const Text('University'),
=======
                                child: const Text('大学'),
>>>>>>> develop
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
                                      hint: choiceMsgs['uh'],
                                      searchHint: choiceMsgs['ush'],
                                      items: _prefecturesValue == null
                                          ? _emptyItems
                                          : snapshot.data,
                                      value: _universityValue,
                                      dialogBox: false,
                                      isExpanded: true,
                                      menuConstraints: BoxConstraints.tight(
                                          Size.fromHeight(350)),
                                      onChanged: (value) {
                                        setState(() {
                                          _universityValue = value;
                                          if (_universityValue == null) {
                                            _facultyEvents.add(_emptyItems);
                                            _departmentEvents.add(_emptyItems);
                                            _facultyValue = null;
                                            _departmentValue = null;
                                          } else {
                                            makeDropdownMenu(
                                                _facultyEvents,
                                                apiMode.faculty,
                                                _prefecturesValue,
                                                _universityValue);
                                          }
                                        });
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
<<<<<<< HEAD
                                child: const Text('Faculty'),
=======
                                child: const Text('学部'),
>>>>>>> develop
                                decoration: BoxDecoration(
                                  color: greyColor2,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              StreamBuilder(
                                  stream: _facultyEvents.stream,
                                  builder: (BuildContext context, snapshot) {
                                    return AbsorbPointer(
                                      absorbing: _prefecturesValue == null ||
                                          _universityValue == null,
                                      child: SearchChoices.single(
                                        hint: choiceMsgs['fh'],
                                        searchHint: choiceMsgs['fsh'],
                                        items: _prefecturesValue == null ||
                                                _universityValue == null
                                            ? _emptyItems
                                            : snapshot.data,
                                        value: _facultyValue,
                                        dialogBox: false,
                                        isExpanded: true,
                                        menuConstraints: BoxConstraints.tight(
                                            Size.fromHeight(350)),
                                        onChanged: (value) {
                                          setState(() {
                                            _facultyValue = value;
                                            makeDropdownMenu(
                                                _departmentEvents,
                                                apiMode.department,
                                                _prefecturesValue,
                                                _universityValue,
                                                _facultyValue);
                                            _departmentEvents.add(_emptyItems);
                                            _departmentValue = null;
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
<<<<<<< HEAD
                                child: const Text('Department'),
=======
                                child: const Text('学科'),
>>>>>>> develop
                                decoration: BoxDecoration(
                                  color: greyColor2,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              StreamBuilder(
                                stream: _departmentEvents.stream,
                                builder: (BuildContext context, snapshot) {
                                  return AbsorbPointer(
                                    absorbing: _prefecturesValue == null ||
                                        _universityValue == null ||
                                        _facultyValue == null,
                                    child: SearchChoices.single(
                                      hint: choiceMsgs['dh'],
                                      searchHint: choiceMsgs['dsh'],
                                      items: _prefecturesValue == null ||
                                              _universityValue == null ||
                                              _facultyValue == null
                                          ? _emptyItems
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
<<<<<<< HEAD
                              child: const Text('Grade'),
=======
                              child: const Text('学年'),
>>>>>>> develop
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
<<<<<<< HEAD
                    child: const Text('Sign up'),
=======
                    child: const Text('新規登録'),
>>>>>>> develop
                    minWidth: 200,
                    color: themeColor,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
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
