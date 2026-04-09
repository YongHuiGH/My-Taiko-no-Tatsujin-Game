import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class StartScreen extends StatefulWidget {
  final VoidCallback onStart;

  const StartScreen({super.key, required this.onStart});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AudioPlayer _sfxPlayer;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    AudioCache.instance = AudioCache(prefix: '');
    _sfxPlayer = AudioPlayer();

    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _sfxPlayer.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKey: (node, event) {
        if (!_isTransitioning &&
            (event.isKeyPressed(LogicalKeyboardKey.keyF) ||
                event.isKeyPressed(LogicalKeyboardKey.keyJ))) {
          setState(() {
            _isTransitioning = true;
          });
          _sfxPlayer.play(AssetSource('audio/DonSound.wav'));
          Future.delayed(const Duration(milliseconds: 300), () {
            AudioPlayer().play(AssetSource('audio/titlescreen.wav'));
          });
          Future.delayed(const Duration(milliseconds: 2500), () {
            if (mounted) widget.onStart();
          });
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      autofocus: true,
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            if (!_isTransitioning) {
              setState(() {
                _isTransitioning = true;
              });
              _sfxPlayer.play(AssetSource('audio/DonSound.wav'));
              Future.delayed(const Duration(milliseconds: 300), () {
                AudioPlayer().play(AssetSource('audio/titlescreen.wav'));
              });
              Future.delayed(const Duration(milliseconds: 2500), () {
                if (mounted) widget.onStart();
              });
            }
          },
          child: Stack(
            children: [
              // Background cover image
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/cover.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Dark overlay for better text visibility
              Container(color: Colors.black.withOpacity(0.3)),
              // Click to start text overlay
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [const SizedBox(height: 100)],
                ),
              ),
              // Bottom blinking text
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: FadeTransition(
                    opacity: Tween(begin: 0.4, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _blinkController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: const Text(
                      'Click F or J to Start',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
