import 'package:everfight/models/enums.dart';

class Statistics {
  int runsStarted = 0;
  int runsWon = 0;
  int highestLevelReached = 0;

  Map<Element, int> bossesDefeatedByElement = {};
  Map<String, int> monsterPicked = {};
  Map<String, int> winsWithMonster = {};

  int totalDamageDealt = 0;
  int totalDamageTaken = 0;

  Map<String, int> monsterDamageDealt = {};
  Map<String, int> monsterDeaths = {};

  Statistics();
  
  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics()
      ..runsStarted = json['runsStarted'] ?? 0
      ..runsWon = json['runsWon'] ?? 0
      ..highestLevelReached = json['highestLevelReached'] ?? 0
      ..bossesDefeatedByElement = Map<Element, int>.from(
          (json['bossesDefeatedByElement'] ?? {}).map((key, value) =>
              MapEntry(Element.values.firstWhere((e) => e.toString() == key), value)))
      ..monsterPicked = Map<String, int>.from(json['monsterPicked'] ?? {})
      ..winsWithMonster = Map<String, int>.from(json['winsWithMonster'] ?? {})
      ..totalDamageDealt = json['totalDamageDealt'] ?? 0
      ..totalDamageTaken = json['totalDamageTaken'] ?? 0
      ..monsterDamageDealt = Map<String, int>.from(json['monsterDamageDealt'] ?? {})
      ..monsterDeaths = Map<String, int>.from(json['monsterDeaths'] ?? {});
  }

  Map<String, dynamic> toJson() {
    return {
      'runsStarted': runsStarted,
      'runsWon': runsWon,
      'highestLevelReached': highestLevelReached,
      'bossesDefeatedByElement': bossesDefeatedByElement.map((key, value) =>
          MapEntry(key.toString(), value)),
      'monsterPicked': monsterPicked,
      'winsWithMonster': winsWithMonster,
      'totalDamageDealt': totalDamageDealt,
      'totalDamageTaken': totalDamageTaken,
      'monsterDamageDealt': monsterDamageDealt,
      'monsterDeaths': monsterDeaths,
    };
  }
}