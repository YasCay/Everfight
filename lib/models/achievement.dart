import 'package:everfight/models/achievement_condition.dart';
import 'package:everfight/models/unlockable_action.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementCondition condition;
  final UnlockableAction? unlock;
  bool unlocked = false;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.condition,
    this.unlock,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      condition: AchievementCondition.fromJson(json['condition']),
      unlock: UnlockableAction.fromJson(json['unlock']),
    );
  }
}
