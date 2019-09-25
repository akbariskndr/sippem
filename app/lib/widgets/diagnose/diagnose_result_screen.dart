import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sippem/def/fact_argument.dart';
import '../../def/fact.dart';
import '../../def/url.dart';
import '../../def/drawer_items.dart';
import '../../def/diagnose_result.dart';
import 'package:sippem/themes/color.dart';
import '../app_scaffold.dart';

class DiagnoseResultScreen extends StatelessWidget {
  
  Future<DiagnoseResult> _getResult(facts) async {
    final url = URL + '/calculate';

    final body = json.encode({"data": facts});

    final response = await http.post(url, body: body, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      return DiagnoseResult.fromJson(json.decode(response.body));
    } else {
      throw Exception(response.statusCode);
    }
  }

  Widget _buildResultCard(String diseaseResult, String diseaseProb) {
    return Container(
      height: 160,
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Berdasarkan diagnosis sistem kami,', style: TextStyle(fontSize: 15),),
              Text('Anda menderita penyakit', style: TextStyle(fontSize: 15),),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('$diseaseResult', textAlign: TextAlign.center, style: TextStyle(fontSize: 25,),),
              ),
              Text('($diseaseProb)', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherDiseaseProbRow(int index, String disease, String prob) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('$index. $disease'),
        Text('($prob)'),
      ],
    );
  }

  Widget _buildOtherDiseaseCard(List<String> otherDiseases, List<String> otherDiseasesProb) {
    List<Widget> contents = [
      Text('Dengan beberapa kemungkinan'),
      Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Text('Penyakit lain'),
      ),
    ];

    contents.addAll(List.generate(otherDiseases.length, (i) {
      return _buildOtherDiseaseProbRow(i + 1, otherDiseases[i], otherDiseasesProb[i]);
    }));

    return Container(
      height: 160,
      width: double.infinity,
      padding: EdgeInsets.only(top: 5),
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: contents,
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context, DiagnoseResult result) {
    final thirdCard = Container(
      width: double.infinity,
      height: 100,
      padding: EdgeInsets.only(top: 5, bottom: 10),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Silahkan hubungi dokter mata Anda'),
            Text('untuk diagnosis yang lebih akurat'),
          ],
        ),
      ),
    );

    final buttons = Container(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ButtonTheme(
            minWidth: 100.0,
            height: 50.0,
            child: RaisedButton(
              child: Text(
                'HOME',
                style: TextStyle(color: Colors.white, fontSize: 16)
              ),
              onPressed: () => Navigator.pushNamed(context, '/'),
              color: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
            ),
          ),
          ButtonTheme(
            minWidth: 100.0,
            height: 50.0,
            child: RaisedButton(
              child: Text(
                'ULANGI',
                style: TextStyle(color: Colors.white, fontSize: 16)
              ),
              onPressed: () => Navigator.pushNamed(context, '/diagnose'),
              color: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
            ),
          ),
        ],
      )
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildResultCard(result.diseaseResult, result.diseaseProb),
          _buildOtherDiseaseCard(result.otherDiseases, result.otherDiseasesProb),
          thirdCard,
          buttons,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FactArgument args = ModalRoute.of(context).settings.arguments;

    return AppScaffold(
      activeItem: DrawerItems.diagnose,
      body: FutureBuilder<DiagnoseResult>(
        future: _getResult(args.facts),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildResultScreen(context, snapshot.data);
          }
          else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
              child: Text('Maaf, sepertinya terjadi kesalahan.'),
            );
          }
          else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      ),
    );
    
  }
}