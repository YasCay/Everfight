class GameAssets {
  static const monsters = [
    'fakemons/air/Stormgryph_front.png',
    'fakemons/air/Galehawk_front.png',
    'fakemons/air/HazeFairy_front.png',
    'fakemons/air/Whirlstag_front.png',
    'fakemons/earth/Basaltor_front.png',
    'fakemons/earth/Claywolf_front.png',
    'fakemons/earth/Mudcrust_front.png',
    'fakemons/earth/Thornolotl_front.png',
    'fakemons/fire/Ashblade_front.png',
    'fakemons/fire/CoalGolem_front.png',
    'fakemons/fire/Pyrosalamander_front.png',
    'fakemons/fire/Sparkfinch_front.png',
    'fakemons/water/Tidepanzer_front.png',
    'fakemons/water/MistRay_front.png',
    'fakemons/water/Splashling_front.png',
    'fakemons/water/Voltcarp_front.png',
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
