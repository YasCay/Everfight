import 'package:everfight/game/game_state.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:everfight/main.dart';
import 'package:everfight/models/monster.dart';
import 'package:everfight/models/enums.dart';
import 'package:everfight/game/scaling.dart';

class MonsterSelectionOverlay extends StatelessWidget {
  final RogueliteGame game;
  const MonsterSelectionOverlay({super.key, required this.game});

  bool get isFirstPick => game.playerTeam.isEmpty;

  @override
  Widget build(BuildContext context) {
    final baseMonsters = [
      Monster(
        name: 'Leaflet',
        baseHealth: 90,
        baseAttack: 10,
        baseDefense: 3,
        rarity: "common",
        element: Element.earth,
        imagePath: 'monster_earth.jpeg',
      ),
      Monster(
        name: 'Wavey',
        baseHealth: 80,
        baseAttack: 18,
        baseDefense: 2,
        rarity: "uncommon",
        element: Element.water,
        imagePath: 'monster_water.jpeg',
      ),
      Monster(
        name: 'Sparklet',
        baseHealth: 70,
        baseAttack: 20,
        baseDefense: 1,
        rarity: "uncommon",
        element: Element.fire,
        imagePath: 'monster_fire.jpeg',
      ),
    ];

    final candidates =
        baseMonsters
            .map((m) => Scaling.scalePlayer(m, game.currentBossIndex))
            .toList();

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isFirstPick
                  ? 'Choose your first Monster!'
                  : 'Recruit a new Monster!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              children:
                  candidates.map((m) {
                    return GestureDetector(
                      onTap: () {
                        game.playerTeam.add(m);
                        game.hideMonsterSelection();

                        if (isFirstPick) {
                          game.currentBossIndex = 0;
                        }

                        game.router.pushNamed('game');
                        game.state = GameState.idle;
                      },
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          children: [
                            Text(
                              m.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'HP: ${m.baseHealth}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'ATK: ${m.baseAttack}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Image.asset(
                              "assets/images/${m.imagePath}",
                              height: 60,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
