import 'dart:convert';

import 'package:everfight/models/enums.dart';
import 'package:everfight/models/monster_template.dart';
import 'package:flutter/services.dart';

class MonsterRepository {
  static final MonsterRepository _instance = MonsterRepository._internal();
  factory MonsterRepository() => _instance;
  MonsterRepository._internal();

  List<MonsterTemplate> allTemplates = [];

  Map<Element, Map<int, MonsterTemplate>> templateMap = {};

  Future<void> load() async {
    final jsonString = await rootBundle.loadString('assets/data/monster.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    allTemplates = jsonList
        .map((json) => MonsterTemplate.fromJson(json))
        .toList();

    _buildTemplateMap();
  }

  void _buildTemplateMap() {
    templateMap = {};

    for (var template in allTemplates) {
      templateMap.putIfAbsent(template.element, () => {});
      templateMap[template.element]![template.tier] = template;
    }
  }
}
