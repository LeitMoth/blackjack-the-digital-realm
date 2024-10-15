class GameState {
  GameState(
      {required this.started,
      required this.playerIds,
      required this.playerNames,
      required this.cards,
      required this.timestamp,
      // required this.docId
      });
  int timestamp;
  bool started;
  List<String> playerIds;
  List<String> playerNames;
  List<int> cards;

  static List<N> getList<N>(dynamic thing) {
    return (thing as List<dynamic>).map((x) => x as N).toList();
  }

  static GameState deserialize(Map<String, dynamic> data) {
    return GameState(
        timestamp: data['timestamp'],
        // cards: getList<int>(data['cards']),
        cards: [],
        started: data['started'] as bool,
        playerIds: getList<String>(data['playerIds']),         
        playerNames: getList<String>(data['playerNames']),         
        );
  }

  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      'timestamp': timestamp,
      'cards': cards,
      'started': started,
      'playerIds': playerIds,
      'playerNames': playerNames,
    };
  }
}
