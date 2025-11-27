import 'package:everfight/models/enums.dart';

class BossTemplate {
  final String name;
  final int baseHealth;
  final int baseAttack;
  final Element element;
  final String imagePath;

  BossTemplate({
    required this.name,
    required this.baseHealth,
    required this.baseAttack,
    required this.element,
    required this.imagePath,
  });

  factory BossTemplate.fromJson(Map<String, dynamic> json) {
    return BossTemplate(
      name: json['name'],
      baseHealth: json['baseHealth'],
      baseAttack: json['baseAttack'],
      element: Element.values.firstWhere(
        (e) => e.toString().split('.').last == json['element'],
      ),
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'baseHealth': baseHealth,
      'baseAttack': baseAttack,
      'element': element.toString().split('.').last,
      'imagePath': imagePath,
    };
  }
}
