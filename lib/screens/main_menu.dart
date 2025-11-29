import 'package:everfight/logic/achievement_manager.dart';
import 'package:everfight/logic/game_class.dart';
import 'package:everfight/logic/statistics_manager.dart';
import 'package:everfight/screens/achievements.dart';
import 'package:everfight/util/size_utils.dart';
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
        fontSize: 48,
        color: Color(0xFFFFD700), // Goldgelb
        fontWeight: FontWeight.w900,
        fontFamily:
            'Orbitron', // Eigene Schriftart, in pubspec.yaml registrieren!
        letterSpacing: 3,
        shadows: [
          Shadow(
            offset: Offset(0, 4),
            blurRadius: 12,
            color: Colors.black87,
          ),
          Shadow(
            offset: Offset(0, 0),
            blurRadius: 24,
            color: Color.fromARGB(255, 10, 44, 101), // dunkler Goldton
          ),
        ],
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
      paint: Paint()..color = Colors.black.withValues(alpha: 0.6),
      priority: -1,
    ));

    // Title
    add(TextComponent(
      text: 'EVERFIGHT',
      textRenderer: _titlePaint,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y * 0.2),
    ));

    // Buttons
    final buttonWidth = SizeUtils.scalePercentage(size.x, 30);
    final buttonHeight = SizeUtils.scalePercentage(size.y, 14);
    final spacing = SizeUtils.scalePercentage(size.y, 5);
    final totalButtons = 3;
    final totalHeight =
        totalButtons * buttonHeight + (totalButtons - 1) * spacing;
    final startY =
        (size.y - totalHeight) / 2 + SizeUtils.scalePercentage(size.y, 10);

    final buttons = [
      {
        'label': 'Start Run',
        'action': () {
          game.router.pushReplacementNamed('game');
        },
        'color': ButtonColorType.green,
        'icon': Icons.arrow_forward,
      },
      {
        'label': 'Achievements',
        'action': () => {
              Navigator.push(
                game.buildContext!,
                MaterialPageRoute(
                  builder: (_) => AchievementsScreen(
                    achievements: AchievementManager().achievements,
                    stats: StatisticsManager().statistics,
                  ),
                ),
              )
            },
        'color': ButtonColorType.orange,
        'icon': Icons.star,
      },
      {
        'label': 'Unlockables',
        'action': () => game.router.pushReplacementNamed('unlockables'),
        'color': ButtonColorType.pink,
        'icon': Icons.lock_open,
      },
    ];

    final buttonLabels = buttons.map((b) => b['label'] as String).toList();

    for (int i = 0; i < buttons.length; i++) {
      final btn = buttons[i];
      add(RectangleButton(
        label: btn['label'] as String,
        position: Vector2(size.x / 2 - buttonWidth / 2,
            startY + i * (buttonHeight + spacing)),
        size: Vector2(buttonWidth, buttonHeight),
        onPressed: btn['action'] as VoidCallback,
        colorType: btn['color'] as ButtonColorType,
        icon: btn['icon'] as IconData?,
        groupTexts: buttonLabels,
      ));
    }
  }
}
