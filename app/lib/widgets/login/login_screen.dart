import 'dart:async';
import 'dart:convert';
import 'package:flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sippem/def/url.dart';
import 'package:sippem/provider.dart';
import 'package:sippem/themes/color.dart';
import 'package:sippem/widgets/app_scaffold.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  TextEditingController _usernameInput;
  TextEditingController _passwordInput;
  String username;
  String password;

  @override
  void initState() { 
    super.initState();
    _usernameInput = TextEditingController()
      ..addListener(() {
        setState(() {
          username = _usernameInput.text;
        });
      });
    _passwordInput = TextEditingController()
      ..addListener(() {
        setState(() {
          password = _passwordInput.text;
        });
      });
  }

  Future<bool> _submitForm(context) async {
    bool loggedIn = false;
    if (_loginFormKey.currentState.validate()) {
      final url = URL + '/login';
      final data = json.encode({
        'username': username,
        'password': password,
      });

      final response = await http.post(url, body: data, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedId', true);
        LoginProvider.update(context, true);

        loggedIn = true;
      }
    }
    return loggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text('Masuk', style: TextStyle(fontSize: 30)),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 35, right: 35),
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text('Username', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 15, top: 10),
                          child: Container(
                            height: 45,
                            child: TextFormField(
                              controller: _usernameInput,
                              validator: (val) {
                                if (val.isEmpty) {
                                  return 'Silahkan isi username Anda';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0,),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0,),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0,color: AppTheme.dangerButton),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text('Password', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 15, top: 10),
                          child: Container(
                            height: 45,
                            child: TextFormField(
                              controller: _passwordInput,
                              obscureText: true,
                              validator: (val) {
                                if (val.isEmpty) {
                                  return 'Silahkan isi password Anda';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0,),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0,),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0,color: AppTheme.dangerButton),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: ButtonTheme(
                    minWidth: 200.0,
                    height: 60.0,
                    child: RaisedButton(
                      child: Text(
                        'MASUK',
                        style: TextStyle(color: Colors.white, fontSize: 16)
                      ),
                      onPressed: () async {
                        final loggedIn = await _submitForm(context);
                        if (loggedIn) {
                          Navigator.of(context).pop('Berhasil melakukan login!');
                        }
                        Flushbar(
                          message: 'Username atau password Anda salah!',
                          duration: Duration(seconds: 2),
                        )..show(context);
                      },
                      color: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: ButtonTheme(
                    minWidth: 200.0,
                    height: 60.0,
                    child: RaisedButton(
                      child: Text('KEMBALI',
                        style: TextStyle(color: Colors.white, fontSize: 16)
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      color: Color.fromRGBO(179, 179, 179, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}