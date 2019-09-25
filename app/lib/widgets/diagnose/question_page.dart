import 'package:flutter/material.dart';
import 'package:sippem/def/fact.dart';

class QuestionPage extends StatelessWidget {
  final List<Fact> facts;
  final Function onChange;
  final int currentPage;
  final int totalPage;

  QuestionPage({
    this.facts,
    this.onChange,
    this.currentPage,
    this.totalPage,
  });

  Widget _buildListTile(index) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      height: 100,
      child: InkWell(
        onTap: () => this.onChange(index, !facts[index].answer),
        child: Card(
          elevation: 2.5,
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
          child: ListTile(
            title: Text(
              facts[index].question,
              style: TextStyle(fontSize: 15.0),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Checkbox(
                  value: facts[index].answer,
                  onChanged: (val) => this.onChange(index, val),
                ),
              ],
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listView =  ListView.builder(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
      itemCount: facts.length,
      itemBuilder: (context, index) {
        return _buildListTile(index);
      },
    );
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: listView,
        ),
        // _buildNavigation(context),
      ],
    );
  }

}