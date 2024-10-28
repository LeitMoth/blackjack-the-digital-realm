import 'package:flutter/material.dart';

class PlayingCard extends StatelessWidget {
  const PlayingCard({super.key, required this.text});

  final String text;
  
  

  @override
  Widget build(BuildContext context) {
    AssetImage cardImage = AssetImage('images/cards/${text}.png'); 
    

    return Card(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: cardImage,
           fit: BoxFit.fill)
          
        ),
        height: 100,
        width: 71,
        child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              //child: Text(text),
            )),
      ),
    );
  }
}
