import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../providers/enhanced_progress_provider.dart';
import '../constants/app_theme.dart';

class CommunityForumScreen extends StatefulWidget {
  const CommunityForumScreen({super.key});

  @override
  State<CommunityForumScreen> createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<CommunityForumScreen> {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildSearchBox(),
          _buildQuestionsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddQuestionDialog(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_comment_rounded, color: AppTheme.white),
        label: Text('ASK QUESTION', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.white)),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.secondary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          'COMMUNITY Q&A',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.white, fontSize: 18, letterSpacing: 1),
        ),
        background: Stack(
          children: [
            Positioned(
              right: -50,
              top: -20,
              child: Icon(Icons.forum_rounded, size: 200, color: AppTheme.white.withValues(alpha: 0.05)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.topoSilver),
            boxShadow: [
              BoxShadow(color: AppTheme.textDark.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search questions...',
              hintStyle: GoogleFonts.outfit(color: AppTheme.textGray),
              border: InputBorder.none,
              icon: const Icon(Icons.search, color: AppTheme.textGray),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.getQuestionsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load questions',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textGray),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Firebase error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(color: AppTheme.textGray.withValues(alpha: 0.8), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Text('💬', style: TextStyle(fontSize: 64)),
                   const SizedBox(height: 16),
                   Text('No questions yet.', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textGray)),
                   Text('Be the first to ask!', style: GoogleFonts.outfit(color: AppTheme.textGray)),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                return _buildQuestionCard(docs[index].id, data);
              },
              childCount: docs.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionCard(String docId, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuestionDetailScreen(questionId: docId, questionData: data))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.topoSilver),
          boxShadow: [
            BoxShadow(color: AppTheme.textDark.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Text('❓', style: TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data['userName'] ?? 'Member',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textGray, letterSpacing: 1),
                  ),
                ),
                if (data['createdAt'] != null)
                   Text(
                     _formatTimestamp(data['createdAt'] as Timestamp),
                     style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textGray),
                   ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              data['title'] ?? '',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.secondary),
            ),
            const SizedBox(height: 8),
            Text(
              data['content'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSlate, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildStatIcon(Icons.forum_rounded, '${data['answersCount'] ?? 0} answers'),
                const SizedBox(width: 16),
                _buildStatIcon(Icons.thumb_up_alt_rounded, '${data['upvotes'] ?? 0} upvotes'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textGray),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGray)),
      ],
    );
  }

  void _showAddQuestionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text('Ask a Question', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.secondary)),
                 IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
               ],
             ),
             const SizedBox(height: 24),
             TextField(
               controller: titleController,
               decoration: InputDecoration(
                 hintText: 'Question Title...',
                 filled: true,
                 fillColor: AppTheme.offWhite,
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
               ),
               style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
             ),
             const SizedBox(height: 16),
             Expanded(
               child: TextField(
                 controller: contentController,
                 maxLines: 10,
                 decoration: InputDecoration(
                   hintText: 'Describe details...',
                   filled: true,
                   fillColor: AppTheme.offWhite,
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                 ),
                 style: GoogleFonts.outfit(),
               ),
             ),
             const SizedBox(height: 16),
             SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                      try {
                        await _firestore.addQuestion(
                          titleController.text,
                          contentController.text,
                          progress.userId ?? 'anonymous',
                          progress.userName,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Question posted!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('POST QUESTION', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.white)),
                ),
              ),
           ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class QuestionDetailScreen extends StatefulWidget {
  final String questionId;
  final Map<String, dynamic> questionData;
  const QuestionDetailScreen({super.key, required this.questionId, required this.questionData});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        elevation: 0,
        title: Text('ANSWERS', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.white, letterSpacing: 2, fontSize: 16)),
        iconTheme: const IconThemeData(color: AppTheme.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildQuestionDetail(),
                const SizedBox(height: 32),
                Text('ANSWERS', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textGray, letterSpacing: 2)),
                const SizedBox(height: 16),
                _buildAnswersList(),
              ],
            ),
          ),
          _buildAnswerInput(),
        ],
      ),
    );
  }

  Widget _buildQuestionDetail() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppTheme.textDark.withValues(alpha: 0.04), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppTheme.topoLight, shape: BoxShape.circle), child: const Center(child: Text('❓'))),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.questionData['userName'] ?? 'Member', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14)),
                  Text('ASKED QUESTION', style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textGray, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(widget.questionData['title'] ?? '', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, height: 1.2)),
          const SizedBox(height: 12),
          Text(widget.questionData['content'] ?? '', style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textSlate, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildAnswersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.getAnswersStream(widget.questionId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Error loading answers: ${snapshot.error}',
                style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        
        if (docs.isEmpty) {
          return Center(child: Text('No answers yet. Share your knowledge!', style: GoogleFonts.outfit(color: AppTheme.textGray)));
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.topoSilver.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       const CircleAvatar(radius: 12, backgroundColor: AppTheme.topoLight, child: Text('👤', style: TextStyle(fontSize: 10))),
                       const SizedBox(width: 8),
                       Text(data['userName'] ?? 'Member', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                       const Spacer(),
                        if (data['createdAt'] != null)
                           Text(_formatTimestamp(data['createdAt'] as Timestamp), style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textGray)),
                     ],
                   ),
                   const SizedBox(height: 12),
                   Text(data['content'] ?? '', style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textDark, height: 1.4)),
                 ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAnswerInput() {
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [BoxShadow(color: AppTheme.textDark.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppTheme.offWhite, borderRadius: BorderRadius.circular(20)),
              child: TextField(
                controller: _answerController,
                decoration: InputDecoration(hintText: 'Add an answer...', hintStyle: GoogleFonts.outfit(fontSize: 14), border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              if (_answerController.text.isNotEmpty) {
                try {
                  await _firestore.addAnswer(widget.questionId, _answerController.text, progress.userId ?? 'anonymous', progress.userName);
                  if (context.mounted) {
                    _answerController.clear();
                    FocusScope.of(context).unfocus();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              }
            },
            child: Container(
              width: 50,
              height: 50,
              decoration:  BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: AppTheme.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
