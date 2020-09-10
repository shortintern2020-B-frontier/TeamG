import 'dart:ui';

final themeColor = Color(0xffBF0900);
final orangeColor = Color(0xfff1dba1);
final primaryColor = Color(0xff203152);
final greyColor = Color(0xffaeaeae);
final greyColor2 = Color(0xffE8E8E8);
final whiteColor = Color(0xfffafafa);
final orangeColor = Color(0xfff1dba1);

final apiKey = '4abf648ea80e7431';
final baseApiUrl =
    'http://webservice.recruit.co.jp/shingaku/school/v1/?key=$apiKey&format=json';
enum apiMode { university, faculty, department }

// final textFieldMsgs = {
//   'required': 'Please enter some text',
//   'uni-email-need': 'Please enter your university email address'
// };
final textFieldMsgs = {
  'required': '必須項目です',
  'uni-email-need': '大学のメールアドレスを登録してください'
};

// final signUpMsgs = {
//   'success': 'Sign up success',
//   'weak-password': 'The password provided is too weak',
//   'email-already-in-use': 'The account already exists for that email',
//   'invalid-email': 'Invalid format for an e-mail address',
//   'other': 'Sign up failed'
// };
final signUpMsgs = {
  'success': '新規登録に成功しました',
  'weak-password': 'パスワードが短すぎます',
  'email-already-in-use': 'そのメールアドレスは既に使用されています',
  'invalid-email': 'メールアドレスの形式が異なります',
  'other': '新規登録に失敗しました'
};

// final loginMsgs = {
//   'success': 'Login success',
//   'user-not-found': 'No user found for that email',
//   'wrong-password': 'Wrong password provided for that user',
//   'invalid-email': 'Invalid format for an e-mail address',
//   'other': 'Login failed'
// };
final loginMsgs = {
  'success': 'ログインに成功しました',
  'user-not-found': 'そのユーザーは登録されていません',
  'wrong-password': 'パスワードが間違っています',
  'invalid-email': 'メールアドレスの形式が異なります',
  'other': 'ログインに失敗しました'
};

// final choiceMsgs = {
//   'ph': 'Please select',
//   'psh': null, //'都道府県名を入力してください',
//   'uh': 'Please select',
//   'ush': null, //'大学名を入力してください',
//   'fh': 'Please select',
//   'fsh': null, //'学部名を入力してください',
//   'dh': 'Please select',
//   'dsh': null, //'学科名を入力してください'
// };
final choiceMsgs = {
  'ph': '選択してください',
  'psh': null, //'都道府県名を入力してください',
  'uh': '選択してください',
  'ush': null, //'大学名を入力してください',
  'fh': '選択してください',
  'fsh': null, //'学部名を入力してください',
  'dh': '選択してください',
  'dsh': null, //'学科名を入力してください'
};

final Map<String, String> prefectures = {
  '北海道': '01',
  '青森県': '02',
  '岩手県': '03',
  '宮城県': '04',
  '秋田県': '05',
  '山形県': '06',
  '福島県': '07',
  '茨城県': '08',
  '栃木県': '09',
  '群馬県': '10',
  '埼玉県': '11',
  '千葉県': '12',
  '東京都': '13',
  '神奈川県': '14',
  '新潟県': '15',
  '富山県': '16',
  '石川県': '17',
  '福井県': '18',
  '山梨県': '19',
  '長野県': '20',
  '岐阜県': '21',
  '静岡県': '22',
  '愛知県': '23',
  '三重県': '24',
  '滋賀県': '25',
  '京都府': '26',
  '大阪府': '27',
  '兵庫県': '28',
  '奈良県': '29',
  '和歌山県': '30',
  '鳥取県': '31',
  '島根県': '32',
  '岡山県': '33',
  '広島県': '34',
  '山口県': '35',
  '徳島県': '36',
  '香川県': '37',
  '愛媛県': '38',
  '高知県': '39',
  '福岡県': '40',
  '佐賀県': '41',
  '長崎県': '42',
  '熊本県': '43',
  '大分県': '44',
  '宮崎県': '45',
  '鹿児島県': '46',
  '沖縄県': '47',
};
