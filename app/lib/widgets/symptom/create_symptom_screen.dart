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


class CreateSymptomScreen extends StatefulWidget {
  _CreateSymptomScreenState createState() => _CreateSymptomScreenState();
}

class _CreateSymptomScreenState extends State<CreateSymptomScreen> {
  TextEditingController _symptomNameController;
  TextEditingController _symptomQuestionController;
  String symptomName;
  String question;

  @override
  void initState() {
    symptomName = '';
    question = '';
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
              'SIMPAN',
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
    final url = URL + '/symptom/create';

    final data = json.encode(Symptom(0, symptomName, question).toJson());

    final response = await http.post(
      url,
      body: data,
      headers: {'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      String textInfo = 'Penambahan gejala berhasil dilakukan!';
      if (responseData['error']) {
        textInfo = 'Tidak dapat menambahkan gejala, silahkan coba kembali';
      }

      Navigator.pop(context, textInfo);
    }
    else {
      Flushbar(
        message: 'Pastikan Anda mengisi semua field yang ada.',
        duration: Duration(seconds: 2),
      )..show(context);
      // throw Exception(response.body);
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

    final mainContent =  Padding(
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

    return AppScaffold(
      activeItem: DrawerItems.show,
      body: mainContent,
    );
  }
}