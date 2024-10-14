class GameState {
  GameState(
      {required this.started,
      required this.playerIds,
      required this.playerNames,
      required this.docId});
  String docId;
  bool started;
  List<String> playerIds;
  List<String> playerNames;
}
