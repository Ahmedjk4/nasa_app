import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:name_avatar/name_avatar.dart';
import 'package:nasa_app/generated/l10n.dart';
import 'package:nasa_app/providers/language_provider.dart';
import 'package:nasa_app/utils/app_router.dart';
import 'package:nasa_app/utils/firestore_functions.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var user = FirebaseAuth.instance.currentUser;

  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Arabic'];

  @override
  void initState() {
    _selectedLanguage = Intl.getCurrentLocale() == 'ar' ? 'Arabic' : 'English';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).profile,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          final userName = userData?['name'] ?? 'User';

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: NameAvatar(
                  name: userName,
                  radius: 50,
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                userName,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (user?.emailVerified == false)
                Card(
                  color: Colors.yellow[100],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          S.of(context).emailnv,
                          style: TextStyle(color: Colors.orange),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            try {
                              await user?.sendEmailVerification();
                              if (!context.mounted) return;
                              if (user?.emailVerified == false) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Sent Email Verfication Link',
                                    ),
                                  ),
                                );
                              }
                              // 🔑 Force reload user
                              await FirebaseAuth.instance.currentUser?.reload();
                              final refreshedUser =
                                  FirebaseAuth.instance.currentUser;

                              setState(() {
                                user = refreshedUser; // update your state
                              });
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                          child: Text(S.of(context).verify),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(
                  S.of(context).language,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                trailing: DropdownButton<String>(
                  value: _selectedLanguage,
                  items: _languages
                      .map(
                        (lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(
                            lang,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    if (value == 'Arabic') {
                      await context.read<LanguageProvider>().changeLanguage(
                        'ar',
                      );
                      S.load(const Locale('ar'));
                    } else {
                      await context.read<LanguageProvider>().changeLanguage(
                        'en',
                      );
                      S.load(const Locale('en'));
                    }
                    setState(() {
                      _selectedLanguage = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    context.go(AppRouter.authPath);
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(S.of(context).signout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        BetterFeedback.of(context).show((fdback) async {
                          await FirestoreFunctions.createDocument(
                            collection: 'feedbacks',
                            data: {
                              'feedback': fdback.text,
                              'email': user?.email ?? 'Anonymous',
                            },
                          );
                        });
                      },
                      icon: const Icon(Icons.bug_report),
                      label: Text(S.of(context).reportBug),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Text(
                    '${S.of(context).appVersion}: 1.0\n${S.of(context).madeBy}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
