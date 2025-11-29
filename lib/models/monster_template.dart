import 'package:everfight/models/enums.dart';

class MonsterTemplate {
  final String name;
  final Element element;
  final int tier;
  final int baseHealth;
  final int baseAttack;
  final String imagePath;


  MonsterTemplate({
    required this.name,
    required this.element,
    required this.tier,
    required this.baseHealth,
    required this.baseAttack,
    required this.imagePath,
  });


  factory MonsterTemplate.fromJson(Map<String, dynamic> json) => MonsterTemplate(
    name: json['name'],
    element: Element.values.firstWhere((e) => e.toString() == 'Element.${json['element']}'),
    tier: json['tier'],
    baseHealth: json['baseHp'],
    baseAttack: json['baseDamage'],
    imagePath: json['imagePath'],
  );
}