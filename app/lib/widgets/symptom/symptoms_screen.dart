import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:sippem/def/id_argument.dart';
import 'package:sippem/def/drawer_items.dart';
import 'package:sippem/def/models.dart';
import 'package:sippem/def/url.dart';
import 'package:sippem/themes/color.dart';
import 'package:sippem/widgets/app_scaffold.dart';


class SymptomsScreen extends StatefulWidget {
  _SymptomsState createState() => _SymptomsState();
}

class _SymptomsState extends State<SymptomsScreen> {
  Future<List<Symptom>> _fetchSymptomsList() async {
    final url = URL + '/question';

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body).map<Symptom>((item) {
        return Symptom.fromJson(item);
      }).toList();
    }
    else {
      throw Exception('Fetching diseases list failed!');
    }
  }
  
  Widget _buildTile(int index, String title, Function onTap, Function onLongPress) {
    return Card(
      child: InkWell(
        onLongPress: onLongPress,
        child: ListTile(
          title: Text(title),
        ),
        onTap: onTap,
      ),
    );
  }

  Future<String> _deleteSymptom(int id, context) async {
    final url = URL + '/symptom/$id/destroy';

    final response = await http.post(url);

    String info =  'Berhasil menghapus gejala!';
    if (response.statusCode != 200) {
      info = 'Terjadi kesalahan, silahkan coba kembali';
    }
    return info;
  }

  Widget _buildListView(context, List<Symptom> data) {
    final children = <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('Gejala', style: TextStyle(fontSize: 30),),
      ),
    ];

    final tiles = data.map<Widget>((item) {
      return _buildTile(item.id, item.nama, () async {
        final result = await Navigator.pushNamed(
          context, '/symptom/show',
          arguments: IdArgument(item.id),
        );

        if (result != null) {
          Flushbar(
            message: '$result',
            duration: Duration(seconds: 2),
          )..show(context);
        }

      }, () async {
        final msg = await showDialog(
          context: context,
          builder: (_context) {
            return AlertDialog(
              title: Text('Apakah Anda yakin akan menghapus gejala ${item.nama}?'),
              actions: <Widget>[
                FlatButton(
                  child: Text('BATALKAN'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                FlatButton(
                  child: Text('HAPUS', style: TextStyle(color: AppTheme.dangerButton),),
                  onPressed: () async {
                    final info = await _deleteSymptom(item.id, context);
                    Navigator.of(context).pop(info);
                  } 
                ),
              ],
            );
          }
        );

        if (msg != null) {
          Flushbar(
            message: msg,
            duration: Duration(seconds: 2),
          )..show(context);
          setState((){});
        }
      });
    });

    children.addAll(tiles);

    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        bool isLast = index + 1 == children.length;

        return isLast ? Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: children[index],
        ) : children[index];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      activeItem: DrawerItems.show,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: () async {
          final info = await Navigator.pushNamed(context, '/symptom/create');

          if (info != null) {
            Flushbar(
              message: '$info',
              duration: Duration(seconds: 2),
            )..show(context);
          }
        },
      ),
      body: FutureBuilder<List<Symptom>>(
        future: _fetchSymptomsList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: _buildListView(context, snapshot.data),
            );
          }
          else if (snapshot.hasError) {
            return Center(child: Text('Sepertinya terjadi kesalahan, silahkan coba kembali'),);
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}