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

class ShowDiseaseScreen extends StatelessWidget{
  Future<DiseaseDetail> _fetchDiseaseDetail(int id) async {
    final url = URL + '/disease/$id';

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return DiseaseDetail.fromJson(json.decode(response.body));
    }
    else {
      throw Exception('Failed to fetch disease detail!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final IdArgument diseaseArgument = ModalRoute.of(context).settings.arguments;

    return AppScaffold(
      activeItem: DrawerItems.show,
      body: FutureBuilder<DiseaseDetail>(
        future: _fetchDiseaseDetail(diseaseArgument.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ShowDiseaseScreenReady(snapshot.data);
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

class ShowDiseaseScreenReady extends StatefulWidget {
  final DiseaseDetail diseaseDetail;

  ShowDiseaseScreenReady(this.diseaseDetail);

  _ShowDiseaseScreenReadyState createState() => _ShowDiseaseScreenReadyState();
}

class _ShowDiseaseScreenReadyState extends State<ShowDiseaseScreenReady> {
  List<Symptom> symptoms;
  TextEditingController _controller;
  String diseaseName;

  @override
  void initState() {
    symptoms = widget.diseaseDetail.symptoms;
    diseaseName = widget.diseaseDetail.disease.nama;
    _controller = TextEditingController(text: diseaseName)
      ..addListener(() {
        setState(() {
          diseaseName = _controller.text;
        });
      });

    super.initState();
  }

  @override
  void dispose() {
    symptoms = null;
    diseaseName = null;
    _controller = null;

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

  Widget _buildDiseaseNameInput(String diseaseName) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15, top: 10),
      child: Container(
        height: 45,
        child: TextFormField(
          controller: _controller,
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

  Widget _buildTile(int index, String title, bool checked, Function onTap) {
    return InkWell(
      onTap: () => onTap(index, !checked),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(title, style: TextStyle(fontSize: 13)),
            trailing: Checkbox(
              onChanged: (val) => onTap(index, val),
              value: checked,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Divider(height: 1, color: Colors.black,),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseSymptomsInput() {
    return Padding(
      padding: EdgeInsets.only(bottom: 15, top: 10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: ListView.builder(
          itemCount: symptoms.length,
          itemBuilder: (context, index)
            => _buildTile(index, symptoms[index].nama, symptoms[index].checked, (i, checked) {
              setState(() {
                symptoms[index].checked = checked;
              });
            }),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final textNamaPenyakit = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text('Nama Penyakit', style: TextStyle(fontSize: 16)),
      ],
    );

    final textGejalaPenyakit = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text('Gejala Penyakit', style: TextStyle(fontSize: 16)),
      ],
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        textNamaPenyakit,
        _buildDiseaseNameInput(diseaseName),
        textGejalaPenyakit,
        Expanded(
          child: _buildDiseaseSymptomsInput(),
        ),
      ],
    );
  }

  Future<void> _submitForm(context) async {
    final diseaseId = widget.diseaseDetail.disease.id;
    final url = URL + '/disease/$diseaseId';

    final symptomsIds = symptoms.where((i) => i.checked).toList().map<int>((i) => i.id).toList();
    final data = json.encode(DiseaseSymptomRequest(diseaseId, diseaseName, symptomsIds).toJson());

    final response = await http.post(
      url,
      body: data,
      headers: {'Content-Type': 'application/json'}
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      String textInfo = 'Detail dari penyakit berhasil diubah!';
      if (responseData['error']) {
        textInfo = 'Tidak dapat mengubah detail penyakit, silahkan coba kembali';
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
          Text('Detail Penyakit', style: TextStyle(fontSize: 30)),
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