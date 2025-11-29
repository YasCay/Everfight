import 'package:everfight/models/achievement.dart';
import 'package:everfight/models/statistics.dart';
import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  final List<Achievement> achievements;
  final Statistics stats;

  const AchievementsScreen({
    super.key,
    required this.achievements,
    required this.stats,
  });

  double _progress(Achievement a) {
    final current = stats.getStatValue(a.condition.stat);
    final target = a.condition.value;

    if (current >= target) return 1.0;
    return current / target;
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...achievements]
      ..sort((a, b) => _progress(b).compareTo(_progress(a)));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: sorted.length,
        itemBuilder: (context, i) {
          final a = sorted[i];
          final p = _progress(a);

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
