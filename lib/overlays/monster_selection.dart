import 'package:everfight/logic/game_class.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:everfight/models/monster.dart';
import 'package:everfight/models/enums.dart';

class MonsterSelectionOverlay extends StatelessWidget {
  final RogueliteGame game;
  const MonsterSelectionOverlay({super.key, required this.game});

  bool get isFirstPick => game.playerTeam.team.isEmpty;

  @override
  Widget build(BuildContext context) {
    final totalCandidates = [
      Monster(name: 'Basaltor', baseHealth: 90, baseAttack: 10, element: Element.earth, imagePath: 'fakemons/earth/Basaltor_front.png'),
      Monster(name: 'Tidepanzer', baseHealth: 80, baseAttack: 18, element: Element.water, imagePath: 'fakemons/water/Tidepanzer_front.png'),
      Monster(name: 'Ashblade', baseHealth: 70, baseAttack: 20, element: Element.fire, imagePath: 'fakemons/fire/Ashblade_front.png'),
      Monster(name: 'Stormgryph', baseHealth: 70, baseAttack: 20, element: Element.air, imagePath: 'fakemons/air/Stormgryph_front.png'),
    ];

    final candidates = (totalCandidates..shuffle()).take(3).toList();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isFirstPick ? 'Choose your first Monster!' : 'Recruit a new Monster!',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  children: candidates.map((m) {
                    return GestureDetector(
                      onTap: () {
                        game.playerTeam.add(m);
                        game.hideMonsterSelection();

                        if (isFirstPick) game.currentBossIndex = 0;

                        game.router.pushNamed('game');
                        game.phaseController.onTeamSelected();
                      },
                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          children: [
                            Text(m.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
                            const SizedBox(height: 6),
                            Text('HP: ${m.baseHealth}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                            Text('ATK: ${m.baseAttack}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                            const SizedBox(height: 6),
                            Image.asset("assets/images/${m.imagePath}", height: 90),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
