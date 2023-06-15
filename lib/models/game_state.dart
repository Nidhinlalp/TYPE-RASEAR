import 'dart:convert';

class GameState {
  final String id;
  final List players;
  final bool isJoin;
  final bool isOver;
  final List words;
  GameState({
    required this.id,
    required this.players,
    required this.isJoin,
    required this.isOver,
    required this.words,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'players': players,
      'isJoin': isJoin,
      'isOver': isOver,
      'words': words,
    };
  }

  factory GameState.fromMap(Map<String, dynamic> map) {
    return GameState(
      id: map['id'] ?? '',
      players: List.from(map['players']),
      isJoin: map['isJoin'] ?? false,
      isOver: map['isOver'] ?? false,
      words: List.from(map['words']),
    );
  }

  factory GameState.fromJson(String source) =>
      GameState.fromMap(json.decode(source));
}
