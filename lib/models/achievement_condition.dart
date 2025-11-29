class AchievementCondition {
  final String stat;
  final String operator;
  final dynamic value;

  AchievementCondition({
    required this.stat,
    required this.operator,
    required this.value,
  });

  factory AchievementCondition.fromJson(Map<String, dynamic> json) {
    return AchievementCondition(
      stat: json['stat'],
      operator: json['operator'],
      value: json['value'],
    );
  }
}
