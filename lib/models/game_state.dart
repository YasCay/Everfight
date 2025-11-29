import 'package:everfight/models/boss.dart';
import 'package:everfight/models/monster.dart';

class GameState {
  Boss? currentBoss;
  int currentLevel = 1;
  List<Monster> team = [];

  GameState({
    this.currentBoss,
    this.currentLevel = 1,
    List<Monster>? team,
  }) : team = team ?? [];

  void reset() {
    currentBoss = null;
    currentLevel = 1;
    team.clear();
  }

  void update({
    Boss? newBoss,
    required int newLevel,
    List<Monster>? newTeam,
  }) {
    currentBoss = newBoss;
    currentLevel = newLevel;
    team = newTeam ?? [];
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      currentBoss: json['currentBoss'] != null
          ? Boss.fromJson(json['currentBoss'])
          : null,
      currentLevel: json['currentLevel'] ?? 1,
      team: (json['team'] as List<dynamic>?)
              ?.map((mJson) => Monster.fromJson(mJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentBoss': currentBoss?.toJson(),
      'currentLevel': currentLevel,
      'team': team.map((m) => m.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'GameState(currentLevel: $currentLevel, team: ${team.map((m) => m.name).toList()}, currentBoss: ${currentBoss?.name})';
  }
}
