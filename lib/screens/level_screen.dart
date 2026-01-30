import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duolingo/auth/signin_screen.dart';
import 'package:duolingo/screens/screen_one.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  static const Color greenPrimary = Color(0xFF4CAF50);
  static const Color greenAccent = Color(0xFF81C784);
  static const backgroundGradient = LinearGradient(
    colors: [Color(0xFFE8F5E9), Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  int _currentIndex = 0;

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Korean',
  ];

  Future<void> _changeLanguage() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    String? selectedLanguage = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Language'),
          children: _languages.map((lang) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, lang);
              },
              child: Text(lang),
            );
          }).toList(),
        );
      },
    );

    if (selectedLanguage != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'language': selectedLanguage});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Language changed to $selectedLanguage')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final levelsQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('levels')
        .orderBy('levelNumber');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LevelScreen.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 16.0),
                child: Row(
                  children: [
                    const Text(
                      'Language Tutor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: LevelScreen.greenPrimary,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                        icon: const Icon(Icons.settings,
                            color: LevelScreen.greenPrimary),
                        onSelected: (value) async {
                          if (value == 'language') {
                            await _changeLanguage();
                          } else if (value == 'logout') {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignInScreen()),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'language',
                                child: ListTile(
                                  leading: Icon(
                                    Icons.language,
                                    color: LevelScreen.greenPrimary,
                                  ),
                                  title: Text('Change Language'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'logout',
                                child: ListTile(
                                  leading: Icon(
                                    Icons.logout,
                                    color: Colors.redAccent,
                                  ),
                                  title: Text('Logout'),
                                ),
                              ),
                            ])
                  ],
                ),
              ),

              //user streak card language display
              StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final userData = snapshot.data!;
                    final email = userData['email'] ?? 'user';
                    final name = email.split('@')[0];
                    final streak = userData['streak'] ?? 0;
                    final language = userData['language'] ?? 'German';

                    return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 8.0,
                        ),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundImage:
                                AssetImage('assets/images/cool.png'),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, $name',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Learning: $language',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF8A65),
                                  Color(0xFFFF7043),
                                ],
                              ),
                              color: LevelScreen.greenAccent,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 6.0),
                                Text(
                                  '🔥 $streak',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                const Text(
                                  "days",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          )
                        ]));
                  }),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: StreamBuilder(
                      stream: levelsQuery.snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final levels = snapshot.data!.docs;

                        return SingleChildScrollView(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(vertical: 60.0),
                          child: Column(
                            children: levels.asMap().entries.map((entry) {
                              final index = entry.key;
                              final doc = entry.value;

                              final levelNumber =
                                  doc['levelNumber'] ?? index + 1;
                              final title = doc['title'] ?? 'Level';
                              final bool isUnlocked =
                                  doc['isUnlocked'] ?? (levelNumber == 1);
                              final bool isLeft = index % 2 == 0;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 28.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: isLeft
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.end,
                                  children: [
                                    if (!isLeft)
                                      Lottie.asset(
                                        'assets/animation/animation.json',
                                        height: 80,
                                        width: 80,
                                      ),
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: isUnlocked
                                              ? () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ScreenOne(
                                                                levelNumber:
                                                                    levelNumber,
                                                              )));
                                                }
                                              : null,
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 12.0),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: isUnlocked
                                                    ? const LinearGradient(
                                                        colors: [
                                                            LevelScreen
                                                                .greenPrimary,
                                                            LevelScreen
                                                                .greenAccent,
                                                          ])
                                                    : LinearGradient(colors: [
                                                        Colors.grey.shade400,
                                                        Colors.grey.shade600,
                                                      ]),
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 4,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.2),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 6),
                                                  )
                                                ]),
                                            width: 80,
                                            height: 80,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    isUnlocked
                                                        ? Icons.star
                                                        : Icons.lock,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                                  const SizedBox(
                                                    height: 4.0,
                                                  ),
                                                  Text(
                                                    '$levelNumber',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8.0,
                                        ),
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      ],
                                    ),
                                    if (isLeft)
                                      Lottie.asset(
                                        'assets/animation/animation3.json',
                                        height: 80,
                                        width: 80,
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 12,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.grey,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 1) {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => LeaderboardScreen(),
              //   ),
              // );
            } else if (index == 2) {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => ProfileScreen(),
              //   ),
              // );
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: SizedBox(
                width: 24,
                height: 24,
                child: Image.asset('assets/avatars/home.png'),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                width: 24,
                height: 24,
                child: Image.asset('assets/avatars/rank.png'),
              ),
              label: 'Leaderboard',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                width: 24,
                height: 24,
                child: Image.asset('assets/avatars/avatar.png'),
              ),
              label: 'Profile',
            )
          ]),
    );
  }
}
