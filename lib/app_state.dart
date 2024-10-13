import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'game_state.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  StreamSubscription<QuerySnapshot>? _gameSubscription;
  List<GameState> _games = [];
  List<GameState> get games => _games;
  DocumentReference? _currentGameRef;
  GameState? _currentGame;
  bool get started => _currentGame?.started ?? false;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;

        _gameSubscription = FirebaseFirestore.instance
            .collection('games')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _games = [];
          for (final document in snapshot.docs) {
            _games.add(GameState(
              started: document.data()['started'] as bool,
              playerIds: (document.data()['playerIds'] as List<dynamic>)
                  .map((x) => x as String)
                  .toList(),
              playerNames: (document.data()['playerNames'] as List<dynamic>)
                  .map((x) => x as String)
                  .toList(),
            ));

            if (_currentGameRef != null) {
              if (document.reference.id == _currentGameRef!.id) {
                _currentGame = _games.last;
              }
            }
          }
          notifyListeners();
        });
      } else {
        _loggedIn = false;

        _gameSubscription?.cancel();
        _games = [];
        _currentGame = null;
        _currentGameRef = null;
      }
      notifyListeners();
    });
  }

  Future<DocumentReference> makeLobby() {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance.collection('games').add(<String, dynamic>{
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'started': false,
      'playerNames': [FirebaseAuth.instance.currentUser!.displayName],
      'playerIds': [FirebaseAuth.instance.currentUser!.uid],
    }).then((ref) => _currentGameRef = ref);
  }

  //https://stackoverflow.com/a/59020046
  Future<void> startGame() {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    if (_currentGameRef == null) {
      throw Exception('Can\'t start game without making lobby');
    }

    return _currentGameRef!.update(<String, dynamic>{'started': true});
  }

  // Future<DocumentReference> joinLobby(String uid) {
  //   if (!_loggedIn) {
  //     throw Exception('Must be logged in');
  //   }
  //   return FirebaseFirestore.instance
  //       .collection('games')
  //       .add(<String, dynamic>{
  //     'timestamp': DateTime.now().millisecondsSinceEpoch,
  //     'playerNames': [FirebaseAuth.instance.currentUser!.displayName],
  //     'playerIds': [FirebaseAuth.instance.currentUser!.uid],
  //   });
  // }
}
