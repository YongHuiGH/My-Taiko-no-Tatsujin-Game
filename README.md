# Taiko no Tatsujin Game

A Flutter-based rhythm game inspired by the popular arcade game "Taiko no Tatsujin"!

## 🎮 Game Overview

**Taiko no Tatsujin** is an interactive rhythm game where players tap to the beat of the music. The game features:

- **4 Unique Characters**: Choose from 4 different playable characters, each with their own costume
- **Rhythm Gameplay**: Tap along to the beat of selected songs and earn points based on accuracy
- **Score System**: 
  - Perfect hits (highest score)
  - OK hits (medium score)
  - Misses (no score)
  - Combo tracking for consecutive hits
- **Immersive Audio**: Background music and sound effects that react to your gameplay
- **Results Screen**: View your final score, combo count, and hit accuracy

## 📋 Prerequisites

Before you begin, make sure you have:
- Flutter SDK installed ([visit flutter.dev](https://flutter.dev/docs/get-started/install))
- A supported IDE (VS Code, Android Studio, or IntelliJ IDEA)
- Dart SDK (comes with Flutter)

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/YongHuiGH/My-Taiko-no-Tatsujin-Game.git
cd My-Taiko-no-Tatsujin-Game
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the Game

**For Android:**
```bash
flutter run -d android
```

**For iOS:**
```bash
flutter run -d ios
```

**For Web:**
```bash
flutter run -d chrome
```

**For Desktop (Windows/macOS/Linux):**
```bash
flutter run -d windows
# or
flutter run -d macos
# or
flutter run -d linux
```

## 📁 Project Structure

```
lib/
├── main.dart                          # Main entry point
├── models/
│   └── character_model.dart          # Character data model
└── screens/
    ├── start_screen.dart             # Game start menu
    ├── character_selection_screen.dart # Character selection
    ├── song_selection_screen.dart     # Song selection
    ├── game_screen.dart               # Main gameplay screen
    └── result_screen.dart             # Results and score display

audio/                                 # Game audio files
images/                               # Game assets (characters, backgrounds)
android/                              # Android-specific code
ios/                                  # iOS-specific code
windows/                              # Windows-specific code
macos/                                # macOS-specific code
linux/                                # Linux-specific code
web/                                  # Web-specific code
```

## 🎵 How to Play

1. **Start**: Press the "Start" button on the main menu
2. **Select Character**: Choose your favorite character from 4 options
3. **Select Song**: Pick a song to play
4. **Play**: 
   - Watch for the timing indicators
   - Tap when the note hits the target zone
   - Aim for "Perfect" hits for maximum score
5. **Results**: View your final score, combo, and hit accuracy

## 🛠️ Technologies Used

- **Flutter**: Cross-platform mobile/desktop framework
- **Dart**: Programming language
- **AudioPlayers**: For in-game audio playback
- **Material Design**: UI/UX framework

## 📝 Game Features

- Smooth character animations
- Responsive tap detection
- Accurate combo and score tracking
- Audio feedback for hits and misses
- Beautiful Material Design UI

## 🤝 Contributing

Feel free to fork this project and submit pull requests with improvements!

## 📄 License

This project is open source.

## 🎯 Future Enhancements

- Additional songs
- Difficulty levels
- Leaderboard system
- Sound mixing customization
- Multiplayer mode

---

**Enjoy playing Taiko no Tatsujin!** 🥁
