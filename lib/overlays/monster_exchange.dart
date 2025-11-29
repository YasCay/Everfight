import 'package:everfight/util/size_utils.dart';
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

    final width = SizeUtils.scalePercentage(game.size.x, 80);
    final height = SizeUtils.scalePercentage(game.size.y, 80);
    final padding = SizeUtils.scalePercentage(game.size.x, 1.85);
    final boxSize = SizeUtils.scalePercentage(game.size.x, 1.5);
    final candidateHeight = SizeUtils.scalePercentage(height, 60);

    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: width,
              height: height,
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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

                  SizedBox(height: boxSize),

                  SizedBox(
                    height: candidateHeight,
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
                          width: SizeUtils.scalePercentage(game.size.x, 25),
                          height: candidateHeight,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: SizeUtils.scalePercentage(game.size.y, 3),
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Icon(Icons.swipe, color: Colors.white38, size: 20),
                SizedBox(height: 4),
                Text(
                  'Swipe to see all monsters',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
