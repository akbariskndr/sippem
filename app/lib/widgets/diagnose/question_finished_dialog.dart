import 'package:flutter/material.dart';

class QuestionFinishedDialog extends StatelessWidget {
  final Function onConfirm;
  final Function onCancel;

  QuestionFinishedDialog({this.onConfirm, this.onCancel});

  RaisedButton _buildButton(String text, Color color, Function callback) {
    return RaisedButton(
      child: Text(
        text,
        style: TextStyle(
          color: Color.fromRGBO(254, 254, 254, 1),
          fontSize: 18.0,
        ),
      ),
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
      ),
      onPressed: callback,
    );
  }

  Padding _buildActionButtons(buttonBottomPadding) {
    return Padding(
      padding: EdgeInsets.only(bottom: buttonBottomPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildButton('Tidak', Color.fromRGBO(246, 67, 96, 1.0), onCancel),
          _buildButton('Iya', Color.fromRGBO(42, 224, 85, 1), onConfirm),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration dialogDecoration = BoxDecoration(
      shape: BoxShape.rectangle,
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(6.0)),
    );

    Expanded textContainer = Expanded(
      child: Row(
        children: <Widget>[
          Container(
            child: Flexible(
              child: Text(
                'Apakah Anda yakin dengan jawaban Anda?',
                style: TextStyle(color: Colors.black, fontSize: 20.0),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );

    return AlertDialog(
      elevation: 80,
      backgroundColor: Colors.transparent,
      content: Container(
        height: 180.0,
        decoration: dialogDecoration,
        child: Column(
          children: <Widget>[
            textContainer,
            _buildActionButtons(8.0),
          ],
        ),
      ),
    );
  }
}