import 'package:flutter/material.dart';

class LoginProvider extends InheritedWidget {
  LoginProvider({Key key, this.child, this.isLoggedIn}) : super(key: key, child: child);

  final Widget child;
  bool isLoggedIn;

  static LoginProvider of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(LoginProvider)as LoginProvider);
  }

  static void update(BuildContext context, bool loggedIn) {
    LoginProvider prov = (context.inheritFromWidgetOfExactType(LoginProvider)as LoginProvider);
    prov.isLoggedIn = loggedIn;
  }

  @override
  bool updateShouldNotify( LoginProvider oldWidget) {
    return oldWidget.isLoggedIn != isLoggedIn;
  }
}