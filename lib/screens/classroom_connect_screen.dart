import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import 'quiz_screen.dart';

class ClassroomConnectScreen extends StatefulWidget {
  const ClassroomConnectScreen({super.key});

  @override
  State<ClassroomConnectScreen> createState() => _ClassroomConnectScreenState();
}

class _ClassroomConnectScreenState extends State<ClassroomConnectScreen> {
  final TextEditingController _msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    final isTeacher = progress.isTeacherMode;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Column(
          children: [
            Text('வகுப்பறை இணைப்பு', style: GoogleFonts.notoSansTamil(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Classroom Connect', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTopBanner(isTeacher),
          _buildNoticeBoard(progress),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 20),
                _buildSectionTitle(context, 'கல்விப் பணிகள் (Tasks & Homework)'),
                const SizedBox(height: 12),
                _buildTasksList(progress),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'கலந்துரையாடல் (Discussions)'),
                const SizedBox(height: 12),
                _buildDiscussionFeed(progress),
              ],
            ),
          ),
          _buildMessageInput(progress),
        ],
      ),
    );
  }

  Widget _buildTopBanner(bool isTeacher) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCard(radius: 20),
      child: Row(
        children: [
          Icon(isTeacher ? Icons.school : Icons.person, color: Colors.white, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTeacher ? 'Teacher Dashboard' : 'Student Hub',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                ),
                Text(
                  isTeacher ? 'Manage tasks and guide students' : 'Connect with your teacher and complete tasks',
                  style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeBoard(EnhancedProgressProvider progress) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign_rounded, color: Colors.amber, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              progress.globalNotice,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.brown.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.notoSansTamil(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
      ],
    );
  }

  Widget _buildTasksList(EnhancedProgressProvider progress) {
    final quizzes = progress.assignedQuizzes;
    final homework = progress.assignedHomework;

    if (quizzes.isEmpty && homework.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.whiteCard(),
        child: const Center(child: Text('பணிகள் எதுவும் இல்லை (No tasks yet)', style: TextStyle(color: AppTheme.textGray))),
      );
    }

    return Column(
      children: [
        ...homework.map((hw) => _buildTaskCard(
          icon: Icons.assignment_rounded,
          title: hw,
          type: 'Homework',
          status: 'Instruction',
          color: Colors.orange,
        )),
        ...quizzes.map((quiz) => _buildTaskCard(
          icon: Icons.quiz_rounded,
          title: quiz['title'],
          type: 'Quiz',
          status: quiz['status'],
          color: AppTheme.primaryRed,
          onTap: quiz['status'] == 'Pending' ? () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen()));
            progress.completeQuiz(quiz['id']);
          } : null,
        )),
      ],
    );
  }

  Widget _buildTaskCard({
    required IconData icon,
    required String title,
    required String type,
    required String status,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.whiteCard(radius: 16),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: GoogleFonts.notoSansTamil(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(type, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textGray)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'Completed' ? Colors.green.withOpacity(0.1) : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: status == 'Completed' ? Colors.green : color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscussionFeed(EnhancedProgressProvider progress) {
    final discussions = progress.discussions;

    if (discussions.isEmpty) {
      return Container(
        height: 100,
        decoration: AppTheme.whiteCard(),
        child: const Center(child: Text('கேள்விகள் கேளுங்கள்! (Ask a question!)', style: TextStyle(color: AppTheme.textGray))),
      );
    }

    return Column(
      children: discussions.map((msg) => _buildChatMessage(msg)).toList(),
    );
  }

  Widget _buildChatMessage(Map<String, String> msg) {
    final isMe = msg['sender'] == 'You' || (msg['sender'] == 'Teacher' && Provider.of<EnhancedProgressProvider>(context, listen: false).isTeacherMode);
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryRed : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe)
              Text(
                msg['sender']!,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primaryRed),
              ),
            Text(
              msg['message']!,
              style: GoogleFonts.notoSansTamil(
                color: isMe ? Colors.white : AppTheme.textDark,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg['time']!,
              style: TextStyle(
                color: (isMe ? Colors.white : AppTheme.textGray).withOpacity(0.6),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(EnhancedProgressProvider progress) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              decoration: InputDecoration(
                hintText: 'இங்கே கேட்கவும்... (Ask something...)',
                hintStyle: GoogleFonts.notoSansTamil(fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                filled: true,
                fillColor: AppTheme.offWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (_msgController.text.trim().isNotEmpty) {
                progress.addMessage(progress.isTeacherMode ? 'Teacher' : progress.userName, _msgController.text);
                _msgController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Message cannot be empty! (செய்தி காலியாக இருக்கக்கூடாது)'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
