import 'package:everfight/models/monster.dart';
import 'package:flame/game.dart';

class MonsterLayout {
  final Monster monster;
  final Vector2 position;
  final double width;
  final double height;

  MonsterLayout({
    required this.monster,
    required this.position,
    required this.width,
    required this.height,
  });
}