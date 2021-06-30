import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:factsy/quiz.dart';
import 'dart:math';
import 'package:flutter_svg/svg.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AnimatedSplashScreen(
        splash: SvgPicture.asset(
          "icons/factsy.svg",
        ),
        nextScreen: HomePage(),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.blueAccent,
        duration: 3000,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Quiz quiz;
  List<Results> results;
  Color c;
  Random random = Random();
  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchQuestions() async {
    const String QuestLink = "https://opentdb.com/api.php?amount=25";
    var res = await http.get(Uri.parse(QuestLink));
    var decRes = jsonDecode(res.body);
    print(decRes);
    c = Colors.white;
    quiz = Quiz.fromJson(decRes);
    results = quiz.results;
  }

  @override
  Widget build(BuildContext context) {
    // Color fgColor = Color.fromRGBO(244, 244, 248, 1.0);
    Color bgColor = Color.fromRGBO(51, 51, 51, 1.0);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SvgPicture.asset(
          "icons/factsy.svg",
          height: size.height * 0.05,
        ),
        elevation: 1.0,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: bgColor,
        child: RefreshIndicator(
          onRefresh: fetchQuestions,
          child: FutureBuilder(
              future: fetchQuestions(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text('Press button to start.');
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.done:
                    if (snapshot.hasError) return errorData(snapshot);
                    return questionList();
                }
                return null;
              }),
        ),
      ),
    );
  }

  Padding errorData(AsyncSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Error: ${snapshot.error}',
            style: TextStyle(
              fontFamily: "morenaSemiBold",
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            child: Text(
              "Try Again",
              style: TextStyle(
                fontFamily: "morenaSemiBold",
              ),
            ),
            onPressed: () {
              fetchQuestions();
              setState(() {});
            },
          )
        ],
      ),
    );
  }

  ListView questionList() {
    Color fgColor = Color.fromRGBO(69, 69, 69, 1.0);
    Color bgColor = Color.fromRGBO(51, 51, 51, 1.0);
    // Color bgColor = Color.fromRGBO(231, 231, 234, 1.0);
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        clipBehavior: Clip.hardEdge,
        borderOnForeground: true,
        color: fgColor,
        elevation: 2.0,
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 32.0),
          title: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  results[index].question,
                  style: TextStyle(
                    fontFamily: "DevantHorgen",
                    fontSize: 32.0,
                    color: Colors.white,
                    // fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(height: 12.0),
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(60),
                      //     border: Border.all(
                      //       color: Colors.blue,
                      //       width: 1,
                      //     )),
                      FilterChip(
                        tooltip: "category",
                        backgroundColor: bgColor,
                        pressElevation: 0.0,
                        elevation: 0.0,
                        label: Text(
                          "#" + results[index].category,
                          style: TextStyle(
                            fontFamily: "didot",
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        onSelected: (b) {},
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      FilterChip(
                        tooltip: "Level",
                        backgroundColor: bgColor,
                        pressElevation: 0.0,
                        elevation: 0.0,
                        label: Text(
                          "Lev : " + results[index].difficulty,
                          style: TextStyle(
                            fontFamily: "didot",
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        onSelected: (b) {},
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: bgColor,
            child: Text(
              results[index].type.startsWith("m") ? "M" : "B",
              style: TextStyle(
                fontFamily: "soulmaze",
              ),
            ),
          ),
          children: results[index].allAnswers.map((m) {
            return AnswerWidget(results, index, m);
          }).toList(),
        ),
      ),
    );
  }
}

class AnswerWidget extends StatefulWidget {
  final List<Results> results;
  final int index;
  final String m;

  AnswerWidget(this.results, this.index, this.m);

  @override
  _AnswerWidgetState createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  Color c = Colors.white;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          if (widget.m == widget.results[widget.index].correctAnswer) {
            c = Colors.green;
          } else {
            c = Colors.red;
          }
        });
      },
      title: Text(
        widget.m,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
