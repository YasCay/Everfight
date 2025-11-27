// import 'package:flutter/material.dart';
// import 'package:everfight/logic/game_class.dart';

// class PauseMenuOverlay extends StatelessWidget {
//   final RogueliteGame game;
//   const PauseMenuOverlay({super.key, required this.game});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.black.withValues(alpha: 0.7),
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.blueGrey[900],
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text('Paused', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   game.resumeEngine();
//                   game.hidePauseMenu();
//                 },
//                 child: const Text('Resume'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   game.resetRun();
//                   game.hidePauseMenu();
//                 },
//                 child: const Text('Restart'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   game.resumeEngine();
//                   game.hidePauseMenu();
//                   game.router.pushReplacementNamed('menu');
//                 },
//                 child: const Text('Quit to Menu'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:everfight/widgets/flutter_rectangle_button.dart';
import 'package:flutter/material.dart';
import 'package:everfight/logic/game_class.dart';
import 'package:everfight/util/size_utils.dart';

class PauseMenuOverlay extends StatelessWidget {
  final RogueliteGame game;

  const PauseMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final size = game.size;
    final spacing = SizeUtils.scalePercentage(size.y, 3);

    final buttons = [
      {
        'label': 'Resume',
        'action': () {
          game.resumeEngine();
          game.hidePauseMenu();
        },
        'color': ButtonColorType.green,
        'icon': Icons.play_arrow,
      },
      {
        'label': 'Restart',
        'action': () {
          game.resetRun();
          game.hidePauseMenu();
        },
        'color': ButtonColorType.orange,
        'icon': Icons.refresh,
      },
      {
        'label': 'Quit to Menu',
        'action': () {
          game.resumeEngine();
          game.hidePauseMenu();
          game.router.pushReplacementNamed('menu');
        },
        'color': ButtonColorType.pink,
        'icon': Icons.exit_to_app,
      },
    ];

    final buttonLabels = buttons.map((b) => b['label'] as String).toList();

    return Material(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blueGrey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Paused',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: SizeUtils.scalePercentage(size.y, 3)),

              // BUILD MENU BUTTONS
              for (int i = 0; i < buttons.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == buttons.length - 1 ? 0 : spacing),
                  child: FlutterRectangleButton(
                    label: buttons[i]['label'] as String,
                    onPressed: buttons[i]['action'] as VoidCallback,
                    colorType: buttons[i]['color'] as ButtonColorType,
                    icon: buttons[i]['icon'] as IconData?,
                    groupTexts: buttonLabels,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
