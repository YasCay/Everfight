import 'package:everfight/models/achievement.dart';
import 'package:everfight/models/statistics.dart';
import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  final List<Achievement> achievements;
  final Statistics stats;
  final bool isUnlockableScreen;

  const AchievementsScreen({
    super.key,
    required this.achievements,
    required this.stats,
    required this.isUnlockableScreen
  });

  double _progress(Achievement a) {
    final current = stats.getStatValue(a.condition.stat);
    final target = a.condition.value;

    if (current >= target) return 1.0;
    return current / target;
  }

  @override
  Widget build(BuildContext context) {
    var title = isUnlockableScreen ? "Unlockables" : "Achievements";
    var elements = isUnlockableScreen
        ? achievements.where((a) => a.unlock != null).toList()
        : achievements.where((a) => a.unlock == null).toList();

    final sorted = [...elements]
      ..sort((a, b) => _progress(b).compareTo(_progress(a)));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: sorted.length,
        itemBuilder: (context, i) {
          final a = sorted[i];
          var p = _progress(a);

          if (a.unlocked) {
            p = 1.0;
          }

          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(a.title, style: const TextStyle(fontSize: 18)),
                      if (a.unlocked)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(a.description),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: p,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 6),
                  Text("${(p * 100).toStringAsFixed(0)}%"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
