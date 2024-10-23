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
                        Text(
                          // Make this either email or personable (check group)
                          appState.loggedInState?.name ?? "Log In",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
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
                  // https://stackoverflow.com/a/52801899
                  SizedBox(
                      height: 525,
                      child: ListView(children: [
                        for ((String, GameState) idGame in appState
                                .loggedInState?.games
                                .where((g) => !g.$2.started) ??
                            [])
                          Container(
                              padding: const EdgeInsets.all(8.0),
                              height: 110,
                              width: 300,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 30),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 79, 78, 78),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(children: [
                                SizedBox(
                                    width: 220,
                                    child: Column(children: [
                                      const Text(
                                        "Open Lobby",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                        ),
                                      ),
                                      const Text(
                                        "Players:",
                                        style: TextStyle(
                                          color: Colors.white,
                                          // fontSize: 20,
                                        ),
                                      ),
                                      // Text("${game.started}"),
                                      // Text("${game.playerIds}"),
                                      Text(
                                        "${idGame.$2.playerNames}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ])),
                                FloatingActionButton(
                                    onPressed: () {
                                      appState.loggedInState
                                          ?.joinLobby(idGame.$1, context);
                                    },
                                    child: const Text("Join"))
                              ])),
                      ]))
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
      ),
    );
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
    state.loggedInState?.makeLobby(context);

    var time = Timestamp.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('In Lobby'),
          //change this to be the list of players in lobby
          content: Consumer<ApplicationState>(builder: (ctx, appState, _) {
            // var l = appState.loggedInState!;
            // var ps = [];
            // if (l.state
            //     case WaitingToJoin(currentGame: EntangledGame currentGame)) {
            //   ps = currentGame.state.playerNames;
            // }
            //
            // return Text('Players $ps');
            return const Text(
                'Players can now join your lobby, press start when ready.');
          }),
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
                state.loggedInState?.startGame();
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
