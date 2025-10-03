import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nasa_app/generated/l10n.dart';
import 'package:nasa_app/utils/app_router.dart';
import 'package:nasa_app/utils/hive_functions.dart';
import 'package:nasa_app/widgets/liquid_gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    setLang();
    navigateNext();
    super.initState();
  }

  Future<void> setLang() async {
    String? langCode = await HiveFunctions.getData('lang');
    if (langCode == null) {
      S.load(const Locale('en'));
    } else {
      if (langCode == 'ar') {
        S.load(const Locale('ar'));
      } else {
        S.load(const Locale('en'));
      }
    }
  }

  Future<void> navigateNext() async {
    bool? finishedOnboarding = await HiveFunctions.getData(
      'finishedOnboarding',
    );
    if (finishedOnboarding == null || finishedOnboarding == false) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) context.pushReplacement(AppRouter.onboardingPath);
      });
    } else if (finishedOnboarding == true) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) context.pushReplacement(AppRouter.controlFlow);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          LiquidGradientBackground(),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 10,
                children: [
                  Image.asset('assets/images/nasa_cairo_logo.png', height: 40),
                  Image.asset(
                    'assets/images/nasa_international_logo.jpg',
                    height: 40,
                  ),
                  Image.asset('assets/images/moe_eg.jpeg', height: 40),
                ],
              ),
            ),
          ),
          Center(
            child: SizedBox(
              height: 100,
              width: 100,
              child: CircleAvatar(
                radius: 12,
                child: ClipOval(
                  child: Image.asset('assets/images/app_logo.jpeg'),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Team Space Zone',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black54,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
