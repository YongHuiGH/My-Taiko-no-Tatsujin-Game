import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import 'dart:async';
import 'dart:math';

class NoteInfo {
  final double hitTime; // Exact audio position (seconds) to hit center
  double xPosition; // 1.0 is far right, 0.0 is hit zone, negative is off-screen
  final String color; // 'red' or 'blue'
  bool isMissed; // Tracks if combo was already reset for this note

  NoteInfo({
    required this.hitTime,
    required this.xPosition,
    required this.color,
    this.isMissed = false,
  });
}

class GameScreen extends StatefulWidget {
  final String songTitle;
  final String selectedCharacter;
  final void Function(int score, int maxCombo, int perfect, int ok, int miss)
  onFinished;

  const GameScreen({
    super.key,
    required this.songTitle,
    required this.selectedCharacter,
    required this.onFinished,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _sfxPlayer;
  late AudioPlayer _comboPlayer;
  late AudioPlayer _bgmPlayer;

  // Game logic variables
  late AnimationController _gameLoopController;
  final List<NoteInfo> _notes = [];
  Timer? _spawnerTimer;
  Timer? _charAnimTimer;
  StreamSubscription? _positionSubscription;
  final Random _random = Random();
  double _noteSpeed =
      0.40; // How much xPosition decreases per second. (0.35 is slightly slower than 0.5)

  bool _isCharacterStanding = true;
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;

  int _perfectCount = 0;
  int _okCount = 0;
  int _missCount = 0;

  bool _isEnding = false;

  double _audioSeconds = 0.0;
  DateTime _lastUpdateTime = DateTime.now();

  String _hitFeedback = '';
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    AudioCache.instance = AudioCache(
      prefix: '',
    ); // Prepare global config for audio
    _sfxPlayer = AudioPlayer();
    _comboPlayer = AudioPlayer();
    _bgmPlayer = AudioPlayer();

    // Setup dummy beatmap
    _loadBeatmap();

    // Subscribe to audio player position for perfect sync
    _positionSubscription = _bgmPlayer.onPositionChanged.listen((p) {
      _audioSeconds = p.inMilliseconds / 1000.0;
      _lastUpdateTime = DateTime.now(); // Sync elapsed delta
    });

    // Start background music
    if (widget.songTitle == 'DDU-DU DDU-DU') {
      _bgmPlayer.play(AssetSource('audio/blackpink.mp3'));
    } else if (widget.songTitle == 'CANON') {
      _bgmPlayer.play(AssetSource('audio/canon.mp3'));
    } else if (widget.songTitle == 'Can Can') {
      _bgmPlayer.play(AssetSource('audio/cancan.mp3'));
    } else if (widget.songTitle == 'Golden') {
      _bgmPlayer.play(AssetSource('audio/golden.mp3'));
    } else if (widget.songTitle == 'Woke Up') {
      _bgmPlayer.play(AssetSource('audio/wokeup.mp3'));
    } else if (widget.songTitle == 'Sun and Earth') {
      _bgmPlayer.play(AssetSource('audio/sunnearth.mp3'));
    } else if (widget.songTitle == '夜に駆ける') {
      _bgmPlayer.play(AssetSource('audio/yoasobi.mp3'));
    } else if (widget.songTitle == 'APT') {
      _bgmPlayer.play(AssetSource('audio/apt.mp3'));
    }

    // Setup game loop (fires every hardware frame)
    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _gameLoopController.addListener(_updateGameLoop);
    _gameLoopController.repeat();

    // Setup character animation timer
    _charAnimTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _isCharacterStanding = !_isCharacterStanding;
        });
      }
    });
  }

  void _loadBeatmap() {
    List<double> hitTimes = [];

    if (widget.songTitle == 'APT') {
      hitTimes = [
        7,
        7.4,
        7.5,
        8,
        8.1,
        8.6,
        8.9,
        9.1,
        9.5,
        9.7,
        10.1,
        10.6,
        10.8,
        11.1,
        11.4,
        11.8,
        12.2,
        12.3,
        12.7,
        13,
        13.4,
        13.8,
        14,
        14.4,
        14.5,
        14.6,
        15,
        15.4,
        15.6,
        16,
        16.2,
        16.6,
        17,
        17.2,
        17.8,
        18.2,
        18.6,
        18.8,
        19.2,
        19.4,
        19.8,
        20.2,
        20.4,
        20.8,
        20.9,
        21,
        21.4,
        21.8,
        22,
        22.4,
        22.6,
        23,
        23.4,
        23.6,
        24,
        24.2,
        24.6,
        25,
        25.3,
        25.7,
        25.9,
        26.9,
        27.3,
        27.5,
        27.9,
        28,
        28.4,
        28.5,
        28.8,
        28.9,
        29.1,
        29.5,
        29.9,
        30.1,
        30.5,
        30.6,
        30.7,
        31.1,
        31.2,
        31.5,
        31.7,
        31.9,
        32.1,
        32.3,
        32.5,
        32.7,
        33.1,
        33.4,
        33.6,
        33.7,
        33.8,
        34.3,
        34.4,
        34.7,
        35.9,
        36.3,
        36.6,
        37.1,
        37.2,
        37.5,
        37.6,
        37.9,
        38.2,
        38.6,
        38.8,
        39.1,
        39.5,
        39.8,
        40.2,
        40.3,
        40.5,
        40.7,
        40.8,
        41.1,
        41.4,
        41.8,
        42.3,
        42.4,
        43.4,
        43.6,
        43.7,
        45.6,
        45.7,
        46,
        46.2,
        46.6,
        46.8,
        47.2,
        47.3,
        47.6,
        47.8,
        48.2,
        48.4,
        48.5,
        48.8,
        48.9,
        49.2,
        49.4,
        49.8,
        50,
        50.4,
        50.5,
        50.8,
        51,
        51.4,
        51.6,
        52.1,
        52.4,
        52.6,
        53,
        53.2,
        53.7,
        54,
        54.3,
        54.7,
        54.8,
        55.3,
        55.6,
        55.9,
        56.3,
        56.4,
        56.8,
        56.9,
        57.2,
        57.3,
        57.5,
        57.9,
        58,
        58.4,
        58.5,
      ];
    } else if (widget.songTitle == 'Golden') {
      // Procedural Beatmap Generation for Golden
      double bpm = 124.0; // Average between 120-126
      double beatDuration = 60.0 / bpm;
      double currentTime = 3.0; // Start offset to skip intro silence

      // Repeating rhythm pattern expressed in fractions of a beat
      // 1.0 = quarter note (on beat)
      // 0.5 = eighth note (half beat)
      // 0.333 = triplet feel
      List<double> rhythmPattern = [
        1.0, 1.0, 0.5, 0.5, 1.0, // Standard groove
        0.5, 0.5, 1.0, 1.0, 1.0, // Offbeat variations
        0.333, 0.333, 0.334, // Triplet roll
        1.0, 0.5, 0.5, 1.0, // Filler
      ];

      int patternIndex = 0;
      while (currentTime < 58.0) {
        // Generate notes until the 58th second
        hitTimes.add(currentTime);
        currentTime += beatDuration * rhythmPattern[patternIndex];
        patternIndex = (patternIndex + 1) % rhythmPattern.length;
      }
    } else if (widget.songTitle == 'Can Can') {
      // Procedural Beatmap Generation for Can Can
      double bpm = 167.0;
      double beatDuration = 60.0 / bpm;
      double currentTime = 2.0; // Start offset

      // Fast-paced 2/4 march/polka feel based on the sheet music
      // Features offbeat eighth notes, driving quarter notes, and fast consecutive eighths
      List<double> rhythmPattern = [
        0.5, 0.5, 1.0, // Two eighths, one quarter
        0.5, 0.5, 0.5, 0.5, // Four eighths (gallop)
        1.0, 1.0, // Two quarters (stomp)
        0.5, 0.5, 1.0, // Syncopation feel
        0.5, 0.5, 0.5, 0.5, // Driving eighths
        0.5, 0.5, 1.0, // Wrap up measure
      ];

      int patternIndex = 0;
      while (currentTime < 58.0) {
        // Generate notes until the 58th second
        hitTimes.add(currentTime);
        currentTime += beatDuration * rhythmPattern[patternIndex];
        patternIndex = (patternIndex + 1) % rhythmPattern.length;
      }
    } else if (widget.songTitle == 'CANON') {
      // Procedural Beatmap Generation for CANON
      double bpm = 100.0;
      double beatDuration = 60.0 / bpm;
      double currentTime = 2.0; // Start offset

      // Canon in D right hand melody progression
      // 2.0 = half note, 1.0 = quarter note, 0.5 = eighth note
      List<double> rhythmPattern = [
        2.0, 2.0, // Slow majestic start (half notes)
        2.0, 2.0, // Slow majestic start (half notes)
        1.0, 1.0, 1.0, 1.0, // Picking up with quarter notes
        1.0, 1.0, 1.0, 1.0, // Picking up with quarter notes
        0.5, 0.5, 1.0, 0.5, 0.5, 1.0, // Mix of eighths and quarters
        0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0, // Ending flourish
      ];

      int patternIndex = 0;
      while (currentTime < 58.0) {
        // Generate notes until the 58th second
        hitTimes.add(currentTime);
        currentTime += beatDuration * rhythmPattern[patternIndex];
        patternIndex = (patternIndex + 1) % rhythmPattern.length;
      }
    } else if (widget.songTitle == 'DDU-DU DDU-DU') {
      // Procedural Beatmap Generation for DDU-DU DDU-DU
      double bpm = 140.0;
      double beatDuration = 60.0 / bpm;
      double currentTime = 2.0; // Start offset

      // High-energy 140 BPM pop rhythm, with sharp eighth and dotted eighth syncopation
      // 1.0 = quarter note, 0.5 = eighth note, 0.25 = sixteenth note, 0.75 = dotted eighth
      List<double> rhythmPattern = [
        0.5, 0.5, 1.0, // Eighth, eighth, quarter (punchy setup)
        0.75, 0.25, 0.5, 0.5, // Dotted eighth, sixteenth syncopated hook
        1.0, 1.0, // Driving quarters
        0.25, 0.25, 0.5, 1.0, // Quick sixteenths burst resolving to quarter
        0.5, 0.5, 0.5, 0.5, // Steady eighth notes running loop
      ];

      int patternIndex = 0;
      while (currentTime < 58.0) {
        hitTimes.add(currentTime);
        currentTime += beatDuration * rhythmPattern[patternIndex];
        patternIndex = (patternIndex + 1) % rhythmPattern.length;
      }
    } else if (widget.songTitle == '夜に駆ける') {
      // Procedural Beatmap Generation for YOASOBI (夜に駆ける)
      double bpm = 132.0;
      double beatDuration = 60.0 / bpm;
      double currentTime = 2.0; // Start offset

      // Fast, intricate J-pop piano rock rhythm at 132 BPM
      // Packed with continuous 8th notes, syncopated 16th pickups, and tied notes
      List<double> rhythmPattern = [
        0.5,
        0.5,
        0.5,
        0.5,
        1.0, // Bouncing 8th notes resolving on a strong quarter
        0.25,
        0.25,
        0.5,
        0.5,
        0.5,
        1.0, // Quick 16th-note trills flowing into upbeat
        0.5,
        1.0,
        0.5,
        1.0,
        1.0, // Highly syncopated tied-note feel (similar to measure 5)
        0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.5, // Very busy measure end
      ];

      int patternIndex = 0;
      while (currentTime < 58.0) {
        hitTimes.add(currentTime);
        currentTime += beatDuration * rhythmPattern[patternIndex];
        patternIndex = (patternIndex + 1) % rhythmPattern.length;
      }
    } else if (widget.songTitle == 'Sun and Earth') {
      hitTimes = [
        1.0,
        2.0,
        2.5,
        5.0,
        6.0,
        6.5,
        9.0,
        10.0,
        10.5,
        14.0,
        17.0,
        19.0,
        19.5,
        19.8,
        20.0,
        20.3,
        24.0,
        24.5,
        24.8,
        26.0,
        26.3,
        26.5,
        27.5,
        28.5,
        30.0,
        30.5,
        31.0,
        31.5,
        32.0,
        34.0,
        34.5,
        35.0,
        36.0,
        36.5,
        37.5,
        39.5,
        41.0,
        41.5,
        42.0,
        42.5,
        43.0,
        44.0,
        45.0,
        46.0,
        46.25,
        46.5,
        46.75,
        47.0,
        47.5,
        47.8,
        48.0,
        48.5,
        49.0,
        49.25,
        49.5,
        49.75,
        50.0,
        50.5,
        50.8,
        51.5,
        51.8,
        52.5,
        53.0,
        53.5,
        53.75,
        54.3,
        55.0,
        55.5,
        55.8,
        56.0,
        56.5,
        58.0,
        59.0,
      ];
    } else if (widget.songTitle == 'Woke Up') {
      // Procedural Beatmap Generation for Woke Up by XG
      double bpm = 146.0;
      double beatDuration = 60.0 / bpm;
      double currentTime = 1.0; // Start offset

      // Fast 146 BPM English rap/K-pop track
      // Characterized by aggressive trap hi-hats, heavy sub-bass on the 1,
      // and fast vocal triplets common in XG's rap lines.
      List<double> rhythmPattern = [
        1.0, 0.5, 0.5, // Solid kick on beat, two 8th note hi-hats
        0.25, 0.25, 0.5, 1.0, // Trap snare stutter into clear hit
        1.0, 1.0, // Two heavy beat drops
        0.333,
        0.333,
        0.334,
        1.0, // Aggressive rap vocal triplet followed by rest
        0.5, 0.25, 0.25, 0.5, 0.5, // Busy syncopated 16th note filler
      ];

      int patternIndex = 0;
      while (currentTime < 58.0) {
        hitTimes.add(currentTime);
        currentTime += beatDuration * rhythmPattern[patternIndex];
        patternIndex = (patternIndex + 1) % rhythmPattern.length;
      }
    } else {
      // Default fallback
      hitTimes = [
        2.0,
        2.5,
        3.0,
        3.5,
        4.0,
        4.5,
        5.0,
        5.25,
        5.5,
        6.0,
        6.5,
        7.0,
        8.0,
        8.5,
        9.0,
        9.25,
        9.5,
        10.0,
        11.0,
        11.5,
        12.0,
      ];
    }

    setState(() {
      for (double time in hitTimes) {
        _notes.add(
          NoteInfo(
            hitTime: time,
            xPosition: 1.0, // Initially arbitrary, dynamically computed in loop
            color: _random.nextBool() ? 'red' : 'blue',
          ),
        );
      }
    });
  }

  void _endSequence() async {
    _gameLoopController.removeListener(_updateGameLoop);
    _gameLoopController.stop();

    // Play clear sound without blocking the fade-out, ignore error if missing
    try {
      _sfxPlayer.play(AssetSource('audio/clear.wav'));
    } catch (e) {
      debugPrint('clear.wav missing or failed to play: $e');
    }

    // Fade out volume
    int steps = 20;
    int msPerStep = 100; // 2 seconds fade out
    double currentVolume = 1.0;
    double volumeStep = currentVolume / steps;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(Duration(milliseconds: msPerStep));
      currentVolume -= volumeStep;
      if (currentVolume < 0) currentVolume = 0;
      try {
        await _bgmPlayer.setVolume(currentVolume);
      } catch (e) {
        // Ignore if disposed during fade
      }
    }

    await Future.delayed(
      const Duration(seconds: 3),
    ); // Let clear.wav finish playing

    await _bgmPlayer.stop();

    if (!mounted) return;

    widget.onFinished(_score, _maxCombo, _perfectCount, _okCount, _missCount);
  }

  void _updateGameLoop() {
    // Update audio seconds smoothly between stream updates
    DateTime now = DateTime.now();
    double dt = now.difference(_lastUpdateTime).inMilliseconds / 1000.0;
    _lastUpdateTime = now;

    // Only increment internal clock if audio has actually started ticking natively
    if (_audioSeconds > 0) {
      _audioSeconds += dt;
    }

    if (_audioSeconds >= 60.0 && !_isEnding) {
      _isEnding = true;
      _endSequence();
    }

    double hitCenter = 0.25;
    double hitTolerance = 0.08;

    setState(() {
      for (int i = _notes.length - 1; i >= 0; i--) {
        NoteInfo note = _notes[i];

        // Core of Beatmapping logic:
        // Position relies STRICTLY on time distance from the Hit Target.
        double timeUntilHit = note.hitTime - _audioSeconds;
        note.xPosition = hitCenter + (timeUntilHit * _noteSpeed);

        // If note passes the hit zone entirely, it's a miss
        if (!note.isMissed && note.xPosition < (hitCenter - hitTolerance)) {
          note.isMissed = true;
          _missCount++;
        }

        // Remove if way off-screen to save rendering memory
        if (note.xPosition < -0.2) {
          _notes.removeAt(i);
        }
      }
    });
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _positionSubscription?.cancel();
    _charAnimTimer?.cancel();
    _spawnerTimer?.cancel();
    _gameLoopController.dispose();
    _bgmPlayer.stop();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    _comboPlayer.dispose();
    super.dispose();
  }

  void _handleInput(String color) {
    // Play sound based on note mapped key
    if (color == 'red') {
      _sfxPlayer.play(AssetSource('audio/DonSound.wav'));
    } else {
      _sfxPlayer.play(AssetSource('audio/KatsuSound.wav'));
    }

    // Hit zone definition
    double hitCenter = 0.25; // Roughly where the drum graphic is
    double hitTolerance = 0.08; // Allow hit within 0.17 to 0.33 xPosition
    double perfectTolerance = 0.03; // Inner window for Perfect hit

    setState(() {
      for (int i = 0; i < _notes.length; i++) {
        // Skip already missed notes
        if (_notes[i].isMissed) continue;

        double distance = (_notes[i].xPosition - hitCenter).abs();

        // Check if note is within the hit tolerance window
        if (distance <= hitTolerance) {
          // If the note matches the expected color, hit succeeds!
          if (_notes[i].color == color) {
            if (distance <= perfectTolerance) {
              _score += 200; // Perfect hit
              _perfectCount++;
              _hitFeedback = 'PERFECT';
            } else {
              _score += 100; // Normal hit
              _okCount++;
              _hitFeedback = 'OK';
            }
            _combo++;
            if (_combo > _maxCombo) {
              _maxCombo = _combo;
            }
            if (_combo == 50) {
              _comboPlayer.play(AssetSource('audio/50combo.wav'));
            } else if (_combo == 100) {
              _comboPlayer.play(AssetSource('audio/100combo.wav'));
            }
            _notes.removeAt(i);
            _feedbackTimer?.cancel();
            _feedbackTimer = Timer(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _hitFeedback = '';
                });
              }
            });
            break; // Stop after successfully hitting one note
          }
          // Wrong key press could break combo, but traditionally Taiko lets it pass or registers as BAD.
          // Let's just ignore wrong colors here so user can wait for the correct color.
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.keyF ||
              event.logicalKey == LogicalKeyboardKey.keyJ) {
            _handleInput('red');
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.keyD ||
              event.logicalKey == LogicalKeyboardKey.keyK) {
            _handleInput('blue');
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      autofocus: true,
      child: Scaffold(
        backgroundColor: Colors.black, // Fill letterbox areas with black
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate track boundaries to match the middle gamemiddle.png section
            final trackTop =
                constraints.maxHeight * 0.28; // Starts slightly higher
            final trackHeight =
                constraints.maxHeight * 0.20; // Takes 20% of the screen height

            return Stack(
              children: [
                // Top Screen Background
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height:
                      constraints.maxHeight *
                      0.40, // 40% height for the top part
                  child: Image.asset(
                    'images/game/gametop.png',
                    fit: BoxFit.fill,
                  ),
                ),
                // Middle Drum Roll Background
                Positioned(
                  top: trackTop,
                  left: 0,
                  right: 0,
                  height: trackHeight, // 20% height for the drum roll
                  child: Image.asset(
                    'images/game/gamemiddle.png',
                    fit: BoxFit.fill,
                  ),
                ),
                // Bottom Screen Background
                Positioned(
                  top: constraints.maxHeight * 0.48,
                  left: 0,
                  right: 0,
                  bottom: 0, // Remaining 40% for the bottom
                  child: Image.asset(
                    'images/game/gamebottom.png',
                    fit: BoxFit.fill,
                  ),
                ),
                // Render the notes inside the track
                Positioned(
                  top: trackTop,
                  height: trackHeight,
                  left:
                      constraints.maxWidth *
                      0.26, // Hide notes that slide past the drum left bound
                  right: 0,
                  child: ClipRect(
                    child: Stack(
                      children: [
                        // The Notes
                        ..._notes
                            .where(
                              (note) =>
                                  note.xPosition > -0.2 && note.xPosition < 1.2,
                            )
                            .map((note) {
                              // Offset the rendering left by the 22% track margin
                              double leftPosition =
                                  (note.xPosition * constraints.maxWidth) -
                                  (constraints.maxWidth * 0.22);

                              return Positioned(
                                left:
                                    leftPosition, // 1.0 = right edge, 0.0 = left edge logically
                                top: 0,
                                bottom: 0,
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Image.asset(
                                    'images/${note.color}.png',
                                    fit: BoxFit
                                        .contain, // Maintain note aspect ratio
                                  ),
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                ),
                // Hit Feedback (PERFECT / OK)
                if (_hitFeedback.isNotEmpty)
                  Positioned(
                    top:
                        constraints.maxHeight *
                        0.2, // Show roughly above the hit area
                    left: constraints.maxWidth * 0.25 - 50,
                    child: AnimatedOpacity(
                      opacity: _hitFeedback.isNotEmpty ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Stack(
                        children: [
                          Text(
                            _hitFeedback,
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 8
                                ..color = Colors.black,
                            ),
                          ),
                          Text(
                            _hitFeedback,
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: _hitFeedback == 'PERFECT'
                                  ? Colors.yellowAccent
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Character Animation
                Positioned(
                  top: -20, // Slightly higher as requested
                  left: 25, // Left adjusted (was 100)
                  height:
                      constraints.maxHeight *
                      0.35, // Scale nicely within the top area
                  child: () {
                    // Determine character folder
                    String charFolder = widget.selectedCharacter;
                    int lastSlash = charFolder.lastIndexOf('/');
                    if (lastSlash != -1) {
                      charFolder = charFolder.substring(0, lastSlash);
                    }

                    String currentImage = _isCharacterStanding
                        ? '$charFolder/stand.png'
                        : '$charFolder/down.png';

                    return Image.asset(
                      currentImage,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          widget.selectedCharacter,
                          fit: BoxFit.contain,
                        );
                      },
                    );
                  }(),
                ),
                // Song Title Text Top Right
                Positioned(
                  top: 50,
                  right: 40,
                  child: Stack(
                    children: [
                      Text(
                        widget.songTitle,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 8
                            ..color = Colors.black,
                        ),
                      ),
                      Text(
                        widget.songTitle,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Inner text white
                        ),
                      ),
                    ],
                  ),
                ),
                // Score Middle Center
                Positioned(
                  top: constraints.maxHeight * 0.6 + 15,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Text(
                          'Score: $_score',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 6
                              ..color = Colors.black,
                          ),
                        ),
                        Text(
                          'Score: $_score',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Combo Center below Score
                Positioned(
                  top: constraints.maxHeight * 0.55,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Text(
                          'Combo: $_combo',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 7
                              ..color = Colors.black,
                          ),
                        ),
                        Text(
                          'Combo: $_combo',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
