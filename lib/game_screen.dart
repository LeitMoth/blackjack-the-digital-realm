import 'package:flutter/material.dart';

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
  int turn = 0;

  List<PlayingCard> hand0 = [];
  List<PlayingCard> hand1 = [];
  List<PlayingCard> hand2 = [];
  List<PlayingCard> hand3 = [];

  @override
  void initState() {
    super.initState();
    hand0 = generateRandomHand();
    hand1 = generateRandomHand();
    hand2 = generateRandomHand();
    hand3 = generateRandomHand();
  }

  PlayingCard randomCard() {
    // Returns a random card
    // TODO: Henry: Implement Random Suit Selection
    Random random = Random();
    int number = random.nextInt(13) + 1;
    if(number == 1) {
      return const PlayingCard(text: "A");
    }
    if (number == 11) {
      return const PlayingCard(text: "J");
    }
    if (number == 12) {
      return const PlayingCard(text: "Q");
    }
    if (number == 13) {
      return const PlayingCard(text: "K");
    }
    else{
      String cardValue = number.toString();
      return PlayingCard(text: cardValue);
    }
  }

  List<PlayingCard> generateRandomHand() {
    return [
      randomCard(), 
      randomCard()
    ];
  }

  void handleAddCard() {
    // TODO: Check for bust
    switch (turn) {
      case (0):
        hand0.add(randomCard());
      case (1):
        hand1.add(randomCard());
      case (2):
        hand2.add(randomCard());
      case (3):
        hand3.add(randomCard());
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
            hand1.add(randomCard());
            hand2.add(randomCard());
            hand3.add(randomCard());
            hand0.add(randomCard());
          });
        }));
  }
}
