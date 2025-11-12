import 'package:everfight/models/enums.dart';
import 'package:flutter/foundation.dart';

class Boss extends ChangeNotifier {
  final String name;
  final String imagePath;
  final int baseHealth;
  int health;
  final int attack;
  final Element element;

  Boss({
    required this.name,
    required this.imagePath,
    required this.baseHealth,
    required this.attack,
    required this.element,
  }) : health = baseHealth;

  factory Boss.fromJson(Map<String, dynamic> json) {
    return Boss(
      name: json['name'],
      imagePath: json['imagePath'],
      baseHealth: json['baseHealth'],
      attack: json['attack'],
      element: Element.values.firstWhere((e) => e.toString() == 'Element.${json['element']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imagePath': imagePath,
      'baseHealth': baseHealth,
      'attack': attack,
      'element': element.toString().split('.').last,
    };
  }

  void takeDamage(int damage) {
    health -= damage;
    if (health < 0) {
      health = 0;
    }
    notifyListeners();
  }

  void resetHealth() {
    health = baseHealth;
    notifyListeners();
  }
}

extension BossBackground on Boss {
  String get backgroundPath {
    switch (element) {
      case Element.fire:
        return 'fightscene/fire/fire_scene.png';
      case Element.water:
        return 'fightscene/water/water_scene.png';
      case Element.earth:
        return 'fightscene/earth/earth_scene.png';
      case Element.air:
        return 'fightscene/air/air_scene.png';
      }
  }
}