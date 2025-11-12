import 'package:flutter/material.dart' hide Element;
import 'package:everfight/models/monster.dart';

class CandidateCard extends StatelessWidget {
  final Monster monster;
  final VoidCallback? onTap;
  final double width;

  const CandidateCard({
    super.key,
    required this.monster,
    this.onTap,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Text(
              monster.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'HP: ${monster.baseHealth}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            Text(
              'ATK: ${monster.baseAttack}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Image.asset(
              "assets/images/${monster.imagePath}",
              height: 90,
            ),
          ],
        ),
      ),
    );
  }
}
