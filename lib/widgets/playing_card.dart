import 'package:flutter/material.dart';

class PlayingCard extends StatelessWidget {
  const PlayingCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 100,
        width: 76,
        child: Center(child: Text(text)),
      ),
    );
  }
}
