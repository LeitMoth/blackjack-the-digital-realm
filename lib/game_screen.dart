import 'package:flutter/material.dart';

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
  int turn = 0;

  List<PlayingCard> hand0 = [
    const PlayingCard(text: "Card 1"),
    const PlayingCard(text: "Card 2")
  ];
  List<PlayingCard> hand1 = [
    const PlayingCard(text: "Card 1"),
    const PlayingCard(text: "Card 2")
  ];
  List<PlayingCard> hand2 = [
    const PlayingCard(text: "Card 1"),
    const PlayingCard(text: "Card 2")
  ];
  List<PlayingCard> hand3 = [
    const PlayingCard(text: "Card 1"),
    const PlayingCard(text: "Card 2")
  ];

  void handleAddCard() {
    switch (turn) {
      case (0):
        hand0.add(const PlayingCard(text: "New Card"));
      case (1):
        hand1.add(const PlayingCard(text: "New Card"));
      case (2):
        hand2.add(const PlayingCard(text: "New Card"));
      case (3):
        hand3.add(const PlayingCard(text: "New Card"));
    }
  }

  @override
  Widget build(BuildContext context) {
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
              cards: hand0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PlayingHand(side: true, cards: hand1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            handleAddCard();
                          });
                        },
                        child: const Text("Add Card")),
                    ElevatedButton(
                        onPressed: () {
                          //end turn
                          if (turn == 3) {
                            turn = 0;
                          }
                          turn += 1;
                        },
                        child: const Text("End Turn"))
                  ],
                ),
                PlayingHand(
                  side: true,
                  cards: hand2,
                )
              ],
            ),
            PlayingHand(
              side: false,
              cards: hand3,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {
          setState(() {
            hand1.add(const PlayingCard(text: "Extra Card"));
            hand2.add(const PlayingCard(text: "Extra Card"));
            hand3.add(const PlayingCard(text: "Extra Card"));
            hand0.add(const PlayingCard(text: "Extra Card"));
          });
        }));
  }
}
