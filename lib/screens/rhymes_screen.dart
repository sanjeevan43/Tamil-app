import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/colors.dart';
import '../constants/tamil_data.dart';

class RhymesScreen extends StatefulWidget {
  const RhymesScreen({super.key});

  @override
  State<RhymesScreen> createState() => _RhymesScreenState();
}

class _RhymesScreenState extends State<RhymesScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int? _selectedRhymeIndex;
  int _lineIndex = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await flutterTts.setLanguage("ta-IN");
    await flutterTts.setPitch(1.2);
    await flutterTts.setSpeechRate(0.4);
  }

  Future<void> _speak(String text) async {
    setState(() => _isPlaying = true);
    await flutterTts.speak(text);
    flutterTts.setCompletionHandler(() {
      setState(() => _isPlaying = false);
    });
  }

  Future<void> _stop() async {
    await flutterTts.stop();
    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedRhymeIndex != null) {
      return _buildRhymePlayer();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('குழந்தை பாடல்கள்'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: TamilData.tamilRhymes.length,
        itemBuilder: (context, index) {
          final rhyme = TamilData.tamilRhymes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.music_note, color: AppColors.primaryRed),
              ),
              title: Text(
                rhyme['title']!,
                style: GoogleFonts.notoSansTamil(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed,
                ),
              ),
              subtitle: Text('${(rhyme['lines'] as List).length} Lines'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                setState(() {
                  _selectedRhymeIndex = index;
                  _lineIndex = 0;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRhymePlayer() {
    final rhyme = TamilData.tamilRhymes[_selectedRhymeIndex!];
    final lines = rhyme['lines'] as List;
    final currentLine = lines[_lineIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(rhyme['title']!),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _stop();
            setState(() => _selectedRhymeIndex = null);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryRed.withOpacity(0.05), AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image Area
                      Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryRed.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/${currentLine['image']}.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.music_video, size: 80, color: AppColors.primaryRed),
                              const SizedBox(height: 10),
                              Text(
                                'Image: ${currentLine['image']}',
                                style: const TextStyle(color: AppColors.textGray, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Text Area
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          currentLine['content'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSansTamil(
                            fontSize: 32,
                            height: 1.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Controls
            Container(
              padding: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    iconSize: 48,
                    icon: Icon(Icons.skip_previous, 
                      color: _lineIndex > 0 ? AppColors.primaryRed : Colors.grey[300]),
                    onPressed: _lineIndex > 0 ? () {
                      _stop();
                      setState(() => _lineIndex--);
                    } : null,
                  ),
                  GestureDetector(
                    onTap: () => _isPlaying ? _stop() : _speak(currentLine['content']),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.primaryRed, blurRadius: 10, spreadRadius: 1)],
                      ),
                      child: Icon(_isPlaying ? Icons.stop : Icons.play_arrow, size: 48, color: Colors.white),
                    ),
                  ),
                  IconButton(
                    iconSize: 48,
                    icon: Icon(Icons.skip_next, 
                      color: _lineIndex < lines.length - 1 ? AppColors.primaryRed : Colors.grey[300]),
                    onPressed: _lineIndex < lines.length - 1 ? () {
                      _stop();
                      setState(() => _lineIndex++);
                    } : null,
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
