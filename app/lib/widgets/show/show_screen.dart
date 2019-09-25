import 'package:flutter/material.dart';
import 'package:sippem/def/drawer_items.dart';
import '../app_scaffold.dart';
import '../../themes/color.dart';

class ShowScreen extends StatelessWidget {
  Widget _buildButton(String title, Function onPressed) {
    return ButtonTheme(
      minWidth: 200.0,
      height: 60.0,
      child: RaisedButton(
        child: Text(
          title,
          style: TextStyle(color: AppTheme.textBlack, fontSize: 16)
        ),
        onPressed: onPressed,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      activeItem: DrawerItems.show,
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 35,),
              _buildButton('LIHAT PENYAKIT', () => Navigator.pushNamed(context, '/disease')),
              SizedBox(height: 20,),
              _buildButton('LIHAT GEJALA', () => Navigator.pushNamed(context, '/symptom')),
            ],
          ),
      ),
    );
  }
}