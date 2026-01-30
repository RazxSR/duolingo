import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';



class ScreenFour extends StatefulWidget {
  final int levelNumber;
  const ScreenFour({super.key, required this.levelNumber});

  @override
  _ScreenFourState createState() => _ScreenFourState();
}

class _ScreenFourState extends State<ScreenFour> {
  final AudioPlayer player = AudioPlayer();
  final FlutterTts flutterTts = FlutterTts();
  late OnDeviceTranslator translator;

  static const Color greenPrimary = Color(0xFF58CC02);

  String subtitle = '';
  String questionEn = '';
  String questionTranslated = '';
  String answerEn = '';
  String answerTranslated = '';
  List<Map<String, String>> options = [];

  String selectedOption = '';
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void>_setup() async {
    await _initTranslator();
    await _initializeTts();
    await _fetchTask();
  }

    Future<void> _initTranslator() async{
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    
    final userLang = userDoc['language'] ?? 'German';
    final targetLang = _mapLanguageToEnum(userLang);

    translator = OnDeviceTranslator(sourceLanguage: TranslateLanguage.english, targetLanguage: targetLang) ;
    }

    TranslateLanguage _mapLanguageToEnum(String lang){
    switch (lang.toLowerCase()) {
      case 'german':
        return TranslateLanguage.german;
      case 'spanish':
        return TranslateLanguage.spanish;
      case 'french':
        return TranslateLanguage.french;
      case 'italian':
        return TranslateLanguage.italian;
      case 'korean':
        return TranslateLanguage.korean;
      default:
      return TranslateLanguage.german;

    }
    }

    Future<void> _initializeTts() async{
      final ttsLang = _getTtsCode(translator.targetLanguage);
      await flutterTts.setLanguage(ttsLang);
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setPitch(0.1);
    }

    String _getTtsCode(TranslateLanguage lang){
      switch(lang){
        case TranslateLanguage.spanish:
          return 'es';
        case TranslateLanguage.french:
          return 'fr';
        case TranslateLanguage.italian:
          return 'it';  
        case TranslateLanguage.korean:
          return 'ko';
        default:
          return 'de';          
      }
    }

    @override
    void dispose(){
      super.dispose();
      player.dispose();
      flutterTts.stop();
      translator.close();
    }

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}