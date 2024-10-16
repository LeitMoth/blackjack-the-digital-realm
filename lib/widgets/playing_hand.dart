import 'package:flutter/material.dart';

import 'playing_card.dart';

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
  List<Widget> positions = [];
  double shift = 50;
  double containerSize = 75;
  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Container();
    }
    positions = [];
    shift = 50;
    containerSize = (shift * widget.cards.length - 1) + 75;
    positions.add(widget.cards[0]);
    if (widget.cards.length > 1) {
      int i = 1;
      // print(widget.cards.length);
      while (i < widget.cards.length) {
        // print(i);
        if (widget.side) {
          positions.add(Positioned(top: shift, child: widget.cards[i]));
        } else {
          positions.add(Positioned(left: shift, child: widget.cards[i]));
        }
        shift += 50;
        i += 1;
      }
      // print("ran");
      // print(positions);
    }

    switch (widget.side) {
      case true:
        // return Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: widget.cards,
        // );
        return Container(
          // TODO: Edit so that the center of the card isn't overlapped, thus blocking the text
          padding: const EdgeInsets.all(8),
          width: 100,
          height: containerSize,
          // color: Colors.black,
          child: Stack(
            children: positions,
          ),
        );
      case false:
        // return Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: widget.cards,
        // );
        return Container(
          padding: const EdgeInsets.all(8),
          width: containerSize,
          height: 150,
          child: Stack(
            // alignment: Alignment.center,
            children: positions,
          ),
        );
    }
  }
}
