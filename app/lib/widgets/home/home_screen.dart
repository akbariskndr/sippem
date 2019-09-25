import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sippem/def/drawer_items.dart';
import 'package:sippem/provider.dart';
import 'package:sippem/themes/color.dart';
import 'package:sippem/widgets/app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _buildLogo() {
    return Expanded(
      child: Center(
        child: Text(
          "sippem",
          style: TextStyle(
            fontFamily: 'Moderna',
            color: AppTheme.primaryColor,
            fontSize: 60.0,
          ),
        ),//Image.asset('assets/img/logo.png'),
      ),
    );
  }

  Widget _buildButtons(bool loggedIn, context) {
    final diagnoseStartButton = Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: ButtonTheme(
        minWidth: 200.0,
        height: 60.0,
        child: RaisedButton(
          child: Text('MULAI DIAGNOSIS',
            style: TextStyle(color: Colors.white, fontSize: 16)
          ),
          onPressed: () => Navigator.pushNamed(context, '/diagnose'),
          color: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
        ),
      ),
    );
    
    final adminLoginButton = Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: ButtonTheme(
        minWidth: 200.0,
        height: 60.0,
        child: RaisedButton(
          child: Text(
            !loggedIn ? 'ADMIN? MASUK SINI' : 'KELUAR',
            style: TextStyle(color: Colors.white, fontSize: 16)
          ),
          onPressed: () async {
            if (loggedIn) {
              final prefs = await SharedPreferences.getInstance();
              prefs.remove('isLoggedIn');
              LoginProvider.update(context, false);
              setState((){});
            }
            else {
              final info = await Navigator.pushNamed(context, '/login');
              if (info != null) {
                Flushbar(
                  message: info,
                  duration: Duration(seconds: 2),
                )..show(context);
              }
            }
          },
          color: !loggedIn ? AppTheme.secondaryColor : Color.fromRGBO(179, 179, 179, 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
        ),
      ),
    );

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          diagnoseStartButton,
          adminLoginButton,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final loggedIn = LoginProvider.of(context).isLoggedIn;

    return AppScaffold(
      activeItem: DrawerItems.home,
      body:Center(
        child: Column(
          children: <Widget>[
            _buildLogo(),
            _buildButtons(loggedIn, context),
          ],
        ),
      ),
    );
  }
}