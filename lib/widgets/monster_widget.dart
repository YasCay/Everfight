import 'dart:math' as math;

import 'package:everfight/models/monster.dart';
import 'package:everfight/widgets/damage_popup_component.dart';
import 'package:everfight/widgets/health_bar_component.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' hide Image;

class MonsterWidget extends PositionComponent {
  final Monster monster;
  SpriteComponent? _spriteComponent;
  late HealthBarComponent _hpBubble;
  @override
  final double width;
  @override
  final double height;

  MonsterWidget({
    required this.monster,
    required Vector2 position,
    required this.width,
    required this.height,
  }) : super(
            position: position,
            size: Vector2(width, height),
            anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final image = Flame.images.fromCache(monster.imagePath);
    final sprite = Sprite(image);

    final imageSize = sprite.srcSize;
    final targetSize = Vector2(width, height);
    final scale = math.min(
      targetSize.x / imageSize.x,
      targetSize.y / imageSize.y,
    );

    final fittedSize = imageSize * scale;
    final offset = Vector2(
      (targetSize.x - fittedSize.x) / 2,
      (height - fittedSize.y) / 2,
    );

    final spriteComponent = SpriteComponent(
      sprite: sprite,
      size: fittedSize,
      position: offset,
    );
    _spriteComponent = spriteComponent;

    _hpBubble = HealthBarComponent(
      owner: monster,
      getCurrent: () => monster.health,
      getMax: () => monster.baseHealth,
      position: Vector2(8, height - 18),
      size: Vector2(width * 0.55, 14),
    );

    add(spriteComponent);
    add(_hpBubble);
  }

  void takeDamage(int damage) {
    monster.takeDamage(damage);
    final spriteComponent = _spriteComponent;
    if (spriteComponent != null) {
      final hitEffect = ColorEffect(
        Colors.red.withValues(alpha: 0.5),
        EffectController(duration: 0.1, reverseDuration: 0.1),
      );
      spriteComponent.add(hitEffect);
    }

    // Add damage popup at center of monster
    final popupPosition = Vector2(width / 2, height / 3);
    final damagePopup = DamagePopupComponent(
      damage: damage,
      position: popupPosition,
    );
    damagePopup.priority = priority + 1;
    add(damagePopup);
  }

  void attack({
    required PositionComponent target,
    required VoidCallback applyDamage,
    required VoidCallback onAttackFinished,
  }) {
    final attackerCenter = position + Vector2(width / 2, height / 2);
    final targetCenter =
        target.position + Vector2(target.size.x / 2, target.size.y / 2);
    final moveVector = (targetCenter - attackerCenter) * 0.5;

    final reverseAttackEffect = MoveByEffect(
      -moveVector,
      EffectController(duration: 0.3),
      onComplete: () {
        onAttackFinished();
      },
    );

    final attackEffect = MoveByEffect(
      moveVector,
      EffectController(duration: 0.3),
      onComplete: () {
        applyDamage();
        add(reverseAttackEffect);
      },
    );

    add(attackEffect);
  }
}
