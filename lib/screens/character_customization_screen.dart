import 'package:flutter/material.dart';
import '../models/character_model.dart';

class CharacterCustomizationScreen extends StatefulWidget {
  final CharacterCustomization initialCustomization;
  final VoidCallback onContinue;

  const CharacterCustomizationScreen({
    super.key,
    required this.initialCustomization,
    required this.onContinue,
  });

  @override
  State<CharacterCustomizationScreen> createState() =>
      _CharacterCustomizationScreenState();
}

class _CharacterCustomizationScreenState
    extends State<CharacterCustomizationScreen> {
  late CharacterCustomization customization;

  @override
  void initState() {
    super.initState();
    customization = CharacterCustomization(
      hatIndex: widget.initialCustomization.hatIndex,
      shirtIndex: widget.initialCustomization.shirtIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taiko Character'),
        backgroundColor: Colors.deepPurple.shade400,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Character Preview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.deepPurple.shade300, width: 2),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    'Your Character',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Character with emojis (taiko representation)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          customization.currentHat,
                          style: const TextStyle(fontSize: 60),
                        ),
                        Text(
                          '🥁', // Taiko drum
                          style: const TextStyle(fontSize: 80),
                        ),
                        Text(
                          customization.currentShirt,
                          style: const TextStyle(fontSize: 60),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Hat Selection
            _buildCustomizationSection(
              title: 'Choose Hat',
              items: CharacterCustomization.hats,
              selectedIndex: customization.hatIndex,
              onSelected: (index) {
                setState(() {
                  customization.setHat(index);
                });
              },
            ),
            const SizedBox(height: 30),
            // Shirt Selection
            _buildCustomizationSection(
              title: 'Choose Shirt',
              items: CharacterCustomization.shirts,
              selectedIndex: customization.shirtIndex,
              onSelected: (index) {
                setState(() {
                  customization.setShirt(index);
                });
              },
            ),
            const SizedBox(height: 40),
            // Continue Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  // Update parent customization
                  widget.initialCustomization.setHat(customization.hatIndex);
                  widget.initialCustomization.setShirt(
                    customization.shirtIndex,
                  );
                  widget.onContinue();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Continue to Game',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationSection({
    required String title,
    required List<String> items,
    required int selectedIndex,
    required Function(int) onSelected,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () => onSelected(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.deepPurple.shade300
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.deepPurple.shade600
                          : Colors.grey.shade400,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        items[index].split(' ')[0], // emoji
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        items[index].split(' ').skip(1).join(' '), // label
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
