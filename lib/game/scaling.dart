import 'dart:math';
import 'package:everfight/models/monster.dart';

class Scaling {
  // Gegner stark skalieren
  static Monster scaleBoss(Monster base, int level) {
    final hp = (base.baseHealth * pow(1.18, level)).round();
    final atk = (base.baseAttack * pow(1.15, level)).round();
    final def = (base.baseDefense * pow(1.10, level)).round();

    return Monster(
      name: base.name,
      imagePath: base.imagePath,
      baseHealth: hp,
      baseAttack: atk,
      baseDefense: def,
      rarity: base.rarity,
      element: base.element,
    );
  }

  // Spieler leicht skalieren
  static Monster scalePlayer(Monster base, int level) {
    final hp = (base.baseHealth * (1 + 0.03 * level)).round();
    final atk = (base.baseAttack * (1 + 0.02 * level)).round();
    final def = (base.baseDefense * (1 + 0.015 * level)).round();

    return Monster(
      name: base.name,
      imagePath: base.imagePath,
      baseHealth: hp,
      baseAttack: atk,
      baseDefense: def,
      rarity: base.rarity,
      element: base.element,
    );
  }
}
