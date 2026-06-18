import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../constants/app_theme.dart';
import '../services/auth_service.dart';
import '../providers/enhanced_progress_provider.dart';
import 'package:provider/provider.dart';
import 'admin_classrooms_tab.dart';
import '../data/moral_stories_data.dart';
import '../data/tamil_data.dart';
import 'splash_screen.dart';

class AdminControlScreen extends StatefulWidget {
  const AdminControlScreen({super.key});

  @override
  State<AdminControlScreen> createState() => _AdminControlScreenState();
}

class _AdminControlScreenState extends State<AdminControlScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestore = FirestoreService();
  final _topicFormKey = GlobalKey<FormState>();
  

  final TextEditingController _topicTitleController = TextEditingController();
  final TextEditingController _topicOrderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();

    _topicTitleController.dispose();
    _topicOrderController.dispose();
    super.dispose();
  }



  Future<void> _seedMoralStories() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final story in MoralStoriesData.moralStories) {
        final docRef = FirebaseFirestore.instance.collection('stories').doc(story['id']);
        batch.set(docRef, {
          ...story,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        _showSnackBar('Successfully seeded 16 Moral Stories!', AppTheme.success);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        _showSnackBar('Error seeding stories: $e', AppTheme.primary);
      }
    }
  }

  Future<void> _seedRhymes() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final rhyme in TamilData.tamilRhymes) {
        final docId = rhyme['title'].hashCode.toString();
        final docRef = FirebaseFirestore.instance.collection('rhymes').doc(docId);
        batch.set(docRef, {
          ...rhyme,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        _showSnackBar('Successfully seeded Tamil Rhymes!', AppTheme.success);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        _showSnackBar('Error seeding rhymes: $e', AppTheme.primary);
      }
    }
  }

  Future<void> _seedTopics() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final topic in TamilData.lessons) {
        final docId = topic['id'].toString();
        final docRef = FirebaseFirestore.instance.collection('topics').doc(docId);
        batch.set(docRef, {
          ...topic,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        _showSnackBar('Successfully seeded Learning Topics!', AppTheme.success);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        _showSnackBar('Error seeding topics: $e', AppTheme.primary);
      }
    }
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

    _showSnackBar('Topic Added!', AppTheme.success);
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
    _showSnackBar('User role updated to $newRole', AppTheme.info);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        
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
              Provider.of<EnhancedProgressProvider>(context, listen: false).clearProgress();
              Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.white,
          isScrollable: true,
          tabs: const [

            Tab(icon: Icon(Icons.topic_outlined), text: 'Topics'),
            Tab(icon: Icon(Icons.school_outlined), text: 'Classrooms'),
            Tab(icon: Icon(Icons.people_outline), text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [

          _buildTopicsTab(),
          const AdminClassroomsTab(),
          _buildUsersTab(),
        ],
      ),
    );
  }



  Widget _buildSeedCard({
    required String title,
    required String desc,
    required IconData icon,
    required VoidCallback onPressed,
    required String btnText,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary.withOpacity(0.08), AppTheme.primary.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.secondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSlate, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(btnText, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold)),
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
          Text('Database Seeding Dashboard', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildSeedCard(
                  title: 'Moral Stories',
                  desc: '16 bilingual moral stories & interactive quizzes.',
                  icon: Icons.auto_stories,
                  onPressed: _seedMoralStories,
                  btnText: 'SEED STORIES',
                ),
                const SizedBox(width: 12),
                _buildSeedCard(
                  title: 'Tamil Rhymes',
                  desc: 'Sing-along interactive nursery rhymes.',
                  icon: Icons.music_note,
                  onPressed: _seedRhymes,
                  btnText: 'SEED RHYMES',
                ),
                const SizedBox(width: 12),
                _buildSeedCard(
                  title: 'Learning Topics',
                  desc: 'Topics/Lessons structured learning levels.',
                  icon: Icons.bookmark,
                  onPressed: _seedTopics,
                  btnText: 'SEED TOPICS',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Manage Learning Topics', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Form(
            key: _topicFormKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _topicTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Topic Title',
                      border: OutlineInputBorder(),
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
                    decoration: const InputDecoration(
                      labelText: 'Order',
                      border: OutlineInputBorder(),
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
                          icon: const Icon(Icons.delete, color: AppTheme.primary),
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
