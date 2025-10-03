import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nasa_app/generated/l10n.dart';
import 'package:nasa_app/utils/app_router.dart';
import 'package:nasa_app/utils/hive_functions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int currentStep = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic> responses = {'language': '', 'isFirstTime': 0};

  final List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇪🇬'},
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start welcome animation
    _startWelcomeSequence();
  }

  void _startWelcomeSequence() {
    Future.delayed(Duration(milliseconds: 500), () {
      _fadeController.forward();
    });

    Future.delayed(Duration(milliseconds: 3000), () {
      setState(() {
        currentStep = 1;
      });
      _slideController.forward();
    });
  }

  void _nextStep() {
    _slideController.reset();
    setState(() {
      currentStep++;
    });
    _slideController.forward();
  }

  void _handleLanguageSelect(String langCode, String langName) async {
    setState(() {
      responses['language'] = langName;
    });
    if (langCode == 'ar') {
      S.load(const Locale('ar'));
      await HiveFunctions.putData('lang', 'ar');
    } else {
      S.load(const Locale('en'));
      await HiveFunctions.putData('lang', 'en');
    }
    Future.delayed(Duration(milliseconds: 800), () {
      _nextStep();
    });
  }

  void _handleFirstTimeSelect(int exp) {
    setState(() {
      responses['isFirstTime'] = exp;
    });

    _nextStep();
  }

  void _resetOnboarding() {
    _fadeController.reset();
    _slideController.reset();
    setState(() {
      currentStep = 0;
      responses = {'language': '', 'isFirstTime': null};
    });
    _startWelcomeSequence();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B132B), // deep navy
              Color(0xFF1C2541), // dark blue
              Color(0xFF3A506B), // blue-gray
              Color(0xFF5BC0BE), // teal glow
              Color(0xFF0B132B), // back to deep navy
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: _buildCurrentStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildLanguageStep();
      case 2:
        return _buildFirstTimeStep();
      case 3:
        return _buildCompletionStep();
      default:
        return _buildWelcomeStep();
    }
  }

  Widget _buildWelcomeStep() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            margin: EdgeInsets.only(bottom: 32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Center(child: Text('👋', style: TextStyle(fontSize: 48))),
          ),
          Text(
            'Welcome',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Let\'s get you started',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose Your Language',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Select your preferred language',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final lang = languages[index];
              return _buildLanguageCard(
                lang['code']!,
                lang['name']!,
                lang['flag']!,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(String code, String name, String flag) {
    return GestureDetector(
      onTap: () => _handleLanguageSelect(code, name),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstTimeStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            margin: EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(child: Text('🤔', style: TextStyle(fontSize: 32))),
          ),
          Text(
            S.of(context).experience,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            S.of(context).experienceTip,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 40),
          Column(
            children: [
              _buildOptionButton(
                S.of(context).beginner,
                () => _handleFirstTimeSelect(0),
              ),
              SizedBox(height: 16),
              _buildOptionButton(
                S.of(context).intermediate,
                () => _handleFirstTimeSelect(1),
              ),
              SizedBox(height: 16),
              _buildOptionButton(
                S.of(context).expert,
                () => _handleFirstTimeSelect(2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            margin: EdgeInsets.only(bottom: 32),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(child: Text('🎉', style: TextStyle(fontSize: 40))),
          ),
          Text(
            S.of(context).finishOnboardingTitle,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            S.of(context).finishOnboardingSubtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryItem(
                  S.of(context).language,
                  responses['language'],
                ),
                SizedBox(height: 12),
                _buildSummaryItem(
                  S.of(context).knowledgeLevel,
                  responses['isFirstTime'] == 0
                      ? S.of(context).beginnerLevel
                      : responses['isFirstTime'] == 1
                      ? S.of(context).intermediateLevel
                      : S.of(context).expertLevel,
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    S.of(context).startOver,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await HiveFunctions.putData('finishedOnboarding', true);
                    if (mounted) context.go(AppRouter.authPath);
                    debugPrint('Onboarding completed with: $responses');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    S.of(context).getStarted,
                    style: TextStyle(
                      color: Color(0xFF1e3c72),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
