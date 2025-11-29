import 'package:everfight/models/enums.dart';

class TierUnlocks {
  final Map<Element, int> unlockedTiers;

  TierUnlocks({required this.unlockedTiers});

  int getUnlockedTier(Element element) {
    return unlockedTiers[element] ?? 1;
  }

  factory TierUnlocks.fromJson(Map<String, dynamic> json) {
    final Map<Element, int> tiers = {};
    json.forEach((key, value) {
      final element =
          Element.values.firstWhere((e) => e.toString() == 'Element.$key');
      tiers[element] = value;
    });
    return TierUnlocks(unlockedTiers: tiers);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    unlockedTiers.forEach((key, value) {
      json[key.toString().split('.').last] = value;
    });
    return json;
  }
}
