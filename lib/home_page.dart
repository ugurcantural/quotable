// ignore_for_file: prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> listem = [];

  bool icon = true;
  bool translateValue = false;
  bool isPressed = false;

  final translator = GoogleTranslator();

  late Future<dynamic> quote;

  Future<dynamic> quoteLoad() async {
    var response = await Dio().get("https://api.quotable.io/random");

    try {
      return response.data;
    } catch (e) {
      print('Hata! $e Hata!');
    }
  }

  void ChangeLoading() {
    setState(() {
      translateValue = !translateValue;
    });
  }

  @override
  void initState() {
    super.initState();
    quote = quoteLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.fill,
            opacity: .4,
          ),
        ),
        child: FutureBuilder(
          future: quote,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case (ConnectionState.active):
                return Text('Aktive');
                break;
              case (ConnectionState.waiting):
                return Center(child: CircularProgressIndicator(strokeWidth: 1));
                break;
              case (ConnectionState.done):
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      height: MediaQuery.of(context).size.height * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(width: 1, color: Colors.black),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          translateValue
                              ? CircularProgressIndicator(strokeWidth: 1)
                              : SizedBox(),
                          SizedBox(height: 20),
                          Text(
                            '# ${snapshot.data["tags"][0]}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            '${snapshot.data["content"]}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            '${snapshot.data["author"]}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  // color: Colors.blue[100],
                                  shape: BoxShape.circle,
                                  border: Border.all(width: 1),
                                ),
                                child: IconButton(
                                  onPressed: () async {
                                    listem.add(snapshot.data["content"]);
                                    listem.add(snapshot.data["tags"][0]);
                                    ChangeLoading();
                                    isPressed = !isPressed;
                                    if (isPressed == true) {
                                      //translate content
                                      await translator
                                          .translate(snapshot.data["content"],
                                              to: 'tr')
                                          .then((value) =>
                                              snapshot.data["content"] =
                                                  value.toString());
                                      //translate hashtag
                                      await translator
                                          .translate(snapshot.data["tags"][0],
                                              to: 'tr')
                                          .then((value) => snapshot.data["tags"]
                                              [0] = value.toString());
                                    } else {
                                      snapshot.data["content"] = listem[0];
                                      snapshot.data["tags"][0] = listem[1];
                                      listem.clear();
                                    }
                                    ChangeLoading();
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.g_translate_outlined),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(width: 1),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    icon = !icon;
                                    setState(() {});
                                  },
                                  icon: icon
                                      ? Icon(Icons.favorite_border_outlined)
                                      : Icon(
                                          Icons.favorite_outlined,
                                          color: Colors.red,
                                        ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  //color: Colors.blue[100],
                                  shape: BoxShape.circle,
                                  border: Border.all(width: 1),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    icon = true;
                                    isPressed = false;
                                    listem.clear();
                                    quoteLoad();
                                    quote = quoteLoad();
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.refresh_outlined),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                break;
              default:
                return Text('Bilinmeyen Hata!');
            }
          },
        ),
      ),
    );
  }
}
