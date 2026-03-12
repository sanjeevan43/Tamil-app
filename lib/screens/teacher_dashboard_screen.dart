import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import '../services/firestore_service.dart';
import 'teaching_guide_screen.dart';
import 'classroom_connect_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherDashboardScreen extends StatelessWidget {
  TeacherDashboardScreen({super.key});

  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.offWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.topoSilver),
              ),
              child: Image.asset('assets/images/29099e40-2686-49d2-af50-5d939b785f80.png'),
            ),
            const SizedBox(width: 12),
            Text(
              'TEACHER DASHBOARD',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.secondary, fontSize: 16, letterSpacing: 1),
            ),
          ],
        ),
        actions: [
          Switch(
            value: progress.isTeacherMode,
            onChanged: (_) => progress.toggleTeacherMode(),
            activeColor: AppTheme.primary,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryRed.withOpacity(0.05), AppTheme.offWhite],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStudentOverview(progress),
              const SizedBox(height: 24),
              _buildAnnouncement(context),
              const SizedBox(height: 24),
              _buildLessonControl(context, progress),
              const SizedBox(height: 24),
              _buildHomework(context),
              const SizedBox(height: 24),
              _buildClassroomHub(context),
              const SizedBox(height: 24),
              _buildReports(context),
              const SizedBox(height: 24),
              _buildTeachingGuideLink(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncement(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.getNoticeStream(),
      builder: (context, snapshot) {
        final notice = snapshot.hasData && snapshot.data!.exists 
            ? (snapshot.data!.data() as Map<String, dynamic>)['message'] ?? 'No notice' 
            : 'Loading notice...';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassCard(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.campaign_rounded, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'அறிவிப்பு பலகை (Notice Board)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.1)),
                ),
                child: Text(
                  notice,
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.brown),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showNoticeDialog(context, notice),
                icon: const Icon(Icons.edit_notifications),
                label: const Text('அறிவிப்பை மாற்று (Edit Notice)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.brown,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildHomework(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.getTasksStream(),
      builder: (context, snapshot) {
        final tasks = snapshot.hasData ? snapshot.data!.docs : [];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassCard(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'வீட்டுப்பாடம் (Tasks & Quizzes)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
              ),
              const SizedBox(height: 16),
              if (tasks.isEmpty)
                const Text('பணிகள் எதுவுமில்லை', style: TextStyle(color: AppTheme.textGray))
              else
                ...tasks.take(3).map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: Icon(
                      data['type'] == 'Quiz' ? Icons.quiz : Icons.assignment, 
                      color: AppTheme.primaryRed
                    ),
                    title: Text(data['title'] ?? ''),
                    subtitle: Text(data['type'] ?? ''),
                    contentPadding: EdgeInsets.zero,
                  );
                }),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showHomeworkDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAssignQuizDialog(context),
                      icon: const Icon(Icons.quiz),
                      label: const Text('Quiz'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTeachingGuideLink(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book, color: Colors.amber, size: 28),
              SizedBox(width: 12),
              Text(
                'கற்பித்தல் வழிகாட்டி',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'உங்கள் மாணவருக்கு தமிழை முறையாகக் கற்பிக்க உதவும் விரிவான வழிகாட்டி.',
            style: TextStyle(fontSize: 14, color: Colors.brown),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TeachingGuideScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.brown,
              elevation: 0,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('வழிகாட்டியைப் பார்க்க (View Guide)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentOverview(EnhancedProgressProvider progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UNIFIED CLASSROOM',
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.6), letterSpacing: 2),
              ),
              const Icon(Icons.hub_rounded, color: Colors.white, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Global Students Hub',
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _buildInfoRow('Active Student', progress.userName),
                const Divider(color: Colors.white24),
                _buildInfoRow('Class Average Level', '${progress.level}'),
                const Divider(color: Colors.white24),
                _buildInfoRow('Total Letters Taught', '${progress.totalLettersLearned}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.white)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonControl(BuildContext context, EnhancedProgressProvider progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'பாடக் கட்டுப்பாடு (Lesson Control)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
          ),
          const SizedBox(height: 16),
          const Text('திறக்கப்பட்ட பாடங்கள் (Unlocked):', style: TextStyle(fontSize: 15)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: progress.unlockedLessons.map((id) {
              return Chip(
                label: Text('பாடம் $id'),
                backgroundColor: AppTheme.primaryRed.withOpacity(0.1),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showUnlockDialog(context, progress),
            icon: const Icon(Icons.lock_open),
            label: const Text('அடுத்த பாடத்தைத் திற (Unlock Next)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassroomHub(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'வகுப்பறை மையம் (Classroom Hub)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          const Text('கேள்விகளுக்கு பதிலளிக்கவும் மற்றும் வினாடி வினாக்களை அனுப்பவும்.', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassroomConnectScreen())),
            icon: const Icon(Icons.forum_rounded),
            label: const Text('மையத்திற்குச் செல்லவும் (Go to Hub)'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReports(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'அறிக்கைகள் (Reports)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('அறிக்கை ஏற்றுமதி விரைவில் வரும்!')),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('அறிக்கையை பதிவிறக்கு (Export Report)'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showNoticeDialog(BuildContext context, String currentNotice) {
    final controller = TextEditingController(text: currentNotice);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('புதிய அறிவிப்பு'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'இங்கே அறிவிப்பைத் தட்டச்சு செய்க...'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('வேண்டாம்')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _firestore.updateNotice(controller.text);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notice cannot be empty!'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('அறிவிப்பு செய்'),
          ),
        ],
      ),
    );
  }

  void _showUnlockDialog(BuildContext context, EnhancedProgressProvider progress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('பாடம் திறக்கவா?'),
        content: const Text('மாணவருக்காக அடுத்த பாடத்தை திறக்க வேண்டுமா?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('வேண்டாம்'),
          ),
          ElevatedButton(
            onPressed: () {
              final nextLesson = (progress.unlockedLessons.lastOrNull ?? 0) + 1;
              if (nextLesson <= 7) {
                progress.unlockLesson(nextLesson);
              }
              Navigator.pop(context);
            },
            child: const Text('சரி'),
          ),
        ],
      ),
    );
  }

  void _showHomeworkDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('புதிய பணி (New Assignment)'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'இங்கே உள்ளீடு செய்யவும்...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('வேண்டாம்'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _firestore.addTask({
                  'title': controller.text,
                  'type': 'Homework',
                  'status': 'Pending',
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Assignment cannot be empty!'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('அனுப்பு'),
          ),
        ],
      ),
    );
  }

  void _showAssignQuizDialog(BuildContext context) {
    final quizzes = ['Vowels Challenge', 'Animals Master', 'Sentence Builder', 'Daily Tamil Test'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('வினாடி வினாவைத் தேர்ந்தெடுக்கவும்'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: quizzes.map((q) => ListTile(
            title: Text(q),
            leading: const Icon(Icons.quiz_rounded, color: AppTheme.primaryRed),
            onTap: () async {
              await _firestore.addTask({
                'title': q,
                'type': 'Quiz',
                'status': 'Pending',
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$q ஒதுக்கப்பட்டது!')),
              );
            },
          )).toList(),
        ),
      ),
    );
  }
}
