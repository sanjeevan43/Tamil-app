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

class _ClassroomConnectScreenState extends State<ClassroomConnectScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _msgController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<EnhancedProgressProvider>(context);
    final isTeacher = progress.isTeacherMode;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.secondary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text('வகுப்பறை', style: GoogleFonts.notoSansTamil(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.secondary)),
            Text('CLASSROOM', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textGray, letterSpacing: 2)),
          ],
        ),
        centerTitle: true,
        actions: [
          if (isTeacher)
            IconButton(
              onPressed: () => _showAddMemberDialog(context),
              icon: const Icon(Icons.person_add_rounded, color: AppTheme.primary),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textGray,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800),
          unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Members'),
            Tab(text: 'Tasks'),
            Tab(text: 'Chat'),
            Tab(text: 'Notices'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMembersTab(isTeacher),
          _buildTasksTab(isTeacher),
          _buildChatTab(progress),
          _buildNoticesTab(isTeacher, progress),
        ],
      ),
    );
  }

  // ===== TAB 1: MEMBERS =====
  Widget _buildMembersTab(bool isTeacher) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.getClassroomMembersStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final members = snapshot.data!.docs;

        return ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            // Add Member button for teachers
            if (isTeacher)
              GestureDetector(
                onTap: () => _showAddMemberDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.white),
                      const SizedBox(width: 12),
                      Text('Add Member', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.white)),
                    ],
                  ),
                ),
              ),

            // Member count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.topoSilver),
              ),
              child: Row(
                children: [
                  const Icon(Icons.groups_rounded, color: AppTheme.secondary, size: 20),
                  const SizedBox(width: 12),
                  Text('${members.length} members', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.secondary)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('Online', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.success)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (members.isEmpty)
              _buildEmptyState(Icons.people_outline_rounded, 'No members yet', 'Add students or teachers to the classroom'),

            // Member list
            ...members.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final role = data['role'] ?? 'student';
              final isTeacherMember = role == 'teacher';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isTeacherMember ? AppTheme.primary.withOpacity(0.2) : AppTheme.topoSilver),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: isTeacherMember ? AppTheme.primary.withOpacity(0.1) : AppTheme.topoLight,
                      child: Icon(
                        isTeacherMember ? Icons.school_rounded : Icons.person_rounded,
                        color: isTeacherMember ? AppTheme.primary : AppTheme.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['displayName'] ?? data['name'] ?? 'Unknown', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.secondary)),
                          Row(
                            children: [
                              if (isTeacherMember)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4)),
                                  child: Text('TEACHER', style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.white)),
                                ),
                              Flexible(
                                child: Text(data['email'] ?? '', style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textGray), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isTeacher)
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline_rounded, color: AppTheme.primary.withOpacity(0.5), size: 20),
                        onPressed: () => _confirmRemoveMember(doc.id, data['name'] ?? 'this member'),
                      ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // ===== TAB 2: TASKS =====
  Widget _buildTasksTab(bool isTeacher) {
    return Column(
      children: [
        if (isTeacher)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: GestureDetector(
              onTap: () => _showAddTaskDialog(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.warning, AppTheme.warning.withOpacity(0.7)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppTheme.warning.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_task_rounded, color: AppTheme.white),
                    const SizedBox(width: 12),
                    Text('Create New Task', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.white)),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.getTasksStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final tasks = snapshot.data!.docs;

              if (tasks.isEmpty) {
                return _buildEmptyState(Icons.assignment_turned_in_rounded, 'No tasks yet', isTeacher ? 'Create tasks for your students' : 'No homework right now!');
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final data = tasks[index].data() as Map<String, dynamic>;
                  final type = data['type'] ?? 'Task';
                  final isQuiz = type == 'Quiz';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.topoSilver),
                    ),
                    child: ListTile(
                      onTap: isQuiz ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen())) : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isQuiz ? AppTheme.primary : AppTheme.warning).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(isQuiz ? Icons.quiz_rounded : Icons.assignment_rounded, color: isQuiz ? AppTheme.primary : AppTheme.warning),
                      ),
                      title: Text(data['title'] ?? 'Untitled', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.secondary)),
                      subtitle: Text(type, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textGray)),
                      trailing: isQuiz
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text('START', style: GoogleFonts.outfit(color: AppTheme.primary, fontWeight: FontWeight.w900, fontSize: 10)),
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ===== TAB 3: CHAT =====
  Widget _buildChatTab(EnhancedProgressProvider progress) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.getDiscussionsStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final messages = snapshot.data!.docs;

              if (messages.isEmpty) {
                return _buildEmptyState(Icons.forum_outlined, 'No messages yet', 'Be the first to say Vanakkam!');
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                reverse: true,
                physics: const BouncingScrollPhysics(),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final data = messages[index].data() as Map<String, dynamic>;
                  return _buildChatMessage(data, progress);
                },
              );
            },
          ),
        ),
        _buildMessageInput(progress),
      ],
    );
  }

  // ===== TAB 4: NOTICES =====
  Widget _buildNoticesTab(bool isTeacher, EnhancedProgressProvider progress) {
    return Column(
      children: [
        if (isTeacher)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: GestureDetector(
              onTap: () => _showAddAnnouncementDialog(context, progress),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.secondary, AppTheme.secondary.withOpacity(0.7)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppTheme.secondary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.campaign_rounded, color: AppTheme.white),
                    const SizedBox(width: 12),
                    Text('Post Announcement', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.white)),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.getAnnouncementsStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final announcements = snapshot.data!.docs;

              if (announcements.isEmpty) {
                return _buildEmptyState(Icons.campaign_outlined, 'No announcements', 'Important notices will appear here');
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final data = announcements[index].data() as Map<String, dynamic>;
                  final timestamp = data['createdAt'] as Timestamp?;
                  final timeStr = timestamp != null
                      ? "${timestamp.toDate().day}/${timestamp.toDate().month} at ${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}"
                      : 'just now';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.secondary.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppTheme.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.campaign_rounded, color: AppTheme.secondary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['title'] ?? '', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.secondary)),
                                  Text('${data['sender'] ?? 'Teacher'} · $timeStr', style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textGray)),
                                ],
                              ),
                            ),
                            if (isTeacher)
                              IconButton(
                                icon: Icon(Icons.delete_outline_rounded, color: AppTheme.primary.withOpacity(0.5), size: 20),
                                onPressed: () => _firestore.deleteAnnouncement(announcements[index].id),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(data['message'] ?? '', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSlate, height: 1.5)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ===== SHARED WIDGETS =====
  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppTheme.topoSilver),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.secondary)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textGray)),
        ],
      ),
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> data, EnhancedProgressProvider progress) {
    final sender = data['sender'] ?? 'User';
    final isMe = sender == progress.userName || (sender == 'Teacher' && progress.isTeacherMode);
    final isTeacher = sender == 'Teacher';

    final timestamp = data['timestamp'] as Timestamp?;
    final timeStr = timestamp != null
        ? "${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}"
        : 'now';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMe && isTeacher)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4)),
                    child: Text('TEACHER', style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.white)),
                  ),
                Text(isMe ? 'You' : sender, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: isTeacher ? AppTheme.primary : AppTheme.textGray)),
                const SizedBox(width: 8),
                Text(timeStr, style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.topoSilver)),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primary : AppTheme.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                border: isMe ? null : Border.all(color: AppTheme.topoSilver),
              ),
              child: Text(
                data['message'] ?? '',
                style: GoogleFonts.outfit(color: isMe ? AppTheme.white : AppTheme.secondary, fontSize: 14, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(EnhancedProgressProvider progress) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: AppTheme.textDark.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              maxLines: 1,
              maxLength: 500,
              style: GoogleFonts.outfit(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: GoogleFonts.outfit(fontSize: 14, color: AppTheme.topoSilver),
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                filled: true,
                fillColor: AppTheme.offWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              final message = _msgController.text.trim();
              if (message.isEmpty) return;
              final sender = progress.isTeacherMode ? 'Teacher' : progress.userName;
              await _firestore.addMessage(sender, message);
              _msgController.clear();
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.send_rounded, color: AppTheme.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ===== DIALOGS =====
  void _showAddMemberDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String role = 'student';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text('Add Member', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.secondary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: GoogleFonts.outfit(),
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person_rounded),
                  filled: true,
                  fillColor: AppTheme.offWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                style: GoogleFonts.outfit(),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_rounded),
                  filled: true,
                  fillColor: AppTheme.offWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Role: ', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppTheme.secondary)),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: Text('Student', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12)),
                    selected: role == 'student',
                    selectedColor: AppTheme.primary.withOpacity(0.2),
                    onSelected: (_) => setDialogState(() => role = 'student'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Teacher', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12)),
                    selected: role == 'teacher',
                    selectedColor: AppTheme.primary.withOpacity(0.2),
                    onSelected: (_) => setDialogState(() => role = 'teacher'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textGray)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                if (name.isEmpty || email.isEmpty) return;
                _firestore.addClassroomMember(email, name, role);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name added as $role!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('ADD', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveMember(String memberId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Remove $name?', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.primary)),
        content: Text('This will remove them from the classroom.', style: GoogleFonts.outfit(color: AppTheme.textGray)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textGray)),
          ),
          ElevatedButton(
            onPressed: () {
              _firestore.removeClassroomMember(memberId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: Text('REMOVE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.white)),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    String type = 'Task';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text('New Task', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.secondary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: GoogleFonts.outfit(),
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  prefixIcon: const Icon(Icons.assignment_rounded),
                  filled: true,
                  fillColor: AppTheme.offWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Type: ', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppTheme.secondary)),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: Text('Task', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12)),
                    selected: type == 'Task',
                    selectedColor: AppTheme.warning.withOpacity(0.2),
                    onSelected: (_) => setDialogState(() => type = 'Task'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Quiz', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12)),
                    selected: type == 'Quiz',
                    selectedColor: AppTheme.primary.withOpacity(0.2),
                    onSelected: (_) => setDialogState(() => type = 'Quiz'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textGray)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                _firestore.addTask({'title': titleController.text.trim(), 'type': type});
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text('CREATE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAnnouncementDialog(BuildContext context, EnhancedProgressProvider progress) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('New Announcement', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.secondary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: GoogleFonts.outfit(),
              decoration: InputDecoration(
                labelText: 'Title',
                prefixIcon: const Icon(Icons.title_rounded),
                filled: true,
                fillColor: AppTheme.offWhite,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              style: GoogleFonts.outfit(),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message',
                prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 40), child: Icon(Icons.message_rounded)),
                filled: true,
                fillColor: AppTheme.offWhite,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textGray)),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              _firestore.addAnnouncement(
                titleController.text.trim(),
                messageController.text.trim(),
                progress.userName,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: Text('POST', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.white)),
          ),
        ],
      ),
    );
  }
}
