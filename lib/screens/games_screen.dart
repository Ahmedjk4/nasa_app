import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nasa_app/generated/l10n.dart';
import 'package:nasa_app/utils/app_router.dart';

class Game {
  final String title;
  final String description;
  final String image;

  Game({required this.title, required this.description, required this.image});
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Game> games = [
      Game(
        title: S.of(context).puzzleTitle,
        description: S.of(context).puzzleDesc,
        image: "assets/images/puzzleLogo.png",
      ),
      Game(
        title: S.of(context).spaceRacingTitle,
        description: S.of(context).spaceRacingDesc,
        image: "assets/images/spaceShipLogo.png",
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Games", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- List with Image + Title + Description ---
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        game.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      game.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(game.description),
                    onTap: () {
                      switch (index) {
                        case 0:
                          context.push(AppRouter.puzzleGame);
                          break;
                        case 1:
                          context.push(AppRouter.raceGame);
                          break;
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
