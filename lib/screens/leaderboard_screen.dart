import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildTopThree(context)),
          _buildListSection(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.secondary,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'LEADERBOARD',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2, fontSize: 16),
        ),
        background: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.secondary, AppTheme.primaryDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'GLOBAL RANKINGS',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopThree(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('progress.totalStars', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 250);
        final topDocs = snapshot.data!.docs;
        
        final List<Map<String, dynamic>> topThree = topDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final prog = data['progress'] as Map<String, dynamic>?;
          return {
            'displayName': data['displayName'] ?? 'User',
            'totalStars': prog?['totalStars'] ?? 0,
            'avatar': data['photoURL'] != null && data['photoURL'].isNotEmpty ? data['photoURL'] : '👤',
          };
        }).toList();

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (topThree.length >= 2) _buildPodium(topThree[1], '2nd', 120, Colors.grey.shade400),
              if (topThree.isNotEmpty) _buildPodium(topThree[0], '1st', 160, Colors.amber),
              if (topThree.length >= 3) _buildPodium(topThree[2], '3rd', 110, Colors.brown.shade400),
            ],
          ),
        );
      }
    );
  }

  Widget _buildPodium(Map<String, dynamic> user, String rank, double height, Color color) {
    String avatar = user['avatar'] ?? '👤';
    bool isUrl = avatar.startsWith('http');
    
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: ClipOval(
            child: isUrl 
              ? Image.network(avatar, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Text('👤', style: TextStyle(fontSize: 30))))
              : Center(child: Text(avatar, style: const TextStyle(fontSize: 40))),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: Text(
            user['displayName'] ?? '...',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: color.withOpacity(0.2), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rank,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: color, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.amber, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '${user['totalStars'] ?? 0}',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 11, color: AppTheme.textDark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('progress.totalStars', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        final users = snapshot.data!.docs;

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              return _buildRankingItem(index + 1, user);
            },
            childCount: users.length,
          ),
        );
      },
    );
  }

  Widget _buildRankingItem(int rank, Map<String, dynamic> user) {
    final prog = user['progress'] as Map<String, dynamic>?;
    final totalStars = prog?['totalStars'] ?? 0;
    final level = prog?['level'] ?? 1;
    final String avatar = user['photoURL'] ?? '👤';
    final bool isUrl = avatar.startsWith('http');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.topoSilver.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#$rank',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.textGray, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppTheme.topoLight, shape: BoxShape.circle),
            child: ClipOval(
              child: isUrl 
                ? Image.network(avatar, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Text('👤', style: TextStyle(fontSize: 20))))
                : Center(child: Text(avatar, style: const TextStyle(fontSize: 20))),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['displayName'] ?? 'Akaravalam Learner',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.secondary),
                ),
                Text(
                  'Expert Level $level',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textGray),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$totalStars',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.secondary, fontSize: 16),
                  ),
                ],
              ),
              Text(
                'STARS',
                style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.textGray, letterSpacing: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
