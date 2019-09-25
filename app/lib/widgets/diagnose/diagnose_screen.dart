import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:sippem/def/fact_argument.dart';
import '../../def/fact.dart';
import '../../def/drawer_items.dart';
import 'package:sippem/themes/color.dart';
import '../app_scaffold.dart';
import 'question_page.dart';
import 'question_finished_dialog.dart';
import 'package:sippem/def/url.dart';


class DiagnoseScreen extends StatelessWidget {
  Future<List<Fact>> _fetchQuestions() async {
    final url = URL + '/question';

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body).map<Fact>((item) {
        return Fact.fromJson(item);
      }).toList();
    }
    else {
      throw Exception('Fetching questions failed!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      activeItem: DrawerItems.diagnose,
      body: FutureBuilder<List<Fact>>(
        future: _fetchQuestions(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final chunkSize = 4;
            final facts = snapshot.data;
            final totalpage = (facts.length / chunkSize).ceil(); 

            return DiagnoseScreenReady(
              facts: facts,
              totalPage: totalpage,
              chunkSize: chunkSize,
            );
          }
          else if (snapshot.hasError) {
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
      )
    );
  }
}

class DiagnoseScreenReady extends StatefulWidget {
  final List<Fact> facts;
  final int totalPage;
  final int chunkSize;

  DiagnoseScreenReady({this.facts, this.totalPage, this.chunkSize});

  @override
  _DiagnoseScreenReadyState createState() => _DiagnoseScreenReadyState(facts: facts);
}

class _DiagnoseScreenReadyState extends State<DiagnoseScreenReady> {
  PageController controller = PageController(initialPage: 0);
  List<Fact> facts;
  int currentPage = 0;
  bool hasReachedEnd = true;

  _DiagnoseScreenReadyState({this.facts});
  
  void _onQuestionChange(index, val) {
    int realIndex = (currentPage * widget.chunkSize) + index;

    setState(() {
      facts[realIndex].answer = val;
    });
  }

  List<Fact> _getChunkedFacts(currentChunk) {
    int start = currentChunk * widget.chunkSize;
    int end = start + widget.chunkSize;
    if (end > facts.length) {
      end = facts.length;
    }
    return facts.sublist(start, end);
  }

  void _onCompleted(context) {
    showDialog(
      context: context,
      builder: (context) {
        return QuestionFinishedDialog(
          onConfirm: () { 
            Navigator.pushNamed(
              context, '/diagnose/result',
              arguments: FactArgument(facts),
            );
          },
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  Widget _buildPageView() {
    return PageView(
      onPageChanged: (page) {
        setState(() {
          if (page + 1 == widget.totalPage) {
            hasReachedEnd = true;
          }
          currentPage = page;
        });
      },
      controller: controller,
      children: List.generate(widget.totalPage, (index) {
        return QuestionPage(
          currentPage: currentPage,
          totalPage: widget.totalPage,
          facts: _getChunkedFacts(index),
          onChange: _onQuestionChange,
        );
      }),
    );
  }

  Widget _buildQuestionPage(pageView) {
    final dotsIndicator = Padding(
      padding: EdgeInsets.only(bottom: 25),
      child: DotsIndicator(
        dotsCount: widget.totalPage,
        position: currentPage,
        decorator: DotsDecorator(
          activeColor: AppTheme.secondaryColor,
          size: const Size.square(9.0),
          activeSize: const Size(18.0, 9.0),
          activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );

    final saveButton = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 3.5,
            spreadRadius: 0.5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            child: Text('SIMPAN', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: !hasReachedEnd ? null : () => _onCompleted(context),
          ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: pageView,
        ),
        dotsIndicator,
        saveButton,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageView = _buildPageView();
    final questionPage = _buildQuestionPage(pageView);
    
    return questionPage;
  }
}