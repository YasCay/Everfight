import 'package:flutter/material.dart';
import 'package:everfight/logic/game_class.dart';

class PauseMenuOverlay extends StatelessWidget {
  final RogueliteGame game;
  const PauseMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blueGrey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Paused', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  game.resumeEngine();
                  game.hidePauseMenu();
                },
                child: const Text('Resume'),
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     game.resumeEngine();
              //     game.hidePauseMenu();
              //     game.resetRun(); // you can define this in your game class
              //   },
              //   child: const Text('Restart'),
              // ),
              ElevatedButton(
                onPressed: () {
                  game.resumeEngine();
                  game.hidePauseMenu();
                  game.router.pushReplacementNamed('menu');
                },
                child: const Text('Quit to Menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
