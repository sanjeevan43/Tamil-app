import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../constants/app_theme.dart';

class AdminControlScreen extends StatefulWidget {
  const AdminControlScreen({super.key});

  @override
  State<AdminControlScreen> createState() => _AdminControlScreenState();
}

class _AdminControlScreenState extends State<AdminControlScreen> {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _englishController = TextEditingController();
  final TextEditingController _sentenceController = TextEditingController();

  Future<void> _addDailyWord() async {
    final word = _wordController.text;
    final english = _englishController.text;
    final sentence = _sentenceController.text;

    if (word.trim().isEmpty || english.trim().isEmpty || sentence.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!'), backgroundColor: Colors.red),
      );
      return;
    }

    final dateStr = DateTime.now().toIso8601String().split('T').first;
      await _firestore.addDailyWord({
        'word': word,
        'english': english,
        'sentence': sentence,
        'date': dateStr,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily Word Added!')),
      );
      _wordController.clear();
      _englishController.clear();
    _sentenceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Daily Tamil Power Word', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(controller: _wordController, decoration: const InputDecoration(labelText: 'Tamil Word')),
            TextField(controller: _englishController, decoration: const InputDecoration(labelText: 'English Meaning')),
            TextField(controller: _sentenceController, decoration: const InputDecoration(labelText: 'Example Sentence (Tamil & English)')),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _addDailyWord, child: const Text('Save Daily Word')),
            
            const SizedBox(height: 40),
            
            Text('Manage Topics', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.getTopicsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final topics = snapshot.data!.docs;
                if (topics.isEmpty) return const Text('No topics added.');
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final data = topics[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['title'] ?? 'Title'),
                      subtitle: Text(data['status'] ?? 'locked'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _firestore.deleteTopic(topics[index].id),
                      ),
                    );
                  }
                );
              }
            ),
                ElevatedButton(
                  onPressed: () {
                    _firestore.addTopic({
                      'title': 'New Lesson',
                      'order': 1,
                      'status': 'unlocked',
                    });
                  },
                  child: const Text('Add Demo Topic'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
