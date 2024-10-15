import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 161, 115, 238)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Black Jack: The Digital Realm'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        //found source for backbutton here: https://www.youtube.com/watch?v=YoLbuAiYOi4
        leading: BackButton( 
          onPressed: () {
            //navigate to a different page here
    },
  ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.black,
            child: Column(
              children: <Widget>[
                Padding(
                  //make this text "Score" to be in be middle alignment (done)
                  padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        'Score',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 65,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 90,
                  margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 79, 78, 78),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}