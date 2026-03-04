import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../constants/app_theme.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'admin_classrooms_tab.dart';

class AdminControlScreen extends StatefulWidget {
  const AdminControlScreen({super.key});

  @override
  State<AdminControlScreen> createState() => _AdminControlScreenState();
}

class _AdminControlScreenState extends State<AdminControlScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestore = FirestoreService();
  final _dailyWordFormKey = GlobalKey<FormState>();
  final _topicFormKey = GlobalKey<FormState>();
  
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _englishController = TextEditingController();
  final TextEditingController _sentenceController = TextEditingController();
  final TextEditingController _topicTitleController = TextEditingController();
  final TextEditingController _topicOrderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _wordController.dispose();
    _englishController.dispose();
    _sentenceController.dispose();
    _topicTitleController.dispose();
    _topicOrderController.dispose();
    super.dispose();
  }

  Future<void> _addDailyWord() async {
    if (!_dailyWordFormKey.currentState!.validate()) return;

    final word = _wordController.text.trim();
    final english = _englishController.text.trim();
    final sentence = _sentenceController.text.trim();

    final dateStr = DateTime.now().toIso8601String().split('T').first;
    await _firestore.addDailyWord({
      'word': word,
      'english': english,
      'sentence': sentence,
      'date': dateStr,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _showSnackBar('Daily Word Added!', Colors.green);
    _wordController.clear();
    _englishController.clear();
    _sentenceController.clear();
  }

  Future<void> _addTopic() async {
    if (!_topicFormKey.currentState!.validate()) return;

    final title = _topicTitleController.text.trim();
    final order = int.tryParse(_topicOrderController.text.trim()) ?? 0;

    await _firestore.addTopic({
      'title': title,
      'order': order,
      'status': 'unlocked',
      'createdAt': FieldValue.serverTimestamp(),
    });

    _showSnackBar('Topic Added!', Colors.green);
    _topicTitleController.clear();
    _topicOrderController.clear();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _updateUserRole(String uid, String newRole) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'role': newRole});
    _showSnackBar('User role updated to $newRole', Colors.blue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.offWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.topoSilver),
              ),
              child: Image.asset('assets/images/29099e40-2686-49d2-af50-5d939b785f80.png'),
            ),
            const SizedBox(width: 12),
            Text(
              'ADMIN CENTER',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.secondary, fontSize: 18, letterSpacing: 1),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new_rounded, color: AppTheme.primary),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.wb_sunny_outlined), text: 'Daily Word'),
            Tab(icon: Icon(Icons.topic_outlined), text: 'Topics'),
            Tab(icon: Icon(Icons.school_outlined), text: 'Classrooms'),
            Tab(icon: Icon(Icons.people_outline), text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyWordTab(),
          _buildTopicsTab(),
          const AdminClassroomsTab(),
          _buildUsersTab(),
        ],
      ),
    );
  }

  Widget _buildDailyWordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Post Daily Tamil Word', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _dailyWordFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _wordController,
                      decoration: InputDecoration(
                        labelText: 'Tamil Word',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: AppTheme.topoLight,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Tamil word is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Word must be at least 2 characters';
                        }
                        if (value.trim().length > 100) {
                          return 'Word must be less than 100 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _englishController,
                      decoration: InputDecoration(
                        labelText: 'English Meaning',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: AppTheme.topoLight,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'English meaning is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Meaning must be at least 2 characters';
                        }
                        if (value.trim().length > 200) {
                          return 'Meaning must be less than 200 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sentenceController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Example Sentence',
                        hintText: 'Both Tamil & English info',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: AppTheme.topoLight,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Example sentence is required';
                        }
                        if (value.trim().length < 5) {
                          return 'Sentence must be at least 5 characters';
                        }
                        if (value.trim().length > 500) {
                          return 'Sentence must be less than 500 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addDailyWord,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: AppTheme.primary,
                      ),
                      child: Text('Publish Word', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manage Learning Topics', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Form(
            key: _topicFormKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _topicTitleController,
                    decoration: InputDecoration(
                      labelText: 'Topic Title',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: AppTheme.topoLight,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title required';
                      }
                      if (value.trim().length < 2) {
                        return 'Min 2 chars';
                      }
                      if (value.trim().length > 100) {
                        return 'Max 100 chars';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: _topicOrderController,
                    decoration: InputDecoration(
                      labelText: 'Order',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: AppTheme.topoLight,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Number only';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addTopic,
                  icon: const Icon(Icons.add_circle, color: AppTheme.primary, size: 40),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.getTopicsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final topics = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final data = topics[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${data['order']}')),
                        title: Text(data['title']),
                        subtitle: Text('Status: ${data['status']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _firestore.deleteTopic(topics[index].id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final users = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            final uid = users[index].id;
            final currentRole = user['role'] ?? 'student';
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(user['displayName'] ?? 'No Name'),
                subtitle: Text(user['email'] ?? 'No Email'),
                trailing: DropdownButton<String>(
                  value: currentRole,
                  items: ['student', 'teacher', 'parent', 'admin'].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role.toUpperCase()));
                  }).toList(),
                  onChanged: (newRole) {
                    if (newRole != null) _updateUserRole(uid, newRole);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
