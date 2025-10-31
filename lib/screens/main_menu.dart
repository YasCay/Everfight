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

  void _buildUI(Vector2 size) {
    removeAll(children.toList());

    // Full-screen background
    add(RectangleComponent(
      position: Vector2.zero(),
      size: size.clone(),
      paint: Paint()..color = Colors.black87,
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

    final buttons = <Map<String, VoidCallback>>[
      {'Start Run': () => {
        game.state = GameState.idle,
        game.router.pushReplacementNamed('game')
      }},
      {'Achievements': () => game.router.pushReplacementNamed('achievements')},
      {'Unlockables': () => game.router.pushReplacementNamed('unlockables')},
    ];

    for (int i = 0; i < buttons.length; i++) {
      final label = buttons[i].keys.first;
      final action = buttons[i][label]!;

      add(RectangleButton(
        label: label,
        position: Vector2(size.x / 2 - buttonWidth / 2, startY + i * (buttonHeight + spacing)),
        size: Vector2(buttonWidth, buttonHeight),
        onPressed: action,
      ));
    }
  }
}