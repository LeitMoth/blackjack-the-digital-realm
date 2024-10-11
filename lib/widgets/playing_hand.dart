import 'package:flutter/material.dart';

import 'playing_card.dart';

//TODO: How are we handling each player's perspective of the screen? that will determine how the view of the playing hand is
//There needs to be a way to handle the playing hands on the side.
class PlayingHand extends StatefulWidget {
  const PlayingHand({super.key, required this.side, required this.cards});

  final bool side;
  final List<PlayingCard> cards;

  @override
  State<StatefulWidget> createState() {
    return PlayingHandState();
  }
}

class PlayingHandState extends State<PlayingHand> {
  // List<PlayingCard> cards = [
  //   const PlayingCard(text: "Card 1"),
  //   const PlayingCard(text: "Card 2"),
  // ];

  //TODO: move this to the game_screen or somewhere else. The playing hand class should purely be for display,
  //not for knowing the information. I would do this now, but I am not sure where this information should be stored at

  // void handleNewPlayingCard(PlayingCard playingCard) {
  //   setState(() {
  //     cards.add(playingCard);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    switch (widget.side) {
      case true:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.cards,
        );
      case false:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.cards,
        );
    }
  }
}
