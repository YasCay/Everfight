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

    final double hpFactor = pow(hpGrowth, level - 1).toDouble();
    final double atkFactor = pow(atkGrowth, level - 1).toDouble();

    return Boss(
      name: tpl.name,
      element: tpl.element,
      imagePath: tpl.imagePath,
      baseHealth: (tpl.baseHealth * hpFactor * (1 + randomFactor)).round(),
      attack: (tpl.baseAttack * atkFactor * (1 + randomFactor)).round(),
    );
  }
}
