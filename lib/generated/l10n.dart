// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Do You Know Anything About Space Weather?`
  String get experience {
    return Intl.message(
      'Do You Know Anything About Space Weather?',
      name: 'experience',
      desc: '',
      args: [],
    );
  }

  /// `This help us customize your experience`
  String get experienceTip {
    return Intl.message(
      'This help us customize your experience',
      name: 'experienceTip',
      desc: '',
      args: [],
    );
  }

  /// `I know nothing about space weather`
  String get beginner {
    return Intl.message(
      'I know nothing about space weather',
      name: 'beginner',
      desc: '',
      args: [],
    );
  }

  /// `I know a little but I'm eager to learn`
  String get intermediate {
    return Intl.message(
      'I know a little but I\'m eager to learn',
      name: 'intermediate',
      desc: '',
      args: [],
    );
  }

  /// `I know a lot about space expert`
  String get expert {
    return Intl.message(
      'I know a lot about space expert',
      name: 'expert',
      desc: '',
      args: [],
    );
  }

  /// `All Set!`
  String get finishOnboardingTitle {
    return Intl.message(
      'All Set!',
      name: 'finishOnboardingTitle',
      desc: '',
      args: [],
    );
  }

  /// `You can change your preferences anytime in settings.`
  String get finishOnboardingSubtitle {
    return Intl.message(
      'You can change your preferences anytime in settings.',
      name: 'finishOnboardingSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Arabic`
  String get ar {
    return Intl.message('Arabic', name: 'ar', desc: '', args: []);
  }

  /// `English`
  String get en {
    return Intl.message('English', name: 'en', desc: '', args: []);
  }

  /// `Knowledge Level`
  String get knowledgeLevel {
    return Intl.message(
      'Knowledge Level',
      name: 'knowledgeLevel',
      desc: '',
      args: [],
    );
  }

  /// `Start Over`
  String get startOver {
    return Intl.message('Start Over', name: 'startOver', desc: '', args: []);
  }

  /// `Get started`
  String get getStarted {
    return Intl.message('Get started', name: 'getStarted', desc: '', args: []);
  }

  /// `Beginner`
  String get beginnerLevel {
    return Intl.message('Beginner', name: 'beginnerLevel', desc: '', args: []);
  }

  /// `Intermediate`
  String get intermediateLevel {
    return Intl.message(
      'Intermediate',
      name: 'intermediateLevel',
      desc: '',
      args: [],
    );
  }

  /// `Expert`
  String get expertLevel {
    return Intl.message('Expert', name: 'expertLevel', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Welcome Back Bro`
  String get loginSuccessfully {
    return Intl.message(
      'Welcome Back Bro',
      name: 'loginSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Hello Bro, Welcome To Our App`
  String get registerSuccessfully {
    return Intl.message(
      'Hello Bro, Welcome To Our App',
      name: 'registerSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Certificate`
  String get cert {
    return Intl.message('Certificate', name: 'cert', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Sign Out`
  String get signout {
    return Intl.message('Sign Out', name: 'signout', desc: '', args: []);
  }

  /// `Email is not valid`
  String get emailnv {
    return Intl.message(
      'Email is not valid',
      name: 'emailnv',
      desc: '',
      args: [],
    );
  }

  /// `Verify Now`
  String get verify {
    return Intl.message('Verify Now', name: 'verify', desc: '', args: []);
  }

  /// `AstroQuest`
  String get astroquest {
    return Intl.message('AstroQuest', name: 'astroquest', desc: '', args: []);
  }

  /// `Lesson 1: Solar System`
  String get lessonOne {
    return Intl.message(
      'Lesson 1: Solar System',
      name: 'lessonOne',
      desc: '',
      args: [],
    );
  }

  /// `Lesson 2: Earth And Atmosphere`
  String get lessonTwo {
    return Intl.message(
      'Lesson 2: Earth And Atmosphere',
      name: 'lessonTwo',
      desc: '',
      args: [],
    );
  }

  /// `Lesson 3: Sun`
  String get lessonThree {
    return Intl.message(
      'Lesson 3: Sun',
      name: 'lessonThree',
      desc: '',
      args: [],
    );
  }

  /// `Lesson 4: Solar Weather`
  String get lessonFour {
    return Intl.message(
      'Lesson 4: Solar Weather',
      name: 'lessonFour',
      desc: '',
      args: [],
    );
  }

  /// `No description available.`
  String get noLessonDescription {
    return Intl.message(
      'No description available.',
      name: 'noLessonDescription',
      desc: '',
      args: [],
    );
  }

  /// `Go To Video Lesson`
  String get goToLesson {
    return Intl.message(
      'Go To Video Lesson',
      name: 'goToLesson',
      desc: '',
      args: [],
    );
  }

  /// `Take The Test`
  String get takeTest {
    return Intl.message('Take The Test', name: 'takeTest', desc: '', args: []);
  }

  /// `Completed`
  String get completed {
    return Intl.message('Completed', name: 'completed', desc: '', args: []);
  }

  /// `Failed`
  String get failed {
    return Intl.message('Failed', name: 'failed', desc: '', args: []);
  }

  /// `Not Attempted`
  String get notAttempt {
    return Intl.message(
      'Not Attempted',
      name: 'notAttempt',
      desc: '',
      args: [],
    );
  }

  /// `Retake Test`
  String get retakeTest {
    return Intl.message('Retake Test', name: 'retakeTest', desc: '', args: []);
  }

  /// `Explore the wonders of our solar system, including planets, moons, and other celestial bodies.`
  String get lessonOneDesc {
    return Intl.message(
      'Explore the wonders of our solar system, including planets, moons, and other celestial bodies.',
      name: 'lessonOneDesc',
      desc: '',
      args: [],
    );
  }

  /// `Learn about Earth's structure, atmosphere, and the importance of protecting our planet.`
  String get lessonTwoDesc {
    return Intl.message(
      'Learn about Earth\'s structure, atmosphere, and the importance of protecting our planet.',
      name: 'lessonTwoDesc',
      desc: '',
      args: [],
    );
  }

  /// `Understand the Sun's role in our solar system, its structure`
  String get lessonThreeDesc {
    return Intl.message(
      'Understand the Sun\'s role in our solar system, its structure',
      name: 'lessonThreeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Discover the phenomena of solar weather, including solar flares and their impact on Earth.`
  String get lessonFourDesc {
    return Intl.message(
      'Discover the phenomena of solar weather, including solar flares and their impact on Earth.',
      name: 'lessonFourDesc',
      desc: '',
      args: [],
    );
  }

  /// `Score`
  String get score {
    return Intl.message('Score', name: 'score', desc: '', args: []);
  }

  /// `Course Certificate`
  String get courseCert {
    return Intl.message(
      'Course Certificate',
      name: 'courseCert',
      desc: '',
      args: [],
    );
  }

  /// `Save Certificate`
  String get saveCert {
    return Intl.message(
      'Save Certificate',
      name: 'saveCert',
      desc: '',
      args: [],
    );
  }

  /// `No certificate available yet.`
  String get noCert {
    return Intl.message(
      'No certificate available yet.',
      name: 'noCert',
      desc: '',
      args: [],
    );
  }

  /// `Games`
  String get games {
    return Intl.message('Games', name: 'games', desc: '', args: []);
  }

  /// `Report a Bug`
  String get reportBug {
    return Intl.message('Report a Bug', name: 'reportBug', desc: '', args: []);
  }

  /// `Arabic`
  String get arabic {
    return Intl.message('Arabic', name: 'arabic', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `App Version`
  String get appVersion {
    return Intl.message('App Version', name: 'appVersion', desc: '', args: []);
  }

  /// `Made By Team Space Zone`
  String get madeBy {
    return Intl.message(
      'Made By Team Space Zone',
      name: 'madeBy',
      desc: '',
      args: [],
    );
  }

  /// `Complete previous lessons first!`
  String get completeFirstLesson {
    return Intl.message(
      'Complete previous lessons first!',
      name: 'completeFirstLesson',
      desc: '',
      args: [],
    );
  }

  /// `Puzzle Game`
  String get puzzleGame {
    return Intl.message('Puzzle Game', name: 'puzzleGame', desc: '', args: []);
  }

  /// `Puzzle Quest`
  String get puzzleTitle {
    return Intl.message(
      'Puzzle Quest',
      name: 'puzzleTitle',
      desc: '',
      args: [],
    );
  }

  /// `Solve challenging puzzles and unlock new levels.`
  String get puzzleDesc {
    return Intl.message(
      'Solve challenging puzzles and unlock new levels.',
      name: 'puzzleDesc',
      desc: '',
      args: [],
    );
  }

  /// `Space Racing`
  String get spaceRacingTitle {
    return Intl.message(
      'Space Racing',
      name: 'spaceRacingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Race become the champion.`
  String get spaceRacingDesc {
    return Intl.message(
      'Race become the champion.',
      name: 'spaceRacingDesc',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `Moves`
  String get moves {
    return Intl.message('Moves', name: 'moves', desc: '', args: []);
  }

  /// `Congratulations!`
  String get congratulations {
    return Intl.message(
      'Congratulations!',
      name: 'congratulations',
      desc: '',
      args: [],
    );
  }

  /// `Level`
  String get level {
    return Intl.message('Level', name: 'level', desc: '', args: []);
  }

  /// `New Puzzle`
  String get newPuzzle {
    return Intl.message('New Puzzle', name: 'newPuzzle', desc: '', args: []);
  }

  /// `Random Image`
  String get randomImage {
    return Intl.message(
      'Random Image',
      name: 'randomImage',
      desc: '',
      args: [],
    );
  }

  /// `Solve`
  String get solve {
    return Intl.message('Solve', name: 'solve', desc: '', args: []);
  }

  /// `Choose Grid Size`
  String get chooseGridSize {
    return Intl.message(
      'Choose Grid Size',
      name: 'chooseGridSize',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
