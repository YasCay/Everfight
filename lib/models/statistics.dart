import 'package:everfight/models/enums.dart';

class Statistics {
  int runsStarted = 0;
  int runsWon = 0;
  int highestLevelReached = 0;

  Map<Element, int> bossesDefeatedByElement = {};
  Map<Element, int> bossesDefeatedByElementRun = {};
  Map<String, int> monsterPicked = {};
  Map<String, int> winsWithMonster = {};

  int totalDamageDealt = 0;
  int totalDamageTaken = 0;

  Map<String, int> monsterDamageDealt = {};
  Map<String, int> monsterDeaths = {};

  int get bossesDefeated {
    return bossesDefeatedByElement.values.fold(0, (a, b) => a + b);
  }

  int bossesDefeatedInRun(Element element) {
    return bossesDefeatedByElementRun[element] ?? 0;
  }

  int bossesDefeatedTotal(Element element) {
    return bossesDefeatedByElement[element] ?? 0;
  }

  num getStatValue(String stat) {
    switch (stat) {
      case 'runsStarted':
        return runsStarted;
      case 'runsWon':
        return runsWon;
      case 'highestLevelReached':
        return highestLevelReached;
      case 'totalDamageDealt':
        return totalDamageDealt;
      case 'totalDamageTaken':
        return totalDamageTaken;
      case 'bossesDefeated':
        return bossesDefeated;
      default:
        return 0;
    }
  }

  Statistics();

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics()
      ..runsStarted = json['runsStarted'] ?? 0
      ..runsWon = json['runsWon'] ?? 0
      ..highestLevelReached = json['highestLevelReached'] ?? 0
      ..bossesDefeatedByElement = Map<Element, int>.from(
          (json['bossesDefeatedByElement'] ?? {}).map((key, value) =>
              MapEntry(Element.values.firstWhere((e) => e.toString() == key), value)))
      ..bossesDefeatedByElementRun = Map<Element, int>.from(
          (json['bossesDefeatedByElementRun'] ?? {}).map((key, value) =>
              MapEntry(Element.values.firstWhere((e) => e.toString() == key), value)))
      ..monsterPicked = Map<String, int>.from(json['monsterPicked'] ?? {})
      ..winsWithMonster = Map<String, int>.from(json['winsWithMonster'] ?? {})
      ..totalDamageDealt = json['totalDamageDealt'] ?? 0
      ..totalDamageTaken = json['totalDamageTaken'] ?? 0
      ..monsterDamageDealt =
          Map<String, int>.from(json['monsterDamageDealt'] ?? {})
      ..monsterDeaths = Map<String, int>.from(json['monsterDeaths'] ?? {});
  }

  Map<String, dynamic> toJson() {
    return {
      'runsStarted': runsStarted,
      'runsWon': runsWon,
      'highestLevelReached': highestLevelReached,
      'bossesDefeatedByElement': bossesDefeatedByElement.map((key, value) =>
          MapEntry(key.toString(), value)),
      'bossesDefeatedByElementRun': bossesDefeatedByElementRun.map((key, value) =>
          MapEntry(key.toString(), value)),
      'monsterPicked': monsterPicked,
      'winsWithMonster': winsWithMonster,
      'totalDamageDealt': totalDamageDealt,
      'totalDamageTaken': totalDamageTaken,
      'monsterDamageDealt': monsterDamageDealt,
      'monsterDeaths': monsterDeaths,
    };
  }

  @override
  String toString() {
    return 'Statistics(runsStarted: $runsStarted, runsWon: $runsWon, highestLevelReached: $highestLevelReached, '
        'bossesDefeatedByElement: $bossesDefeatedByElement, bossesDefeatedByElementRun: $bossesDefeatedByElementRun, '
        'monsterPicked: $monsterPicked, winsWithMonster: $winsWithMonster, '
        'totalDamageDealt: $totalDamageDealt, totalDamageTaken: $totalDamageTaken, '
        'monsterDamageDealt: $monsterDamageDealt, monsterDeaths: $monsterDeaths)';
  }
}
