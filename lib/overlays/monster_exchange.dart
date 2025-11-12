import 'package:flutter/material.dart' hide Element;
import 'package:everfight/logic/game_class.dart';
import 'package:everfight/models/monster.dart';
import 'package:everfight/widgets/candidate_card.dart';

class MonsterExchangeOverlay extends StatelessWidget {
  final RogueliteGame game;
  final Monster newMonster;

  const MonsterExchangeOverlay({
    super.key,
    required this.game,
    required this.newMonster,
  });

  @override
  Widget build(BuildContext context) {
    final teamManager = game.teamManager;
    final team = teamManager.team;

    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 800,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueGrey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Header row: title + skip button inline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Team Full!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      game.teamManager.rerenderTeam();
                      game.hideMonsterSelection();
                    },
                    child: const Text('Skip'),
                  ),
                ],
              ),

              Text(
                'Replace one of your monsters with ${newMonster.name}:',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: team.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final current = team[index];
                    return CandidateCard(
                      monster: current,
                      onTap: () {
                        teamManager.addOrExchange(newMonster, exchangeIndex: index);
                        Navigator.of(context).pop();
                        game.hideMonsterSelection();
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),
              const Icon(Icons.swipe, color: Colors.white38, size: 20),
              const Text('Swipe to see all monsters', style: TextStyle(color: Colors.white38, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
