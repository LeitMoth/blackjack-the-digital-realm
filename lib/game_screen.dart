import 'package:blackjack_the_digital_realm/widgets/playing_card.dart';
import 'package:flutter/material.dart';

import 'widgets/playing_hand.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() {
    return GameScreenState();
  }
}

class GameScreenState extends State<GameScreen> {
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
  List<PlayingCard> hand4 = [
    const PlayingCard(text: "Card 1"),
    const PlayingCard(text: "Card 2")
  ];

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
              cards: hand1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PlayingHand(side: true, cards: hand2),
                PlayingHand(
                  side: true,
                  cards: hand3,
                )
              ],
            ),
            PlayingHand(
              side: false,
              cards: hand4,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {
          setState(() {
            hand1.add(const PlayingCard(text: "Extra Card"));
            hand2.add(const PlayingCard(text: "Extra Card"));
            hand3.add(const PlayingCard(text: "Extra Card"));
            hand4.add(const PlayingCard(text: "Extra Card"));
          });
        }));
  }
}
