// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:blackjack_the_digital_realm/app_state.dart';
import 'package:blackjack_the_digital_realm/game_state.dart';
import 'package:blackjack_the_digital_realm/widgets/playing_card.dart';
import 'package:blackjack_the_digital_realm/widgets/playing_hand.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blackjack_the_digital_realm/main.dart';
import 'package:blackjack_the_digital_realm/home_page.dart';
import 'package:provider/provider.dart';


void main() {
  testWidgets('HomePage renders with correct title and app state', (WidgetTester tester) async {
  final appState = ApplicationState();
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (context) => appState,
      child: const MaterialApp(home: HomePage()),
    ),
  );
  
  expect(find.text('Blackjack: The Digital Realm'), findsOneWidget);
});

testWidgets('App initializes properly', (WidgetTester tester) async {
  await tester.pumpWidget(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: (context, child) => const App(),
  ));
  
  expect(find.byType(MaterialApp), findsOneWidget);
  expect(find.byType(HomePage), findsOneWidget);
});

  testWidgets('PlayingCard displays the correct text', (WidgetTester tester) async {
    // Arrange: Provide the card widget with text
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: PlayingCard(text: 'A'),
      ),
    ));

    // Act & Assert: Verify that the correct text is displayed
    expect(find.text('A'), findsOneWidget);
  });

    testWidgets('PlayingHand displays correct cards', (WidgetTester tester) async {
    
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: PlayingHand(
          side: false,
          cards: [
            PlayingCard(text: 'A'),
            PlayingCard(text: '10')
          ],
          playerName: 'Player 1',
        ),
      ),
    ));

    // Act & Assert: Verify that both cards are displayed
    expect(find.text('A'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('Player 1'), findsOneWidget);
  });

  test('GameState handles turn management correctly', () {
    // Arrange: Mock a simple GameState
    final gameState = GameState(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      turn: 0,
      started: false,
      finished: false,
      playerNames: ['Player 1', 'Player 2'],
      playerIds: ['player1_id', 'player2_id'],
      cards: [1, 2, 3, 4],
      dealerHand: [10],
      hand0: [2],
      hand1: [3],
      hand2: [],
    );

    // Act: Change the turn in the game
    gameState.turn += 1;

    // Assert: Verify the turn was updated correctly
    expect(gameState.turn, equals(1));
  });
}