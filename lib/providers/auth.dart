import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/firebaseException.dart';
import 'dart:developer';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;
  static const webApiKey = 'AIzaSyCu0lDm2UEc6BdI7QsSg41mtf_bq6GhqqA';

  bool get isAuth {
    return _token != null;
  }

  String? get UserId {
    return _userId;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
  }

  Future _authenticate(
      String? username, String? password, String? segmentUrl) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$segmentUrl?key=$webApiKey';
    try {
      //
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'email': username,
            'password': password,
            'returnSecureToken': 'true',
          },
        ),
      );

      //--------------------------------------------------
      final responseData = json.decode(response.body);
      final prettyString =
          const JsonEncoder.withIndent('  ').convert(responseData);
      log(prettyString);
      //--------------------------------------------------

      //check responData contains null?
      if (responseData['error'] != null) {
        print('on error responseData $responseData');
        throw FirebaseException(responseData['error']['message']);
      }

      //--------------------------------------------------
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      //--------------------------------------------------

      //--------------------------------------------------
      if (responseData['expiresIn'] != null) {
        _expiryDate = DateTime.now()
            .add(Duration(seconds: int.parse(responseData['expiresIn'])));
        _autoLogout;
      }
      //--------------------------------------------------

      //--------------------------------------------------
      final _prefs = await SharedPreferences.getInstance();
      final _prefsData = json.encode({
        'token': _token,
        'userId': _userId,
        'expireDate': _expiryDate!.toIso8601String(),
      });
      //--------------------------------------------------

      //--------------------------------------------------
      print('SAVE AUTH $_prefsData');
      _prefs.setString('userData', _prefsData);
      notifyListeners();
    } catch (error) {
      throw (error);
    }
    //--------------------------------------------------
  }

  //--------------------------------------------------
  Future<void> signUp(String? _email, String? _password) async {
    return _authenticate(_email, _password, 'signUp');
  }
  //--------------------------------------------------

  //--------------------------------------------------
  Future<void> signin(String? _email, String? _password) async {
    return _authenticate(_email, _password, 'signInWithPassword');
  }
  //--------------------------------------------------

  //--------------------------------------------------
  Future<bool> tryAutoLogin() async {
    print('IN tryAutoLogin ');

    //
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      print('not detected key');
      return false;
    }

    print('============ 1 ============');

    //--------------------------------------------------------------
    final decodedData = prefs.getString('userData');
    final extractedData = json.decode(decodedData!);
    final extractedAsMap = extractedData as Map<String, dynamic>;
    final strExpireDateAs = extractedAsMap['expireDate'] as String;
    final expiryDate = DateTime.parse(strExpireDateAs);
    print('============ 2 ============ $expiryDate');
    //--------------------------------------------------------------

    //--------------------------------------------------------------
    if (!expiryDate.isAfter(DateTime.now())) {
      print('Expire !');
      return false;
    }

    _token = extractedData['token'];
    _userId = extractedData['userId'];

    //
    print('detected token $_token');

    //
    _expiryDate = expiryDate;

    //
    notifyListeners();
    _autoLogout();
    return true;
  }
  //--------------------------------------------------

  //--------------------------------------------------
  void logout() async {
    log('logout()');
    _userId = null;
    _expiryDate = null;
    _token = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    final decodedData = prefs.remove('userData');
    notifyListeners();
  }
  //--------------------------------------------------

  //--------------------------------------------------
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer = null;
    }
    final timeToExpire = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), logout);
  }
  //--------------------------------------------------
}
