class GameState {
  GameState({
    required this.started,
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
  List<String> playerIds;
  List<String> playerNames;
  List<int> cards;
  List<int> dealerHand;
  List<int> hand0;
  List<int> hand1;
  List<int> hand2;

  void hit() {
    int card = cards.removeLast();
    switch (turn % playerIds.length) {
      case 0:
        hand0.add(card);
        break;
      case 1:
        hand1.add(card);
        break;
      case 2:
        hand2.add(card);
        break;
      default:
        print("Huge problem!");
        break;
    }
  }

  void stand() {
    turn += 1;
    turn %= playerIds.length;
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
      'playerIds': playerIds,
      'playerNames': playerNames,
    };
  }
}
