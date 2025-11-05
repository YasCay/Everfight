import 'package:everfight/logic/game_class.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:everfight/models/monster.dart';

class MonsterSelectionOverlay extends StatelessWidget {
  final RogueliteGame game;
  const MonsterSelectionOverlay({super.key, required this.game});

  bool get isFirstPick => game.teamManager.team.isEmpty;

  @override
  Widget build(BuildContext context) {
    final teamManager = game.teamManager;

    // Generate 3 candidates
    final candidates = teamManager.getRecruitmentCandidates(level: game.currentLevel);

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
              color: Colors.blueGrey[900],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isFirstPick
                      ? 'Choose your first Monster!'
                      : teamManager.isFull
                          ? 'Your team is full! Choose a monster to replace:'
                          : 'Recruit a new Monster!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: candidates.map((m) {
                    return GestureDetector(
                      onTap: () {
                        if (!teamManager.isFull) {
                          // Add normally if there's space
                          teamManager.add(m);
                          game.hideMonsterSelection();
                        } else {
                          // Open exchange dialog
                          _showExchangeDialog(context, m);
                        }
                        game.phaseController.onTeamSelected();
                      },
                      child: _buildCandidateCard(m),
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

  Widget _buildCandidateCard(Monster m) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(m.name,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
          const SizedBox(height: 6),
          Text('HP: ${m.baseHealth}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text('ATK: ${m.baseAttack}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 6),
          Image.asset("assets/images/${m.imagePath}", height: 90),
        ],
      ),
    );
  }

  void _showExchangeDialog(BuildContext context, Monster newMonster) {
    final teamManager = game.teamManager;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[900],
          title: const Text(
            'Team Full!',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select a monster to replace or skip:',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: teamManager.team.length,
                    itemBuilder: (context, index) {
                      final current = teamManager.team[index];
                      return ListTile(
                        tileColor: Colors.blueGrey.withValues(alpha: 0.3),
                        title: Text(current.name, style: const TextStyle(color: Colors.white)),
                        subtitle: Text('HP: ${current.baseHealth}, ATK: ${current.baseAttack}',
                            style: const TextStyle(color: Colors.white70)),
                        trailing: Image.asset("assets/images/${current.imagePath}", height: 40),
                        onTap: () {
                          // Replace selected monster
                          teamManager.addOrExchange(newMonster, exchangeIndex: index);
                          Navigator.of(context).pop();
                          game.hideMonsterSelection();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Skip button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                  ),
                  onPressed: () {
                    // Skip exchanging, keep current team
                    Navigator.of(context).pop();
                    game.teamManager.rerenderTeam();
                    game.hideMonsterSelection();
                  },
                  child: const Text('Skip', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
