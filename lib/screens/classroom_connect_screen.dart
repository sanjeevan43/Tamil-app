import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import '../services/firestore_service.dart';
import 'quiz_screen.dart';

class ClassroomConnectScreen extends StatefulWidget {
  const ClassroomConnectScreen({super.key});

  @override
  State<ClassroomConnectScreen> createState() => _ClassroomConnectScreenState();
}

class _ClassroomConnectScreenState extends State<ClassroomConnectScreen> {
  final TextEditingController _msgController = TextEditingController();
  final FirestoreService _firestore = FirestoreService();

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
            Text('Classroom Connect', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTopBanner(isTeacher),
          _buildFirestoreNotice(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 20),
                _buildSectionTitle(context, 'கல்விப் பணிகள் (Tasks & Homework)'),
                const SizedBox(height: 12),
                _buildFirestoreTasks(),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'கலந்துரையாடல் (Discussions)'),
                const SizedBox(height: 12),
                _buildFirestoreDiscussions(),
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
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                ),
                Text(
                  isTeacher ? 'Manage tasks and guide students' : 'Connect with your teacher and complete tasks',
                  style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirestoreNotice() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.getNoticeStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }
        final notice = (snapshot.data!.data() as Map<String, dynamic>)['message'] ?? '';
        
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
                  notice,
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.brown.shade800),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.notoSansTamil(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
      ],
    );
  }

  Widget _buildFirestoreTasks() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.getTasksStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final tasks = snapshot.data!.docs;

        if (tasks.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.whiteCard(),
            child: const Center(child: Text('பணிகள் எதுவும் இல்லை (No tasks yet)', style: TextStyle(color: AppTheme.textGray))),
          );
        }

        return Column(
          children: tasks.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final type = data['type'] ?? 'Task';
            final isQuiz = type == 'Quiz';

            return _buildTaskCard(
              icon: isQuiz ? Icons.quiz_rounded : Icons.assignment_rounded,
              title: data['title'] ?? 'Untitled',
              type: type,
              status: 'Open',
              color: isQuiz ? AppTheme.primary : Colors.orange,
              onTap: isQuiz ? () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen()));
              } : null,
            );
          }).toList(),
        );
      },
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
        subtitle: Text(type, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textGray)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirestoreDiscussions() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.getDiscussionsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final messages = snapshot.data!.docs;

        if (messages.isEmpty) {
          return Container(
            height: 100,
            decoration: AppTheme.whiteCard(),
            child: const Center(child: Text('கேள்விகள் கேளுங்கள்! (Ask a question!)', style: TextStyle(color: AppTheme.textGray))),
          );
        }

        return Column(
          children: messages.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _buildChatMessage(data);
          }).toList(),
        );
      },
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> data) {
    final sender = data['sender'] ?? 'User';
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
    final isMe = sender == progress.userName || (sender == 'Teacher' && progress.isTeacherMode);
    
    final timestamp = data['timestamp'] as Timestamp?;
    final timeStr = timestamp != null 
        ? "${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}" 
        : 'now';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primary : Colors.white,
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
                sender,
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primary),
              ),
            Text(
              data['message'] ?? '',
              style: GoogleFonts.notoSansTamil(
                color: isMe ? Colors.white : AppTheme.textDark,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeStr,
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
              maxLines: 1,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'இங்கே கேட்கவும்... (Ask something...)',
                hintStyle: GoogleFonts.notoSansTamil(fontSize: 14),
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                filled: true,
                fillColor: AppTheme.offWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              final message = _msgController.text.trim();
              if (message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message cannot be empty!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (message.length > 500) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message is too long (max 500 characters)'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              final sender = progress.isTeacherMode ? 'Teacher' : progress.userName;
              await _firestore.addMessage(sender, message);
              _msgController.clear();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
