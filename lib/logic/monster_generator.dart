import 'dart:math';

import 'package:everfight/logic/unlock_manager.dart';
import 'package:everfight/models/enums.dart';
import 'package:everfight/models/monster.dart';
import 'package:everfight/models/monster_template.dart';
import 'package:everfight/util/settings.dart';

class MonsterGenerator {
  final Random _rng = Random();
  final Map<Element, Map<int, MonsterTemplate>> templates;
  final UnlockManager unlockManager = UnlockManager();

  MonsterGenerator({required this.templates});

  List<_ElementTierEntry> _buildWeightedPool() {
    final List<_ElementTierEntry> pool = [];

    for (final element in Element.values) {
      final odds = unlockManager.getOddsForElement(element);

      for (int tier = 1; tier <= 4; tier++) {
        final weight = odds[tier - 1];

        if (weight > 0 && unlockManager.maxTierFor(element) >= tier) {
          pool.add(_ElementTierEntry(
            element: element,
            tier: tier,
            weight: weight,
          ));
        }
      }
    }

    return pool;
  }

  _ElementTierEntry _weightedPickFromPool(List<_ElementTierEntry> pool) {
    double total = pool.fold(0, (sum, e) => sum + e.weight);
    double roll = _rng.nextDouble() * total;

    for (final entry in pool) {
      roll -= entry.weight;
      if (roll <= 0) return entry;
    }

    return pool.last;
  }

  List<Monster> generateMonsters(int level, int count) {
    final List<Monster> result = [];
    final pool = _buildWeightedPool();

    // Avoid impossible cases
    if (pool.length < count) {
      throw Exception(
          "Not enough unique monsters available to generate $count monsters.");
    }

    final used = <String>{}; // "fire-1", "water-3", ...

    while (result.length < count) {
      final pick = _weightedPickFromPool(pool);
      final key = "${pick.element.index}-${pick.tier}";

      if (used.contains(key)) continue;

      used.add(key);

      final template = templates[pick.element]![pick.tier]!;
      result.add(createMonsterFromTemplate(template, level));
    }

    return result;
  }

  Monster createMonsterFromTemplate(MonsterTemplate tpl, int level) {
    const double growthPerLevel = MONSTER_PER_LEVEL_GROWTH;
    const double tierMultiplier = MONSTER_TIER_MULTIPLIER;

    final double levelFactor = pow(growthPerLevel, level - 1).toDouble();

    final double tierFactor = 1 + (tpl.tier - 1) * tierMultiplier;

    final int scaledHP =
        (tpl.baseHealth * levelFactor * tierFactor * getRandomFactor()).round();

    final int scaledATK =
        (tpl.baseAttack * levelFactor * tierFactor * getRandomFactor()).round();

    return Monster(
      name: tpl.name,
      element: tpl.element,
      baseHealth: scaledHP,
      baseAttack: scaledATK,
      imagePath: tpl.imagePath,
    );
  }

  double getRandomFactor() {
    double base = 1 - MONSTER_RANDOM_STAT_VARIATION;
    return base + _rng.nextDouble() * MONSTER_RANDOM_STAT_VARIATION * 2;
  }
}

class _ElementTierEntry {
  final Element element;
  final int tier;
  final double weight;

  _ElementTierEntry(
      {required this.element, required this.tier, required this.weight});
}
