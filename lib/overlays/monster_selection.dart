import 'package:everfight/logic/game_class.dart';
import 'package:everfight/overlays/monster_exchange.dart';
import 'package:everfight/util/size_utils.dart';
import 'package:everfight/widgets/candidate_card.dart';
import 'package:flutter/material.dart' hide Element;

class MonsterSelectionOverlay extends StatelessWidget {
  final RogueliteGame game;
  const MonsterSelectionOverlay({super.key, required this.game});

  bool get isFirstPick => game.teamManager.team.isEmpty;

  @override
  Widget build(BuildContext context) {
    final teamManager = game.teamManager;
    final padding = EdgeInsets.all(SizeUtils.scalePercentage(game.size.x, 2.5));
    final boxHeight = SizeUtils.scalePercentage(game.size.y, 2.5);
    final boxSpacing = SizeUtils.scalePercentage(game.size.x, 1.85);
    
    final width = SizeUtils.scalePercentage(game.size.x, 100);
    final height = SizeUtils.scalePercentage(game.size.y, 100);

    // Generate 3 candidates
    final candidates = teamManager.getRecruitmentCandidates(level: game.currentLevel);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Container(
            padding: padding,
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
                SizedBox(height: boxHeight),
                Wrap(
                  spacing: boxSpacing,
                  runSpacing: boxSpacing,
                  alignment: WrapAlignment.center,
                  children: candidates.map((m) => CandidateCard(
                    monster: m,
                    onTap: () {
                        if (!teamManager.isFull) {
                          // Add normally if there's space
                          teamManager.addOrExchange(m);
                          game.hideMonsterSelection();
                        } else {
                          // Open exchange dialog
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              opaque: false,
                              barrierColor: Colors.black.withValues(alpha: 0.8),
                              pageBuilder: (_, __, ___) => MonsterExchangeOverlay(
                                game: game,
                                newMonster: m,
                              ),
                            ),
                          );
                        }
                      },
                    width: SizeUtils.scalePercentage(game.size.x, 25),
                    height: SizeUtils.scalePercentage(game.size.y, 55),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
