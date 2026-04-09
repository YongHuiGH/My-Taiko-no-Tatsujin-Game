import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int maxCombo;
  final int perfect;
  final int ok;
  final int miss;
  final String songTitle;
  final String selectedCharacter;
  final VoidCallback onContinue;

  const ResultScreen({
    super.key,
    required this.score,
    required this.maxCombo,
    required this.perfect,
    required this.ok,
    required this.miss,
    required this.songTitle,
    required this.selectedCharacter,
    required this.onContinue,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _charAnimController;
  late AudioPlayer _bgmPlayer;
  bool _isStanding = true;

  @override
  void initState() {
    super.initState();

    _bgmPlayer = AudioPlayer();
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _bgmPlayer.play(AssetSource('audio/songselection.mp3'));

    // Setup character animation timer (stands for 500ms, combo for 500ms)
    _charAnimController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 500),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() {
              _isStanding = !_isStanding;
            });
            _charAnimController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            setState(() {
              _isStanding = !_isStanding;
            });
            _charAnimController.forward();
          }
        });
    _charAnimController.forward();
  }

  @override
  void dispose() {
    _bgmPlayer.stop();
    _bgmPlayer.dispose();
    _charAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine character prefix folder
    String charFolder = widget.selectedCharacter;
    int lastSlash = charFolder.lastIndexOf('/');
    if (lastSlash != -1) {
      charFolder = charFolder.substring(0, lastSlash);
    }

    // Choose between stand and combo sprite
    String currentImage = _isStanding
        ? '$charFolder/stand.png'
        : '$charFolder/combo.png';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset('images/songbg.jpg', fit: BoxFit.cover),

          // Result Background Overlap
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner Result BG container
                Image.asset(
                  'images/resultbg.png',
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.contain,
                ),

                // Embedded Score and Info inside resultbg
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SONG CLEARED',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        color: Colors.yellow[300],
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        shadows: const [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black54,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.songTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'SCORE: ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.score}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'MAX COMBO: ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.maxCombo}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // PERFECT, OK, MISS Counts
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatBox(
                              'PERFECT',
                              widget.perfect,
                              Colors.yellowAccent,
                            ),
                            const SizedBox(width: 20),
                            _buildStatBox(
                              'OK',
                              widget.ok,
                              Colors.lightGreenAccent,
                            ),
                            const SizedBox(width: 20),
                            _buildStatBox('MISS', widget.miss, Colors.red),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        elevation: 8,
                      ),
                      onPressed: widget.onContinue,
                      child: const Text(
                        'CONTINUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Dancing Character Bottom Left
          Positioned(
            bottom: 20,
            left: 40,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Image.asset(
              currentImage,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback rendering
                return Image.asset(
                  widget.selectedCharacter,
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, int value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            shadows: const [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black87,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black87,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
