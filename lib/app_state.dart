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
            state: GameState.deserialize(snap.data() as Map<String, dynamic>),
            docId: id));
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
  PlayingBlackjack({required this.currentGame, required this.myUserId});
  EntangledGame currentGame;
  String myUserId;

  bool isMyTurn() {
    if (currentGame.state.turn >= currentGame.state.playerIds.length) {
      return false;
    }
    return currentGame.state.playerIds[currentGame.state.turn] == myUserId;
  }
}

class LoggedInState {
  LoggedInState(void Function() notifyChangeCallback) {
    notifyChange = notifyChangeCallback;

    name = FirebaseAuth.instance.currentUser?.displayName ?? "John Doe";

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
                state = PlayingBlackjack(
                    currentGame: currentGame,
                    myUserId: FirebaseAuth.instance.currentUser!.uid);
              } else {
                print("WARNING! context hack broke 2!!!");
              }
            }
          });
          break;
        case PlayingBlackjack(currentGame: EntangledGame currentGame):
          currentGame.pull().then((_) => notifyChangeCallback());
          break;
      }

      games = [];
      for (final document in snapshot.docs) {
        games.add((
          document.reference.id,
          GameState.deserialize(
            document.data(),
          )
        ));
      }

      notifyChange();
    });
  }

  late StreamSubscription<QuerySnapshot> gameSubscription;
  late void Function() notifyChange;
  late String name;
  List<(String, GameState)> games = [];
  BlackjackState state = NoBlackjack();

  void deinit() {
    gameSubscription.cancel();
  }

  void makeLobby(BuildContext ctx) async {
    var name =
        FirebaseAuth.instance.currentUser!.displayName ?? "PLACEHOLDER_NAME";
    var uid = FirebaseAuth.instance.currentUser!.uid;

    var deck = <int>[];
    for(int i = 1; i < 14; ++i) {
      for(int j = 0; j < 4; ++j) {
        deck.add(i * 10 + j);
        //The last digit of the number is the suit of the card
      }  
    }
    

    deck.shuffle();

    var hand0 = <int>[];
    hand0.add(deck.removeLast());
    hand0.add(deck.removeLast());

    var dealerHand = <int>[deck.removeLast()];

    var lobby = GameState(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        turn: 0,
        started: false,
        finished: false,
        playerNames: [name],
        playerIds: [uid],
        cards: deck,
        dealerHand:dealerHand,
        hand0: hand0,
        hand1:[],
        hand2:[],
        );

    var e = await EntangledGame.fromState(lobby);

    if (ctx.mounted) {
      state = WaitingToJoin(currentGame: e, navigationContext: ctx);
    } else {
      print("WARNING! The weird context hack broke!");
    }

    notifyChange();
  }

  void joinLobby(String docId, BuildContext ctx) async {
    print("JOINING LOBBY");
    var e = await EntangledGame.fromId(docId);

    var name =
        FirebaseAuth.instance.currentUser!.displayName ?? "PLACEHOLDER_NAME";
    var uid = FirebaseAuth.instance.currentUser!.uid;
    // These three must always be the same length
    int hand = e.state.playerIds.length;
    e.state.playerNames.add(name);
    e.state.playerIds.add(uid);
    if (hand == 1) {
      e.state.hand1.add(e.state.cards.removeLast());
      e.state.hand1.add(e.state.cards.removeLast());
    }
    else if (hand == 2) {
      e.state.hand2.add(e.state.cards.removeLast());
      e.state.hand2.add(e.state.cards.removeLast());
    } else {
      print("hand error");
    }
    e.push();

    if (ctx.mounted) {
      print("JOINING LOBBY MOOVIN STATE");
      state = WaitingToJoin(currentGame: e, navigationContext: ctx);
    } else {
      print("WARNING! The weird context hack broke! 333");
    }

    notifyChange();
  }

  void startGame() {
    if (state case WaitingToJoin w) {
      w.currentGame.state.started = true;
      w.currentGame.push();
    } else {
      print("Could not game, as we weren't in the waiting to join state");
    }
  }

  void cancelGame() {
    if (state case WaitingToJoin w) {
      // IMPORTANT: we need to do this so we don't join the game
      state = NoBlackjack();

      // Messy: we just start an empty game instead of properly deleting
      // this is probably fine.
      // Also we reset state above, that looks like it works?

      //TODO(colin): while this works for the person who
      // started the lobby, this puts anyone who pressed
      // join into the lobby the same as any one else.
      // a more proper way of doing this is make a
      // 'canceled' field and set that to true, then
      // handle this in the firestore updates just
      // like how we handle 'started'
      w.currentGame.state.started = true;
      w.currentGame.push();
    } else {
      print("Could not cancel game, we aren't in a game");
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
