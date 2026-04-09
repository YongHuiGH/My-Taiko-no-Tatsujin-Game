import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import 'dart:async';

class SongData {
  final String title;
  final String subtitle;
  final Color color;

  SongData({required this.title, required this.subtitle, required this.color});
}

class SongSelectionScreen extends StatefulWidget {
  final String selectedCharacter;
  final ValueChanged<String> onSongSelected;
  final VoidCallback onBack;

  const SongSelectionScreen({
    super.key,
    required this.selectedCharacter,
    required this.onSongSelected,
    required this.onBack,
  });

  @override
  State<SongSelectionScreen> createState() => _SongSelectionScreenState();
}

class _SongSelectionScreenState extends State<SongSelectionScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _bgScrollController;
  late AnimationController _donAnimationController;

  final List<SongData> songs = [
    SongData(
      title: 'CANON',
      subtitle: 'Classical',
      color: const Color(0xFFB0D9FF),
    ),
    SongData(
      title: 'DDU-DU DDU-DU',
      subtitle: 'kpop',
      color: Colors.pink.shade100,
    ),
    SongData(
      title: 'Can Can',
      subtitle: 'Classical',
      color: const Color(0xFFFFB0B0),
    ),
    SongData(title: 'Golden', subtitle: 'Pop', color: const Color(0xFFFFE0B2)),
    SongData(
      title: 'Woke Up',
      subtitle: 'Hip Hop',
      color: const Color(0xFFC8E6C9),
    ),
    SongData(
      title: 'Sun and Earth',
      subtitle: 'Pop',
      color: const Color(0xFFFFF9C4),
    ),
    SongData(title: '夜に駆ける', subtitle: 'J-Pop', color: const Color(0xFFE1BEE7)),
    SongData(title: 'APT', subtitle: 'Pop', color: const Color(0xFFFFCC80)),
    SongData(title: '', subtitle: '', color: Colors.transparent),
    SongData(title: '', subtitle: '', color: Colors.transparent),
    SongData(title: '', subtitle: '', color: Colors.transparent),
    SongData(title: '', subtitle: '', color: Colors.transparent),
  ];

  int _selectedSongIndex = 0; // Start directly at index 0

  bool _isFirstBuild = true;
  bool _isTransitioning = false;
  final double _itemWidth = 126.0; // 110 width + 16 (8 horizontal padding)

  bool _showLeftIdle = true;
  Timer? _idleTimer;

  late AudioPlayer _bgmPlayer;
  late AudioPlayer _sfxPlayer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _bgScrollController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _donAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _idleTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _showLeftIdle = !_showLeftIdle;
        });
      }
    });

    // Setup Audio
    AudioCache.instance = AudioCache(
      prefix: '',
    ); // Prevent default 'assets/' prefix if audio is at root
    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();

    // Play BGM looping
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _playSongPreview();
  }

  void _playSongPreview() {
    String title = songs[_selectedSongIndex].title;
    String file = 'songselection.mp3'; // default fallback

    switch (title) {
      case 'DDU-DU DDU-DU':
        file = 'blackpink.mp3';
        break;
      case 'CANON':
        file = 'canon.mp3';
        break;
      case 'Can Can':
        file = 'cancan.mp3';
        break;
      case 'Golden':
        file = 'golden.mp3';
        break;
      case 'Woke Up':
        file = 'wokeup.mp3';
        break;
      case 'Sun and Earth':
        file = 'sunnearth.mp3';
        break;
      case '夜に駆ける':
        file = 'yoasobi.mp3';
        break;
      case 'APT':
        file = 'apt.mp3';
        break;
    }
    _bgmPlayer.play(AssetSource('audio/$file'));
  }

  void _scrollToSelected() {
    final screenWidth = MediaQuery.of(context).size.width;
    final centerOffset = screenWidth / 2 - (_itemWidth / 2);
    final targetOffset = (_selectedSongIndex * _itemWidth) - centerOffset;

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _bgmPlayer.stop();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();

    _scrollController.dispose();
    _bgScrollController.dispose();
    _donAnimationController.dispose();
    super.dispose();
  }

  void _nextSong() {
    setState(() {
      int nextIndex = _selectedSongIndex;
      do {
        if (nextIndex < songs.length - 1) {
          nextIndex++;
        } else {
          nextIndex = 0;
        }
      } while (songs[nextIndex].title.isEmpty &&
          nextIndex != _selectedSongIndex);
      _selectedSongIndex = nextIndex;
    });
    _scrollToSelected();
    _playSongPreview();
  }

  void _previousSong() {
    setState(() {
      int prevIndex = _selectedSongIndex;
      do {
        if (prevIndex > 0) {
          prevIndex--;
        } else {
          prevIndex = songs.length - 1;
        }
      } while (songs[prevIndex].title.isEmpty &&
          prevIndex != _selectedSongIndex);
      _selectedSongIndex = prevIndex;
    });
    _scrollToSelected();
    _playSongPreview();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstBuild) {
      _isFirstBuild = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final screenWidth = MediaQuery.of(context).size.width;
          final centerOffset = screenWidth / 2 - (_itemWidth / 2);
          _scrollController.jumpTo(
            (_selectedSongIndex * _itemWidth) - centerOffset,
          );
        }
      });
    }

    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
              event.logicalKey == LogicalKeyboardKey.keyK) {
            _sfxPlayer.play(AssetSource('audio/KatsuSound.wav'));
            _nextSong();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
              event.logicalKey == LogicalKeyboardKey.keyD) {
            _sfxPlayer.play(AssetSource('audio/KatsuSound.wav'));
            _previousSong();
            return KeyEventResult.handled;
          }
          if (!_isTransitioning &&
              (event.logicalKey == LogicalKeyboardKey.keyF ||
                  event.logicalKey == LogicalKeyboardKey.keyJ)) {
            setState(() {
              _isTransitioning = true;
            });
            // Stop preview BGM and play begin sequence
            _bgmPlayer.stop();
            _sfxPlayer.play(AssetSource('audio/begin.wav'));

            // Assuming begin.wav is around 1-3 seconds, safer to navigate when audio completes
            StreamSubscription? completionSub;
            completionSub = _sfxPlayer.onPlayerComplete.listen((_) {
              completionSub?.cancel();
              if (mounted) {
                widget.onSongSelected(songs[_selectedSongIndex].title);
              }
            });

            // Fallback in case onPlayerComplete fails
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && _isTransitioning) {
                completionSub?.cancel();
                widget.onSongSelected(songs[_selectedSongIndex].title);
              }
            });

            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            widget.onBack();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      autofocus: true,
      child: Scaffold(
        body: Stack(
          children: [
            // Animated background right to left
            AnimatedBuilder(
              animation: _bgScrollController,
              builder: (context, child) {
                return Positioned(
                  top: 0,
                  bottom: 0,
                  left: -(_bgScrollController.value * 2000),
                  width: MediaQuery.of(context).size.width + 2000,
                  child: Image.asset(
                    'images/songbg.jpg',
                    repeat: ImageRepeat.repeatX,
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.centerLeft,
                  ),
                );
              },
            ),
            // Dark overlay
            Container(color: Colors.black.withOpacity(0.2)),
            // Main content
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title at top left
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Select Song',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Song bars in the middle
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final listHeight = constraints.maxHeight;
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: listHeight * 0.95,
                                        child: ListView.builder(
                                          controller: _scrollController,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: songs.length,
                                          itemBuilder: (context, index) {
                                            int songDataIndex = index;
                                            bool isSelected =
                                                index == _selectedSongIndex;
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: GestureDetector(
                                                onTap:
                                                    songs[index].title.isEmpty
                                                    ? null
                                                    : () {
                                                        _sfxPlayer.play(
                                                          AssetSource(
                                                            'audio/KatsuSound.wav',
                                                          ),
                                                        );
                                                        setState(() {
                                                          _selectedSongIndex =
                                                              index;
                                                        });
                                                        _scrollToSelected();
                                                      },
                                                child: AnimatedScale(
                                                  scale: isSelected
                                                      ? 1.1
                                                      : 0.95,
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      // Song bar using song.png
                                                      Opacity(
                                                        opacity:
                                                            songs[songDataIndex]
                                                                .title
                                                                .isEmpty
                                                            ? 0.3
                                                            : 1.0,
                                                        child: Container(
                                                          width: 110,
                                                          height:
                                                              listHeight * 0.85,
                                                          decoration: BoxDecoration(
                                                            boxShadow:
                                                                isSelected
                                                                ? [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .yellow
                                                                          .withOpacity(
                                                                            0.8,
                                                                          ),
                                                                      blurRadius:
                                                                          20,
                                                                      spreadRadius:
                                                                          2,
                                                                    ),
                                                                  ]
                                                                : [],
                                                          ),
                                                          child: Stack(
                                                            children: [
                                                              // Background texture
                                                              Image.asset(
                                                                'images/song.png',
                                                                fit:
                                                                    BoxFit.fill,
                                                                width: 110,
                                                                height:
                                                                    listHeight *
                                                                    0.85,
                                                              ),
                                                              // Song info overlay
                                                              Positioned.fill(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: [
                                                                    Text(
                                                                      songs[songDataIndex]
                                                                          .title
                                                                          .characters
                                                                          .join(
                                                                            '\n',
                                                                          ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black,
                                                                        height:
                                                                            1.2,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      songs[songDataIndex]
                                                                          .subtitle,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black54,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Floating Don character
            Positioned(
              left: 30,
              bottom: 30,
              child: AnimatedBuilder(
                animation: _donAnimationController,
                builder: (context, child) {
                  // Determine character folder
                  String charFolder = widget.selectedCharacter;
                  int lastSlash = charFolder.lastIndexOf('/');
                  if (lastSlash != -1) {
                    charFolder = charFolder.substring(0, lastSlash);
                  }

                  String currentImage = _showLeftIdle
                      ? '$charFolder/left.png'
                      : '$charFolder/right.png';

                  return Transform.translate(
                    offset: Offset(0, -(_donAnimationController.value * 20)),
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.asset(
                        currentImage,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // fallback to stand if left/right are missing
                          return Image.asset(
                            widget.selectedCharacter,
                            fit: BoxFit.contain,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
