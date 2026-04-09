class CharacterCustomization {
  int hatIndex;
  int shirtIndex;

  CharacterCustomization({this.hatIndex = 0, this.shirtIndex = 0});

  // Hat options
  static const List<String> hats = [
    '👑 Gold Crown',
    '🎩 Top Hat',
    '🧢 Baseball Cap',
    '🎓 Graduate Cap',
    '👒 Sun Hat',
  ];

  // Shirt options
  static const List<String> shirts = [
    '🔴 Red Shirt',
    '🔵 Blue Shirt',
    '🟢 Green Shirt',
    '🟡 Yellow Shirt',
    '🟣 Purple Shirt',
  ];

  String get currentHat => hats[hatIndex];
  String get currentShirt => shirts[shirtIndex];

  void setHat(int index) {
    if (index >= 0 && index < hats.length) {
      hatIndex = index;
    }
  }

  void setShirt(int index) {
    if (index >= 0 && index < shirts.length) {
      shirtIndex = index;
    }
  }
}
