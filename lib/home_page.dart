import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' // new
    hide
        EmailAuthProvider,
        PhoneAuthProvider; // new
import 'package:flutter/material.dart'; // new
import 'package:provider/provider.dart'; // new

import 'app_state.dart'; // new
import 'game_state.dart';
import 'src/authentication.dart'; // new
//import 'src/widgets.dart';                  // new

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blackjack: The Digital Realm',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 161, 115, 238)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Blackjack: The Digital Realm'),
        ),
        body: Consumer<ApplicationState>(
          builder: (context, appState, _) => Stack(
            children: <Widget>[
              Container(
                color: Colors.black,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            // Make this either email or personable (check group)
                            'Name',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                            ),
                          ),
                          AuthFunc(
                            loggedIn: appState.loggedIn,
                            signOut: () {
                              FirebaseAuth.instance.signOut();
                            },
                          ),
                        ],
                      ),
                    ),
                    for (GameState game
                        in appState.games.where((g) => !g.started))
                      Container(
                          padding: const EdgeInsets.all(8.0),
                          height: 90,
                          margin: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 79, 78, 78),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(children: [
                            // Text("${game.started}"),
                            // Text("${game.playerIds}"),
                            Text("${game.playerNames}"),
                            TextButton(onPressed: () {
                              appState.joinLobby(game.docId, context);
                            }, child: const Text("Join"))
                          ])),
                  ],
                ),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      //handle dialog decision
                      handleMakeNewLobby(context);
                    },
                    child: const Text('Make New Lobby +'),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // Decision for which screen
  //https://www.youtube.com/watch?v=alp45Szg7Vk
  void handleMakeNewLobby(BuildContext context) {
    bool loggedIn =
        Provider.of<ApplicationState>(context, listen: false).loggedIn;
    //bool to call which
    if (loggedIn) {
      showLobbyDialog(context);
    } else {
      showSignInDialog(context);
    }
  }

  // Show when signed in (display functional d. box)
  void showLobbyDialog(BuildContext context) {
    //TODO(colin): Testing, remove later
    var state = Provider.of<ApplicationState>(context, listen: false);
    state.makeLobby(context);

    var time = Timestamp.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Start Game Diolog'),
          //change this to be the list of players in lobby
          content: Text('[ insert list of players here $time]'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                //close the screen
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                state.startGame();
                //Closes screen when clicked (change this later)
                Navigator.of(context).pop();
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
  }

  // Show when not signed in
  void showSignInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please Sign In'),
          content:
              const Text('You need to sign in to join or create a new lobby.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                //same as above (change to have different option if need)
                Navigator.of(context).pop();
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }
}
