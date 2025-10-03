import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nasa_app/screens/auth_screen.dart';
import 'package:nasa_app/screens/main_screen.dart';

class ControlFlowScreen extends StatelessWidget {
  const ControlFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return MainScreen();
        } else {
          return AuthScreen();
        }
      },
    );
  }
}
