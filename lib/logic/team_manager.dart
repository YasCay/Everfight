import 'package:everfight/models/monster.dart';
import 'package:flutter/material.dart';

class TeamManager extends ChangeNotifier {
  final List<Monster> _team = [];

  List<Monster> get team => List.unmodifiable(_team);

  void add(Monster m) {
    _team.add(m);

    m.addListener(notifyListeners);
    notifyListeners();
  }

  void remove(Monster m) {
    m.removeListener(notifyListeners);
    _team.remove(m);
    notifyListeners();
  }

  void clear() {
    for (var m in _team) {
      m.removeListener(notifyListeners);
    }
    _team.clear();
    notifyListeners();
  }
}
