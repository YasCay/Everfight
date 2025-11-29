import 'package:everfight/util/size_utils.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:everfight/models/monster.dart';

Color _tierColor(int tier) {
  switch (tier) {
    case 1: return Colors.grey;
    case 2: return Colors.blueAccent;
    case 3: return Colors.purpleAccent;
    case 4: return Colors.orangeAccent;
    default: return Colors.white24;
  }
}

class CandidateCard extends StatelessWidget {
  final Monster monster;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const CandidateCard({
    super.key,
    required this.monster,
    this.onTap,
    this.width = 200,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    final boxSize = SizeUtils.scalePercentage(height, 2.75);
    final imageSize = SizeUtils.scalePercentage(height, 40);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: width,
            height: height,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _tierColor(monster.tier),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  monster.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: boxSize),
                Text(
                  'HP: ${monster.baseHealth}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  'ATK: ${monster.baseAttack}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: boxSize),
                Image.asset(
                  "assets/images/${monster.imagePath}",
                  height: imageSize,
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _tierColor(monster.tier).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "T${monster.tier}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
