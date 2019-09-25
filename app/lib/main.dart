import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sippem/provider.dart';
import 'package:sippem/widgets/home/home_screen.dart';
import 'package:sippem/widgets/login/login_screen.dart';
import 'package:sippem/widgets/diagnose/diagnose_screen.dart';
import 'package:sippem/widgets/diagnose/diagnose_result_screen.dart';
import 'package:sippem/widgets/show/show_screen.dart';
import 'package:sippem/widgets/disease/diseases_screen.dart';
import 'package:sippem/widgets/disease/show_disease_screen.dart';
import 'package:sippem/widgets/disease/create_disease_screen.dart';
import 'package:sippem/widgets/symptom/symptoms_screen.dart';
import 'package:sippem/widgets/symptom/show_symptom_screen.dart';
import 'package:sippem/widgets/symptom/create_symptom_screen.dart';
import 'package:sippem/themes/color.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  Future<bool> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final res = prefs.getBool('isLoggedIn') ?? false;
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return LoginProvider(
            isLoggedIn: snapshot.data,
            child: MaterialApp(
              title: 'Sippem',
              theme: ThemeData(
                accentColor: AppTheme.primaryColor,
                fontFamily: 'Segoe-UI',
              ),
              initialRoute: '/',
              routes: {
                '/': (context) => HomeScreen(),
                '/login': (context) => LoginScreen(),
                '/diagnose': (context) => DiagnoseScreen(),
                '/diagnose/result': (context) => DiagnoseResultScreen(),
                '/show': (context) => ShowScreen(),
                '/disease': (context) => DiseasesScreen(),
                '/disease/create': (context) => CreateDiseaseScreen(),
                '/disease/show': (context) => ShowDiseaseScreen(),
                '/symptom': (context) => SymptomsScreen(),
                '/symptom/create': (context) => CreateSymptomScreen(),
                '/symptom/show': (context) => ShowSymptomScreen(),
              },
            ),
          );
        }
        else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString(), textDirection: TextDirection.ltr,),
          );
        }
        else {
          return Center(child: CircularProgressIndicator(),);
        }
      }
    );
  }
}