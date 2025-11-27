import 'dart:convert';

import 'package:everfight/models/boss_template.dart';
import 'package:flutter/services.dart';

class BossRepository {
  static final BossRepository _instance = BossRepository._internal();
  factory BossRepository() => _instance;
  BossRepository._internal();

  List<BossTemplate> templates = [];

  Future<void> load() async {
    final jsonString = await rootBundle.loadString('assets/data/boss.json');
    final List<dynamic> data = json.decode(jsonString);
    templates = data.map((e) => BossTemplate.fromJson(e)).toList();
  }
}
