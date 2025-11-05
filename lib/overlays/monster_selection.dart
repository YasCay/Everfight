import 'package:everfight/logic/game_class.dart';
import 'package:flutter/material.dart' hide Element;

class MonsterSelectionOverlay extends StatelessWidget {
  final RogueliteGame game;
  const MonsterSelectionOverlay({super.key, required this.game});

  bool get isFirstPick => game.teamManager.team.isEmpty;

  @override
  Widget build(BuildContext context) {
    final candidates = game.teamManager.getRecruitmentCandidates(level: game.currentLevel);

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
                        game.teamManager.add(m);
                        game.hideMonsterSelection();

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
