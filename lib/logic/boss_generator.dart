import 'dart:math';
import 'package:everfight/util/settings.dart';
import 'package:everfight/models/boss.dart';
import 'package:everfight/models/boss_template.dart';

class BossGenerator {
  final Random _rng = Random();
  final List<BossTemplate> templates;

  BossGenerator({required this.templates});

  Boss generateBoss(int level) {
    final BossTemplate tpl = templates[_rng.nextInt(templates.length)];
    return _createBossFromTemplate(tpl, level);
  }

  Boss _createBossFromTemplate(BossTemplate tpl, int level) {
    const double hpGrowth = BOSS_HP_PER_LEVEL_GROWTH;
    const double atkGrowth = BOSS_ATK_PER_LEVEL_GROWTH;

    double randomFactor = 0.0;

    if (level > 1) {
      randomFactor = (_rng.nextDouble() * 2 - 1) * BOSS_RANDOM_STAT_VARIATION;
    }

    double hpFactor = pow(1 + hpGrowth, level - 1).toDouble();
    double atkFactor = pow(1 + atkGrowth, level - 1).toDouble();

    if (level > 49) {
      double newLevel = 49 + pow(level - 1 - 49, 0.55).toDouble();
      hpFactor = pow(1 + hpGrowth, newLevel).toDouble();
      atkFactor = pow(1 + atkGrowth, newLevel).toDouble();
    }

    double newHP = tpl.baseHealth * hpFactor * (1 + randomFactor);
    double newATK = tpl.baseAttack * atkFactor * (1 + randomFactor);

    if (level < 5) {
      newHP = newHP / (5 - (level - 1));
      newATK = newATK / (5 - (level - 1));
    }

    return Boss(
      name: tpl.name,
      element: tpl.element,
      imagePath: tpl.imagePath,
      baseHealth: newHP.round(),
      attack: newATK.round(),
    );
  }
}
