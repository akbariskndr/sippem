import 'dart:async';
import 'dart:convert';
import 'package:flushbar/flushbar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sippem/def/id_argument.dart';
import 'package:sippem/def/drawer_items.dart';
import 'package:sippem/def/models.dart';
import 'package:sippem/def/url.dart';
import 'package:sippem/themes/color.dart';
import 'package:sippem/widgets/app_scaffold.dart';

class ShowSymptomScreen extends StatelessWidget{
  Future<Symptom> _fetchSymptomDetail(int id) async {
    final url = URL + '/symptom/$id';

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Symptom.fromJson(json.decode(response.body));
    }
    else {
      throw Exception('Failed to fetch symptom detail!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final IdArgument idArgument = ModalRoute.of(context).settings.arguments;

    return AppScaffold(
      activeItem: DrawerItems.show,
      body: FutureBuilder<Symptom>(
        future: _fetchSymptomDetail(idArgument.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ShowSymptomScreenReady(snapshot.data);
          }
          else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()),);
          }
          return Center(child: CircularProgressIndicator(),);
        },
      ),
    );
  }

  
}

class ShowSymptomScreenReady extends StatefulWidget {
  final Symptom symptom;

  ShowSymptomScreenReady(this.symptom);

  _ShowSymptomScreenReadyState createState() => _ShowSymptomScreenReadyState(symptom: symptom);
}

class _ShowSymptomScreenReadyState extends State<ShowSymptomScreenReady> {
  Symptom symptom;
  TextEditingController _symptomNameController;
  TextEditingController _symptomQuestionController;
  String symptomName;
  String question;

  _ShowSymptomScreenReadyState({this.symptom});

  @override
  void initState() {
    symptomName = symptom.nama;
    question = symptom.pertanyaan;
    _symptomNameController = TextEditingController(text: symptomName)
      ..addListener(() {
        setState(() {
          symptomName = _symptomNameController.text;
        });
      });
    _symptomQuestionController = TextEditingController(text: question)
      ..addListener(() {
        setState(() {
          question = _symptomQuestionController.text;
        });
      });

    super.initState();
  }

  @override
  void dispose() {
    symptom = null;
    symptomName = null;
    question = null;
    _symptomNameController = null;
    _symptomQuestionController = null;

    super.dispose();
  }

  Widget _buildButtons(context) {
    final buttonRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ButtonTheme(
          minWidth: 100.0,
          height: 50.0,
          child: RaisedButton(
            child: Text(
              'KEMBALI',
              style: TextStyle(color: Colors.white, fontSize: 16)
            ),
            onPressed: () => Navigator.pop(context),
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
              'UBAH',
              style: TextStyle(color: Colors.white, fontSize: 16)
            ),
            onPressed: () async => await _submitForm(context),
            color: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
            ),
          ),
        ),
      ],
    );
    
    return Container(
      padding: EdgeInsets.only(top: 10,),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          buttonRow,
        ],
      ),
    );
  }

  Widget _buildSymptomNameInput() {
    return Padding(
      padding: EdgeInsets.only(bottom: 15, top: 10),
      child: Container(
        height: 45,
        child: TextFormField(
          controller: _symptomNameController,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.0,),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.0,),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSymptomQuestionInput() {
    return Padding(
      padding: EdgeInsets.only(bottom: 15, top: 10),
      child: Container(
        child: SizedBox(
          height: double.infinity,
          child: TextField(
              maxLines: 100,
              controller: _symptomQuestionController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1.0,),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1.0,),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final textNamaGejala = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text('Nama Gejala', style: TextStyle(fontSize: 16)),
      ],
    );

    final textPertanyaan = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text('Pertanyaan', style: TextStyle(fontSize: 16)),
      ],
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        textNamaGejala,
        _buildSymptomNameInput(),
        textPertanyaan,
        Expanded(
          child: _buildSymptomQuestionInput(),
        ),
      ],
    );
  }

  Future<void> _submitForm(context) async {
    final symptomId = symptom.id;
    final url = URL + '/symptom/$symptomId';

    final data = json.encode(Symptom(symptomId, symptomName, question).toJson());

    final response = await http.post(
      url,
      body: data,
      headers: {'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      String textInfo = 'Detail dari gejala berhasil diubah!';
      if (responseData['error']) {
        textInfo = 'Tidak dapat mengubah detail gejala, silahkan coba kembali';
      }

      Navigator.pop(context, textInfo);
    }
    else {
      Flushbar(
        message: 'Pastikan Anda mengisi semua field yang ada.',
        duration: Duration(seconds: 2),
      )..show(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final titleText = Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('Detail Gejala', style: TextStyle(fontSize: 30)),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          titleText,
          Expanded(
            flex: 5,
            child: _buildForm(),
          ),
          Expanded(
            flex: 1,
            child: _buildButtons(context),
          ),
        ],
      ),
    );
  }
}