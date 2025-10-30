enum GameState {
  idle,
  inCombat,
  selecting,
  victory,
  defeat,
  reward,
  inMenues,
}

/*
  "init" --> inMenues
  inMenues --> selecting (on start run)
  selecting --> inCombat (on monster pick)
  inCombat --> victory (on boss defeat)
  inCombat --> defeat (on team defeat)
  victory --> selecting (if more bosses)
  victory --> inMenues (if all bosses defeated)
  defeat --> inMenues
*/
