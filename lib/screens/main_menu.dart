import 'package:everfight/game/game_state.dart';
import 'package:everfight/logic/game_class.dart';
import 'package:everfight/widgets/rectangle_button.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MainMenu extends Component with HasGameReference<RogueliteGame> {
  late TextPaint _titlePaint;
  bool _initialized = false;

  @override
  Future<void> onLoad() async {
    _titlePaint = TextPaint(
      style: const TextStyle(
        fontSize: 36,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!_initialized && size.x > 0 && size.y > 0) {
      _initialized = true;
      _buildUI(size);
    }
  }

  Future<void> _buildUI(Vector2 size) async {
    removeAll(children.toList());

    // Background image with dark overlay
    add(SpriteComponent(
      sprite: Sprite(await game.images.load('general/splash_bg.png')),
      size: size.clone(),
      position: Vector2.zero(),
      anchor: Anchor.topLeft, 
      priority: -2,
    ));
    add(RectangleComponent(
      position: Vector2.zero(),
      size: size.clone(),
      paint: Paint()..color = Colors.black.withOpacity(0.6),
      priority: -1,
    ));

    // Title
    add(TextComponent(
      text: 'Everfight',
      textRenderer: _titlePaint,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y * 0.2),
    ));

    // Buttons
    const buttonWidth = 260.0;
    const buttonHeight = 56.0;
    const spacing = 20.0;
    final totalButtons = 3;
    final totalHeight = totalButtons * buttonHeight + (totalButtons - 1) * spacing;
    final startY = (size.y - totalHeight) / 2 + 40;

    final buttons = [
      {
        'label': 'Start Run',
        'action': () {
          game.router.pushReplacementNamed('game');
          game.state = GameState.idle;
        },
        'color': ButtonColorType.green,
        'icon': Icons.arrow_forward,
      },
      {
        'label': 'Achievements',
        'action': () => game.router.pushReplacementNamed('achievements'),
        'color': ButtonColorType.orange,
        'icon': Icons.star,
      },
      {
        'label': 'Unlockables',
        'action': () => game.router.pushReplacementNamed('unlockables'),
        'color': ButtonColorType.pink,
        'icon': Icons.lock_open,
      },
    final buttons = <Map<String, VoidCallback>>[
      {'Start Run': () => {
        game.state = GameState.idle,
        game.router.pushReplacementNamed('game')
      }},
      {'Achievements': () => game.router.pushReplacementNamed('achievements')},
      {'Unlockables': () => game.router.pushReplacementNamed('unlockables')},
    ];

    for (int i = 0; i < buttons.length; i++) {
      final btn = buttons[i];
      add(RectangleButton(
        label: btn['label'] as String,
        position: Vector2(size.x / 2 - buttonWidth / 2, startY + i * (buttonHeight + spacing)),
        size: Vector2(buttonWidth, buttonHeight),
        onPressed: btn['action'] as VoidCallback,
        colorType: btn['color'] as ButtonColorType,
        icon: btn['icon'] as IconData?,
      ));
    }
  }
}