import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import 'teaching_guide_screen.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ஆசிரியர் பக்கம் (Teacher Dashboard)', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Switch(
            value: progress.isTeacherMode,
            onChanged: (_) => progress.toggleTeacherMode(),
            activeColor: AppTheme.white,
          ),
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
              _buildLessonControl(context, progress),
              const SizedBox(height: 24),
              _buildHomework(context, progress),
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
          Row(
            children: [
              const Icon(Icons.menu_book, color: Colors.amber, size: 28),
              const SizedBox(width: 12),
              const Text(
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
      decoration: AppTheme.premiumCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'மாணவர் விவரம் (Student Overview)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.white),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('பெயர் (Name)', progress.userName),
          _buildInfoRow('நிலை (Level)', '${progress.level}'),
          _buildInfoRow('நட்சத்திரங்கள் (Stars)', '${progress.totalStars}'),
          _buildInfoRow('தொடர் நாட்கள் (Streak)', '${progress.streakDays}'),
          _buildInfoRow('கற்ற எழுத்துக்கள் (Letters)', '${progress.totalLettersLearned}'),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomework(BuildContext context, EnhancedProgressProvider progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'வீட்டுப்பாடம் (Assigned Homework)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
          ),
          const SizedBox(height: 16),
          if (progress.assignedHomework.isEmpty)
            const Text('வீட்டுப்பாடம் எதுவும் இல்லை', style: TextStyle(color: AppTheme.textGray))
          else
            ...progress.assignedHomework.map((hw) => ListTile(
                  leading: const Icon(Icons.assignment, color: AppTheme.primaryRed),
                  title: Text(hw),
                )),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showHomeworkDialog(context, progress),
            icon: const Icon(Icons.add),
            label: const Text('வீட்டுப்பாடம் கொடு (Assign Homework)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
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

  void _showHomeworkDialog(BuildContext context, EnhancedProgressProvider progress) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('வீட்டுப்பாடம்'),
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
            onPressed: () {
              if (controller.text.isNotEmpty) {
                progress.assignHomework(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('அனுப்பு'),
          ),
        ],
      ),
    );
  }
}
