import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          Switch(
            value: progress.isTeacherMode,
            onChanged: (_) => progress.toggleTeacherMode(),
            activeColor: AppTheme.white,
          ),
        ],
      ),
      body: SingleChildScrollView(
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
          ],
        ),
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
            'Student Overview',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.white),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Name', progress.userName),
          _buildInfoRow('Level', '${progress.level}'),
          _buildInfoRow('Total Stars', '${progress.totalStars}'),
          _buildInfoRow('Streak Days', '${progress.streakDays}'),
          _buildInfoRow('Letters Learned', '${progress.totalLettersLearned}'),
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
          Text(label, style: const TextStyle(fontSize: 16, color: AppTheme.white)),
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
            'Lesson Control',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
          ),
          const SizedBox(height: 16),
          const Text('Unlocked Lessons:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: progress.unlockedLessons.map((id) {
              return Chip(
                label: Text('Lesson $id'),
                backgroundColor: AppTheme.success.withOpacity(0.2),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showUnlockDialog(context, progress),
            icon: const Icon(Icons.lock_open),
            label: const Text('Unlock Next Lesson'),
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
            'Assigned Homework',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
          ),
          const SizedBox(height: 16),
          if (progress.assignedHomework.isEmpty)
            const Text('No homework assigned', style: TextStyle(color: AppTheme.textGray))
          else
            ...progress.assignedHomework.map((hw) => ListTile(
                  leading: const Icon(Icons.assignment, color: AppTheme.primaryRed),
                  title: Text(hw),
                )),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showHomeworkDialog(context, progress),
            icon: const Icon(Icons.add),
            label: const Text('Assign Homework'),
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
            'Reports',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report export feature coming soon!')),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Export Progress Report'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
        ],
      ),
    );
  }

  void _showUnlockDialog(BuildContext context, EnhancedProgressProvider progress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlock Lesson'),
        content: const Text('Unlock the next lesson for this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final nextLesson = progress.unlockedLessons.last + 1;
              if (nextLesson <= 7) {
                progress.unlockLesson(nextLesson);
              }
              Navigator.pop(context);
            },
            child: const Text('Unlock'),
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
        title: const Text('Assign Homework'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter homework description'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                progress.assignHomework(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}
