import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'game_state.dart';
import 'widgets/playing_card.dart';
import 'widgets/playing_hand.dart';

import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() {
    return GameScreenState();
  }
}
//TODO: make a custom back arrow

class GameScreenState extends State<GameScreen> {
  // int turn = 0;
  //
  // List<PlayingCard> dealerHand = [
  //   const PlayingCard(text: "Card 1"),
  //   const PlayingCard(text: "Card 2")
  // ];
  // List<PlayingCard> hand0 = [
  //   const PlayingCard(text: "Card 1"),
  //   const PlayingCard(text: "Card 2")
  // ];
  // List<PlayingCard> hand1 = [
  //   const PlayingCard(text: "Card 1"),
  //   const PlayingCard(text: "Card 2")
  // ];
  // List<PlayingCard> hand2 = [
  //   const PlayingCard(text: "Card 1"),
  //   const PlayingCard(text: "Card 2")
  // ];
  //
  // void handleAddCard(int turn) {
  //   switch (turn) {
  //     case (0):
  //       dealerHand.add(const PlayingCard(text: "New Card"));
  //     case (1):
  //       hand0.add(const PlayingCard(text: "New Card"));
  //     case (2):
  //       hand1.add(const PlayingCard(text: "New Card"));
  //     case (3):
  //       hand2.add(const PlayingCard(text: "New Card"));
  //   }
  // }

  void queueForScoreIfNeeded(EntangledGame curGame) {
    if (curGame.state.isDealerDone) {
      print("Beforetimer ${DateTime.now()}");
      Timer(const Duration(seconds: 5), () {
        curGame.state.finished = true;
        curGame.push();
      });
      print("Aftertimer ${DateTime.now()}");
    }
  }

  Widget makePlayButtons(PlayingBlackjack state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: !state.isMyTurn()
                ? null
                : () {
                    setState(() {
                      state.currentGame.state.hit();
                      state.currentGame.push();
                      // handleAddCard(state.currentGame.state.turn);
                      queueForScoreIfNeeded(state.currentGame);
                    });
                  },
            child: const Text("Add Card")),
        ElevatedButton(
            onPressed: !state.isMyTurn()
                ? null
                : () {
                    state.currentGame.state.stand();
                    state.currentGame.push();
                    queueForScoreIfNeeded(state.currentGame);
                  },
            child: const Text("End Turn"))
      ],
    );
  }

  List<PlayingCard> getHand(List<int> l, {bool dealer = false}) {
    List<PlayingCard> h = [];
    for (int card in l) {
      h.add(PlayingCard(text: dealer ? "$card" : "$card"));
    }

    return h;
  }

  Widget score(GameState s) {

    var messages = <String>[];

    var indices = <int>[];

    var dealerAmount = GameState.handAmount(s.dealerHand);

    for(int i = 0; i < s.playerIds.length; ++i) {
      indices.add(i);
      var currentHand = switch (i) {
        0 => s.hand0,
        1 => s.hand1,
        2 => s.hand2,
        _ => throw "Hand not found"
      };
      var amount = GameState.handAmount(currentHand);
      if (amount > 21) {
        messages.add("Busted!");
      }
      else if (dealerAmount > 21 || amount > dealerAmount) {
        messages.add("Win! ($amount)");
      }
      else if (amount == dealerAmount) {
        messages.add("Tie ($amount)");
      } else {
        messages.add("Lose ($amount)");
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // title: Text("Score"),
        //found source for backbutton here: https://www.youtube.com/watch?v=YoLbuAiYOi4
        // leading: BackButton(
        //   onPressed: () {
        //     //navigate to a different page here
        //   },
        // ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.black,
            child: Column(
              children: <Widget>[
                const Padding(
                  //make this text "Score" to be in be middle alignment (done)
                  padding: EdgeInsets.symmetric(
                      horizontal: 0.0, vertical: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Results',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 65,
                        ),
                      ),
                    ],
                  ),
                ),
                for (int i  in indices) 
                  Container(
                    height: 90,
                    width: 300,
                    margin:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 79, 78, 78),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text('${s.playerNames[i]}: ${messages[i]}', style: const TextStyle(color: Colors.white, fontSize: 20),))
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (ctx, appState, _) {
      if (appState.loggedInState?.state case PlayingBlackjack playstate) {
        var gamestate = playstate.currentGame.state;
        var players = gamestate.playerIds.length;

        if (gamestate.finished) {
          return score(gamestate);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Blackjack!"),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PlayingHand(
                  side: false,
                  cards: getHand(gamestate.dealerHand, dealer: true),
                  playerName: "The Dealer"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PlayingHand(
                      side: true,
                      cards: players < 1 ? [] : getHand(gamestate.hand0),
                      playerName: players < 1 ? "" : gamestate.playerNames[0]),
                  makePlayButtons(playstate),
                  PlayingHand(
                      side: true,
                      cards: players < 2 ? [] : getHand(gamestate.hand1),
                      playerName: players < 2 ? "" : gamestate.playerNames[1]),
                ],
              ),
              PlayingHand(
                  side: false,
                  cards: players < 3 ? [] : getHand(gamestate.hand2),
                  playerName: players < 3 ? "" : gamestate.playerNames[2]),
            ],
          ),
        );
      } else {
        return Scaffold(appBar: AppBar(title: const Text("BIG ERROR!")));
      }
    });
  }
}
