import 'package:everfight/logic/achievement_manager.dart';
import 'package:everfight/models/enums.dart';
import 'package:everfight/models/statistics.dart';
import 'package:everfight/util/local_storage.dart';

class StatisticsManager {
  static final StatisticsManager _instance = StatisticsManager._internal();
  factory StatisticsManager() => _instance;

  late Statistics statistics;
  bool _initialized = false;

  StatisticsManager._internal();

  Future<void> init() async {
    if (_initialized) return;

    statistics = await LocalStorage.loadStatistics() ?? Statistics();
    print('Loaded statistics: $statistics');
    _initialized = true;
  }

  Future<void> _save() async {
    AchievementManager().evaluate(statistics);
    await LocalStorage.saveStatistics(statistics);
  }

  void recordRunStarted() {
    statistics.runsStarted++;
    _save();
  }

  void recordRunWon() {
    statistics.runsWon++;
    _save();
  }

  void recordHighestLevel(int level) {
    if (level > statistics.highestLevelReached) {
      statistics.highestLevelReached = level;
      _save();
    }
  }

  void recordBossDefeated(Element element) {
    statistics.bossesDefeatedByElement[element] =
        (statistics.bossesDefeatedByElement[element] ?? 0) + 1;
    _save();
  }

  void recordMonsterPicked(String monsterName) {
    statistics.monsterPicked[monsterName] =
        (statistics.monsterPicked[monsterName] ?? 0) + 1;
    _save();
  }

  void recordWinWithMonster(String monsterName) {
    statistics.winsWithMonster[monsterName] =
        (statistics.winsWithMonster[monsterName] ?? 0) + 1;
    _save();
  }

  void recordDamageDealt(String monsterName, int amount) {
    statistics.totalDamageDealt += amount;
    statistics.monsterDamageDealt[monsterName] =
        (statistics.monsterDamageDealt[monsterName] ?? 0) + amount;
    _save();
  }

  void recordDamageTaken(int amount) {
    statistics.totalDamageTaken += amount;
    _save();
  }

  void recordMonsterDeath(String monsterName) {
    statistics.monsterDeaths[monsterName] =
        (statistics.monsterDeaths[monsterName] ?? 0) + 1;
    _save();
  }
}
