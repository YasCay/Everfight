import 'package:everfight/models/enums.dart';

class Monster {
  final String name;
  final String imagePath;
  final int baseHealth;
  int health;
  final int baseAttack;
  final Element element;

  Monster({required this.name, required this.imagePath, required this.baseHealth, required this.baseAttack, required this.element})
      : health = baseHealth;

  factory Monster.fromJson(Map<String, dynamic> json) {
    return Monster(
      name: json['name'],
      imagePath: json['imagePath'],
      baseHealth: json['baseHealth'],
      baseAttack: json['baseAttack'],
      element: Element.values.firstWhere((e) => e.toString() == 'Element.${json['element']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imagePath': imagePath,
      'baseHealth': baseHealth,
      'baseAttack': baseAttack,
      'element': element.toString().split('.').last,
    };
  }

  void resetHealth() {
    health = baseHealth;
  }
}