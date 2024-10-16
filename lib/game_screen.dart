import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'game_state.dart';
import 'widgets/playing_card.dart';
import 'widgets/playing_hand.dart';

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
      h.add(PlayingCard(text: dealer ? "D$card" : "$card"));
    }

    return h;
  }

  Widget score() {
    return Scaffold(
      appBar: AppBar(title: const Text("Score")),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text('a winner is you!')]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (ctx, appState, _) {
      if (appState.loggedInState?.state case PlayingBlackjack playstate) {
        var gamestate = playstate.currentGame.state;
        var players = gamestate.playerIds.length;

        if (gamestate.finished) {
          return score();
        }

        return Scaffold(
            appBar: AppBar(
              title: const Text("Game Screen"),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PlayingHand(
                  side: false,
                  cards: getHand(gamestate.dealerHand, dealer: true),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PlayingHand(
                        side: true,
                        cards: players < 1 ? [] : getHand(gamestate.hand0)),
                    makePlayButtons(playstate),
                    PlayingHand(
                      side: true,
                      cards: players < 2 ? [] : getHand(gamestate.hand1),
                    )
                  ],
                ),
                PlayingHand(
                  side: false,
                  cards: players < 3 ? [] : getHand(gamestate.hand2),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(onPressed: () {
              setState(() {
                // hand0.add(const PlayingCard(text: "Extra Card"));
                // hand1.add(const PlayingCard(text: "Extra Card"));
                // hand2.add(const PlayingCard(text: "Extra Card"));
                // dealerHand.add(const PlayingCard(text: "Extra Card"));
              });
            }));
      } else {
        return Scaffold(appBar: AppBar(title: const Text("BIG ERROR!")));
      }
    });
  }
}
