import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'game_state.dart';

class EntangledGame {
  EntangledGame({required this.state, required this.docId});
  GameState state;
  String docId;

  DocumentReference get _ref =>
      FirebaseFirestore.instance.collection('games').doc(docId);

  Future<void> push() {
    //https://stackoverflow.com/a/59020046
    return _ref.update(state.serialize());
  }

  Future<void> pull() {
    return _ref.get().then((snap) {
      state = GameState.deserialize(snap.data() as Map<String, dynamic>);
    });
  }

  static Future<EntangledGame> fromState(GameState lobby) {
    return FirebaseFirestore.instance
        .collection('games')
        .add(lobby.serialize())
        .then((ref) => EntangledGame(state: lobby, docId: ref.id));
  }

  static Future<EntangledGame> fromId(String id) {
    return FirebaseFirestore.instance.collection('games').doc(id).get().then(
        (snap) => EntangledGame(
            state: GameState.deserialize(snap.data() as Map<String, dynamic>), docId: id));
  }
}

sealed class BlackjackState {}

class NoBlackjack extends BlackjackState {}

class WaitingToJoin extends BlackjackState {
  WaitingToJoin({required this.currentGame, required this.navigationContext});

  EntangledGame currentGame;
  BuildContext navigationContext;
}

class PlayingBlackjack extends BlackjackState {
  PlayingBlackjack({required this.currentGame});
  EntangledGame currentGame;
}

class LoggedInState {
  LoggedInState(void Function() notifyChangeCallback) {
    gameSubscription = FirebaseFirestore.instance
        .collection('games')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      switch (state) {
        case NoBlackjack():
          break;
        case WaitingToJoin(
            currentGame: EntangledGame currentGame,
            navigationContext: BuildContext ctx
          ):
          currentGame.pull().then((_) {
            print("IN WAIT LOOP< START STAUTS <<${currentGame.state.started}");
            if (currentGame.state.started) {
              if (ctx.mounted) {
                print("Moving to new page!");
                // TODO(colin) change back to pushReplacement eventually
                ctx.push("/blackjack");
                state = PlayingBlackjack(currentGame: currentGame);
              } else {
                print("WARNING! context hack broke 2!!!");
              }
            }
          });
          break;
        case PlayingBlackjack():
          break;
      }

      games = [];
      for (final document in snapshot.docs) {
        games.add(
          (document.reference.id,
        GameState.deserialize(
          document.data(),
        )));
      }

      notifyChangeCallback();
    });
  }

  late StreamSubscription<QuerySnapshot> gameSubscription;
  List<(String,GameState)> games = [];
  BlackjackState state = NoBlackjack();

  void deinit() {
    gameSubscription.cancel();
  }

  void makeLobby(BuildContext ctx) async {
    var name =
        FirebaseAuth.instance.currentUser!.displayName ?? "PLACEHOLDER_NAME";
    var uid = FirebaseAuth.instance.currentUser!.uid;

    var lobby = GameState(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        started: false,
        playerNames: [name],
        playerIds: [uid],
        cards: []);

    var e = await EntangledGame.fromState(lobby);

    if (ctx.mounted) {
      state = WaitingToJoin(currentGame: e, navigationContext: ctx);
    } else {
      print("WARNING! The weird context hack broke!");
    }
  }

  void joinLobby(String docId, BuildContext ctx) async {
    print("JOINING LOBBY");
    var e = await EntangledGame.fromId(docId);
    if (ctx.mounted) {
      print("JOINING LOBBY MOOVIN STATE");
      state = WaitingToJoin(currentGame: e, navigationContext: ctx);
    } else {
      print("WARNING! The weird context hack broke! 333");
    }
  }

  void startGame() {
    if (state case WaitingToJoin w) {
      w.currentGame.state.started = true;
      w.currentGame.push();
    } else {
      print("Could not game, as we weren't in the waiting to join state");
    }
  }
}

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  LoggedInState? loggedInState;
  bool get loggedIn {
    if (loggedInState case LoggedInState _) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        loggedInState = LoggedInState(notifyListeners);
      } else {
        loggedInState?.deinit();
        loggedInState = null;
      }
      notifyListeners();
    });
  }
}
