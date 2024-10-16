class GameState {
  GameState({
    required this.started,
    required this.finished,
    required this.playerIds,
    required this.playerNames,
    required this.cards,
    required this.hand0,
    required this.hand1,
    required this.hand2,
    required this.dealerHand,
    required this.timestamp,
    required this.turn,
    // required this.docId
  });
  int timestamp;
  int turn;
  bool started;
  bool finished;
  List<String> playerIds;
  List<String> playerNames;
  List<int> cards;
  List<int> dealerHand;
  List<int> hand0;
  List<int> hand1;
  List<int> hand2;

  static int handAmount(List<int> hand) {
    return hand.fold(0, (x, y) => x + y);
  }

  void hit() {
    int card = cards.removeLast();
    var currentHand = switch (turn % playerIds.length) {
      0 => hand0,
      1 => hand1,
      2 => hand2,
      _ => throw "Hand not found"
    };

    currentHand.add(card);
    if (handAmount(currentHand) > 21) {
      print("Bust!");
      stand();
    }
  }

  bool get isDealerDone => turn == playerIds.length;

  void stand() {
    turn += 1;
    if (turn == playerIds.length) {
      playDealer();
    }
  }

  void playDealer() {
    while (handAmount(dealerHand) < 17) {
      int card = cards.removeLast();
      dealerHand.add(card);
    }
  }

  List<int> winStatus() {
    return [];
  }

  static List<N> getList<N>(dynamic thing) {
    return (thing as List<dynamic>).map((x) => x as N).toList();
  }

  static List<List<N>> getNestedList<N>(dynamic thing) {
    return (thing as List<dynamic>).map((x) => getList<N>(x)).toList();
  }

  static GameState deserialize(Map<String, dynamic> data) {
    return GameState(
      timestamp: data['timestamp'],
      turn: data['turn'],
      cards: getList<int>(data['cards']),
      dealerHand: getList<int>(data['dealerHand']),
      hand0: getList<int>(data['hand0']),
      hand1: getList<int>(data['hand1']),
      hand2: getList<int>(data['hand2']),
      started: data['started'] as bool,
      finished: data['finished'] as bool,
      playerIds: getList<String>(data['playerIds']),
      playerNames: getList<String>(data['playerNames']),
    );
  }

  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      'timestamp': timestamp,
      'turn': turn,
      'cards': cards,
      'hand0': hand0,
      'hand1': hand1,
      'hand2': hand2,
      'dealerHand': dealerHand,
      'started': started,
      'finished': finished,
      'playerIds': playerIds,
      'playerNames': playerNames,
    };
  }
}
