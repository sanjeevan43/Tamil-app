import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../constants/app_theme.dart';

class DailyTamilPowerWordScreen extends StatefulWidget {
  const DailyTamilPowerWordScreen({super.key});

  @override
  State<DailyTamilPowerWordScreen> createState() => _DailyTamilPowerWordScreenState();
}

class _DailyTamilPowerWordScreenState extends State<DailyTamilPowerWordScreen> {
  final FirestoreService _firestore = FirestoreService();
  Map<String, dynamic>? _dailyWord;
  bool _isLoading = true;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _fetchDailyWord();
  }

  Future<void> _fetchDailyWord() async {
    final word = await _firestore.getDailyWord();
    setState(() {
      _dailyWord = word;
      _isLoading = false;
    });
  }

  Future<void> _speakWord() async {
    if (_dailyWord == null) return;
    await flutterTts.setLanguage("ta-IN");
    await flutterTts.speak(_dailyWord!['word']);
  }

  Future<void> _speakSentence() async {
    if (_dailyWord == null || _dailyWord!['sentence'] == null) return;
    await flutterTts.setLanguage("ta-IN");
    await flutterTts.speak(_dailyWord!['sentence']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Daily Tamil Power Word', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _dailyWord == null
              ? const Center(child: Text('No daily word set for today!', style: TextStyle(fontSize: 18)))
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.wb_sunny_rounded, size: 80, color: AppTheme.accent),
                      const SizedBox(height: 20),
                      Text("Today's Power Word", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 22, color: Colors.grey[700])),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            children: [
                              Text(
                                _dailyWord!['word'],
                                style: GoogleFonts.mukta(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primary),
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up, size: 36, color: AppTheme.accent),
                                onPressed: _speakWord,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Meaning: ${_dailyWord!['english']}",
                                style: GoogleFonts.poppins(fontSize: 20, color: Colors.black87),
                              ),
                              const Divider(height: 40),
                              Text(
                                "Example Sentence:",
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _dailyWord!['sentence'] ?? '',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.mukta(fontSize: 20, color: Colors.black87),
                              ),
                              if (_dailyWord!['sentence'] != null && _dailyWord!['sentence'].toString().isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.volume_up, color: AppTheme.accent),
                                  onPressed: _speakSentence,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          // Quick quiz or practice logic here
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz feature coming soon!')));
                        },
                        child: Text('Practice this Word', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
    );
  }
}
