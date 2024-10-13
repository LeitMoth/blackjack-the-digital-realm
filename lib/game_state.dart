class GameState {
  GameState(
      {required this.started,
      required this.playerIds,
      required this.playerNames});
  bool started;
  List<String> playerIds;
  List<String> playerNames;
}
