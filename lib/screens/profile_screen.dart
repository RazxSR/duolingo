import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duolingo/screens/congratulation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';


class ProfileScreen extends StatelessWidget {
const ProfileScreen({super.key});


static const Color greenPrimary = Color(0xFF4CAF50);
  static const Color greenAccent = Color(0xFF81c784);
  static const  backgroundGradient = LinearGradient(
    colors: [Color(0xFFE8F5E9), Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  final List<String> avatars = const [
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
    'assets/avatars/avatar5.png',
  ];

  String getAvatarForUser(String uid) {
    final index = uid.hashCode % avatars.length;
    return avatars[index];
  }


  @override
  Widget build(BuildContext context){
    final user = FirebaseAuth.instance.currentUser;
    final userId = user!.uid;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: backgroundGradient,
        ),
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: userDoc.snapshots(),
            builder: (context,  snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(),);
              }

              final userData = snapshot.data!;
              final email = userData['email'] ?? 'Unknown';
              final name = email.split('@')[0];
              final xp = userData['xp'] ?? 0;
              final streak = userData['streak'] ?? 0;
              final avatar = getAvatarForUser(userId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                      icon: const Icon(Icons.arrow_back, color: greenPrimary,),
                        onPressed: () => Navigator.pop(context),
                         ),
                         const Spacer(),
                          const Text(
                            'Your Profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: greenPrimary,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(avatar),
                  ),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(avatar),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: greenPrimary,
                    ),
                  ),
                  Text(
                    email,
                    style:  TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const Text(
                    "Your Stats",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: greenPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [ greenPrimary, greenAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 30,),
                            const SizedBox(height: 4),
                            Text(
                              '$xp XP',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.orange, size: 30,),
                            const SizedBox(height: 4),
                            Text(
                              '$streak',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height:40 ,),
                ],
              );
            }
          )
        ),
      ),
    );
  }
}