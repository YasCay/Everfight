class UnlockableAction {
  final String type;
  final String rewardType;
  final dynamic data;

  UnlockableAction({
    required this.type,
    required this.rewardType,
    required this.data,
  });

  static UnlockableAction? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return UnlockableAction(
      type: json['type'],
      rewardType: json['reward_type'],
      data: json['data'],
    );
  }
}