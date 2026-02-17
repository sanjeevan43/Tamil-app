import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../constants/tamil_data.dart';
import '../services/audio_service.dart';

class SimpleWordsScreen extends StatefulWidget {
  const SimpleWordsScreen({super.key});

  @override
  State<SimpleWordsScreen> createState() => _SimpleWordsScreenState();
}

class _SimpleWordsScreenState extends State<SimpleWordsScreen> {
  String selectedCategory = 'Animals';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Words')),
      body: Column(
        children: [
          _buildCategoryTabs(),
          Expanded(child: _buildWordsList()),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: TamilData.wordCategories.keys.map((category) {
          final isSelected = category == selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryRed : AppTheme.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.primaryRed, width: 2),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppTheme.white : AppTheme.primaryRed,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWordsList() {
    final words = TamilData.wordCategories[selectedCategory] ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: words.length,
      itemBuilder: (context, index) => _buildWordCard(words[index]),
    );
  }

  Widget _buildWordCard(Map<String, String> word) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.glassCard(),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Text(word['emoji']!, style: const TextStyle(fontSize: 40)),
        title: Text(
          word['tamil']!,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
        ),
        subtitle: Text(word['english']!, style: const TextStyle(fontSize: 16)),
        trailing: IconButton(
          icon: const Icon(Icons.volume_up, color: AppTheme.primaryRed, size: 32),
          onPressed: () => AudioService.playWord(word['tamil']!),
        ),
      ),
    );
  }
}
