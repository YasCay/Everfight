import 'package:everfight/models/enums.dart';

class Boss {
  final String name;
  final String description;
  final String imagePath;
  final int level;
  final int baseHealth;
  int health;
  final int attack;
  final Element element;

  Boss({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.level,
    required this.baseHealth,
    required this.attack,
    required this.element,
  }) : health = baseHealth;

  factory Boss.fromJson(Map<String, dynamic> json) {
    return Boss(
      name: json['name'],
      description: json['description'],
      imagePath: json['imagePath'],
      level: json['level'],
      baseHealth: json['baseHealth'],
      attack: json['attack'],
      element: Element.values.firstWhere((e) => e.toString() == 'Element.${json['element']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'level': level,
      'baseHealth': baseHealth,
      'attack': attack,
      'element': element.toString().split('.').last,
    };
  }
}