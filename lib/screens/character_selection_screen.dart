import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class CharacterSelectionScreen extends StatefulWidget {
  final ValueChanged<String> onContinue;

  const CharacterSelectionScreen({super.key, required this.onContinue});

  @override
  State<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen>
    with TickerProviderStateMixin {
  // Costume options
  static const List<String> costumes = [
    'images/character/cha1/stand.png',
    'images/character/cha2/stand.png',
    'images/character/cha3/stand.png',
    'images/character/cha4/stand.png',
  ];

  int _currentCostumeIndex = 0;
  bool _isTransitioning = false;
  late AnimationController _blinkController;
  late AudioPlayer _sfxPlayer;
  late AudioPlayer _bgmPlayer;

  @override
  void initState() {
    super.initState();
    AudioCache.instance = AudioCache(
      prefix: '',
    ); // Prepare global config for audio
    _sfxPlayer = AudioPlayer();
    _bgmPlayer = AudioPlayer();

    // Play BGM looping
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _bgmPlayer.play(AssetSource('audio/songselection.mp3'));

    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _bgmPlayer.stop();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  void _nextCostume() {
    setState(() {
      _currentCostumeIndex = (_currentCostumeIndex + 1) % costumes.length;
    });
  }

  void _previousCostume() {
    setState(() {
      _currentCostumeIndex =
          (_currentCostumeIndex - 1 + costumes.length) % costumes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKey: (node, event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) ||
            event.isKeyPressed(LogicalKeyboardKey.keyK)) {
          _sfxPlayer.play(AssetSource('audio/KatsuSound.wav'));
          _nextCostume();
          return KeyEventResult.handled;
        }
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) ||
            event.isKeyPressed(LogicalKeyboardKey.keyD)) {
          _sfxPlayer.play(AssetSource('audio/KatsuSound.wav'));
          _previousCostume();
          return KeyEventResult.handled;
        }
        if (!_isTransitioning &&
            (event.isKeyPressed(LogicalKeyboardKey.keyF) ||
                event.isKeyPressed(LogicalKeyboardKey.keyJ))) {
          setState(() {
            _isTransitioning = true;
          });
          // Play drum sound effect
          _bgmPlayer.stop(); // Stop audio before transition
          _sfxPlayer.play(AssetSource('audio/DonSound.wav'));
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) widget.onContinue(costumes[_currentCostumeIndex]);
          });
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      autofocus: true,
      child: Scaffold(
        body: Stack(
          children: [
            // Background cover image (same as start screen)
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/cover.webp'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Dark overlay
            Container(color: Colors.black.withOpacity(0.2)),
            // Main content
            Center(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Character background with costume and arrows
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Character background image with rounded corners
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'images/characterbg.jpg',
                          fit: BoxFit.contain,
                          width: 500,
                          height: 500,
                        ),
                      ),
                      // Left triangle arrow - positioned inside but beside character
                      Positioned(
                        left: 20,
                        child: GestureDetector(
                          onTap: () {
                            _sfxPlayer.play(
                              AssetSource('audio/KatsuSound.wav'),
                            );
                            _previousCostume();
                          },
                          behavior: HitTestBehavior.translucent,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: CustomPaint(
                                painter: TriangleArrowPainter(
                                  direction: TriangleDirection.left,
                                  color: Colors.deepPurple.shade400,
                                ),
                                size: const Size(50, 50),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Costume image - centered
                      Image.asset(
                        costumes[_currentCostumeIndex],
                        fit: BoxFit.contain,
                        width: 350,
                        height: 350,
                      ),
                      // Right triangle arrow - positioned inside but beside character
                      Positioned(
                        right: 20,
                        child: GestureDetector(
                          onTap: () {
                            _sfxPlayer.play(
                              AssetSource('audio/KatsuSound.wav'),
                            );
                            _nextCostume();
                          },
                          behavior: HitTestBehavior.translucent,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: CustomPaint(
                                painter: TriangleArrowPainter(
                                  direction: TriangleDirection.right,
                                  color: Colors.deepPurple.shade400,
                                ),
                                size: const Size(50, 50),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Continue prompt at bottom of characterbg
                      Positioned(
                        bottom: 70,
                        child: GestureDetector(
                          onTap: () {
                            if (!_isTransitioning) {
                              setState(() {
                                _isTransitioning = true;
                              });
                              _sfxPlayer.play(
                                AssetSource('audio/DonSound.wav'),
                              );
                              Future.delayed(const Duration(seconds: 1), () {
                                if (mounted) {
                                  widget.onContinue(
                                    costumes[_currentCostumeIndex],
                                  );
                                }
                              });
                            }
                          },
                          child: FadeTransition(
                            opacity: Tween(begin: 0.5, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _blinkController,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: const Text(
                              'Press F or J to Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum TriangleDirection { left, right }

class TriangleArrowPainter extends CustomPainter {
  final TriangleDirection direction;
  final Color color;

  TriangleArrowPainter({required this.direction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (direction == TriangleDirection.left) {
      // Left-pointing triangle
      path.moveTo(size.width * 0.7, 0);
      path.lineTo(0, size.height / 2);
      path.lineTo(size.width * 0.7, size.height);
      path.close();
    } else {
      // Right-pointing triangle
      path.moveTo(0, 0);
      path.lineTo(size.width * 0.7, size.height / 2);
      path.lineTo(0, size.height);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TriangleArrowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.direction != direction;
  }
}
