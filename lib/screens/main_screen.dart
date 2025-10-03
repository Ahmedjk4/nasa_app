import 'package:flutter/material.dart';
import 'package:nasa_app/generated/l10n.dart';
import 'package:nasa_app/providers/language_provider.dart';
import 'package:nasa_app/screens/certificate_screen.dart';
import 'package:nasa_app/screens/games_screen.dart';

import 'package:nasa_app/screens/home_screen.dart';
import 'package:nasa_app/screens/profile_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final List<Widget> _screens = [
    HomeScreen(),
    CertificateScreen(),
    GameScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) => Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: Color(0xFF3A506B),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
              _pageController.jumpToPage(index);
            });
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: S.of(context).home,
            ),
            NavigationDestination(
              icon: Icon(Icons.star),
              label: S.of(context).cert,
            ),
            NavigationDestination(
              icon: Icon(Icons.games),
              label: S.of(context).games,
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: S.of(context).profile,
            ),
          ],
        ),
      ),
    );
  }
}
