import 'package:flutter/material.dart';
import 'screens/start_screen.dart';
import 'screens/character_selection_screen.dart';
import 'screens/song_selection_screen.dart';
import 'screens/game_screen.dart';
import 'screens/result_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taiko no Tatsujin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Taiko no Tatsujin'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Enum to track current screen
  AppScreen _currentScreen = AppScreen.start;
  String _selectedCharacter = 'images/don1.png'; // default
  String _selectedSong = ''; // store selected song

  int _finalScore = 0;
  int _finalCombo = 0;
  int _finalPerfect = 0;
  int _finalOk = 0;
  int _finalMiss = 0;

  void _goToCharacterSelection() {
    setState(() {
      _currentScreen = AppScreen.characterSelection;
    });
  }

  void _goToSongSelection(String characterPath) {
    setState(() {
      _selectedCharacter = characterPath;
      _currentScreen = AppScreen.songSelection;
    });
  }

  void _backToCharacterSelection() {
    setState(() {
      _currentScreen = AppScreen.characterSelection;
    });
  }

  void _goToGame(String songTitle) {
    if (songTitle.isNotEmpty) {
      setState(() {
        _selectedSong = songTitle;
        _currentScreen = AppScreen.game;
      });
    }
  }

  void _finishGame(int score, int maxCombo, int perfect, int ok, int miss) {
    setState(() {
      _finalScore = score;
      _finalCombo = maxCombo;
      _finalPerfect = perfect;
      _finalOk = ok;
      _finalMiss = miss;
      _currentScreen = AppScreen.result;
    });
  }

  void _backToSongSelectionFromResult() {
    setState(() {
      _currentScreen = AppScreen.songSelection;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentScreen) {
      case AppScreen.start:
        return StartScreen(onStart: _goToCharacterSelection);
      case AppScreen.characterSelection:
        return CharacterSelectionScreen(onContinue: _goToSongSelection);
      case AppScreen.songSelection:
        return SongSelectionScreen(
          selectedCharacter: _selectedCharacter,
          onSongSelected: _goToGame,
          onBack: _backToCharacterSelection,
        );
      case AppScreen.game:
        return GameScreen(
          selectedCharacter: _selectedCharacter,
          songTitle: _selectedSong,
          onFinished: _finishGame,
        );
      case AppScreen.result:
        return ResultScreen(
          score: _finalScore,
          maxCombo: _finalCombo,
          perfect: _finalPerfect,
          ok: _finalOk,
          miss: _finalMiss,
          songTitle: _selectedSong,
          selectedCharacter: _selectedCharacter,
          onContinue: _backToSongSelectionFromResult,
        );
    }
  }
}

enum AppScreen { start, characterSelection, songSelection, game, result }
