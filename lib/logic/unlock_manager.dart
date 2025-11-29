import 'package:everfight/models/enums.dart';
import 'package:everfight/models/tier_unlocks.dart';
import 'package:everfight/util/local_storage.dart';

class UnlockManager {
  static final UnlockManager _instance = UnlockManager._internal();
  static bool _initialized = false;

  factory UnlockManager() => _instance;

  UnlockManager._internal();

  TierUnlocks tierUnlocks = TierUnlocks(unlockedTiers: {}); // safe default
  Map<int, List<double>> tierOdds = {
    1: [1.0, 0.0, 0.0, 0.0],
    2: [0.7, 0.3, 0.0, 0.0],
    3: [0.5, 0.3, 0.2, 0.0],
    4: [0.4, 0.3, 0.2, 0.1],
  };

  Future<void> init() async {
    if (_initialized) return; // avoid double calls

    tierUnlocks = await LocalStorage.loadUnlockedTiers();
    _initialized = true;
  }

  bool get isReady => _initialized;

  List<double> getOddsForElement(Element element) {
    if (!_initialized) {
      // fallback while loading
      return tierOdds[1]!;
    }
    int tier = tierUnlocks.unlockedTiers[element] ?? 1;
    return tierOdds[tier] ?? tierOdds[1]!;
  }

  List<MapEntry<Element, int>> getUnlockedCombos() {
    return tierUnlocks.unlockedTiers.entries.toList();
  }

  Future<void> unlockNextTier(Element element, {int unlockTier = -1}) async {
    if (unlockTier != -1) {
      if ((tierUnlocks.unlockedTiers[element] ?? 1) >= unlockTier) {
        return; // already unlocked
      }
    }

    int current = tierUnlocks.unlockedTiers[element] ?? 1;
    if (current < tierOdds.length) {
      tierUnlocks.unlockedTiers[element] = current + 1;
      await LocalStorage.saveUnlockedTiers(tierUnlocks);
    }
  }

  int maxTierFor(Element element) {
    return tierUnlocks.unlockedTiers[element] ?? 1;
  }
}
