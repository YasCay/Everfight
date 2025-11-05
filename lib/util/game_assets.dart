class GameAssets {
  static const monsters = [
    'fakemons/air/Stormgryph_front.png',
    'fakemons/earth/Basaltor_front.png',
    'fakemons/fire/Ashblade_front.png',
    'fakemons/water/Tidepanzer_front.png',
  ];

  static const bosses = [
    'boss/air/Zephyra_front.png',
    'boss/earth/Terragron_front.png',
    'boss/fire/Infernakor_front.png',
    'boss/water/Tidalion_front.png',
  ];

  static const backgrounds = [
    'fightscene/air/air_scene.png',
    'fightscene/earth/earth_scene.png',
    'fightscene/fire/fire_scene.png',
    'fightscene/water/water_scene.png',
    'general/splash_bg.png',
  ];

  static List<String> get all => [
        ...monsters,
        ...bosses,
        ...backgrounds,
      ];
}
