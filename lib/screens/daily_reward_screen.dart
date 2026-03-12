import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';

class DailyRewardScreen extends StatefulWidget {
  const DailyRewardScreen({super.key});

  @override
  State<DailyRewardScreen> createState() => _DailyRewardScreenState();
}

class _DailyRewardScreenState extends State<DailyRewardScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  bool _hasSpun = false;
  bool _isSpinning = false;
  int _rewardIndex = 0;

  final List<Map<String, dynamic>> _rewards = [
    {'emoji': '💎', 'label': '10 Coins', 'coins': 10, 'color': const Color(0xFF00B0FF)},
    {'emoji': '⭐', 'label': '5 Stars', 'stars': 5, 'color': Colors.amber},
    {'emoji': '🔥', 'label': 'Streak Shield', 'coins': 0, 'color': Colors.orange},
    {'emoji': '💰', 'label': '25 Coins', 'coins': 25, 'color': const Color(0xFF6200EA)},
    {'emoji': '🏆', 'label': '10 Stars', 'stars': 10, 'color': AppTheme.primary},
    {'emoji': '🎁', 'label': '50 Coins', 'coins': 50, 'color': Colors.green},
    {'emoji': '🌟', 'label': '3 Stars', 'stars': 3, 'color': Colors.teal},
    {'emoji': '🎯', 'label': '2x XP Boost', 'coins': 0, 'color': Colors.pink},
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          _hasSpun = true;
        });
        _bounceController.forward(from: 0);
        _applyReward();
      }
    });
  }

  void _spin() {
    if (_isSpinning || _hasSpun) return;
    setState(() => _isSpinning = true);
    _rewardIndex = math.Random().nextInt(_rewards.length);
    final targetAngle = (5 * 2 * math.pi) + (_rewardIndex / _rewards.length * 2 * math.pi);
    _spinController.duration = const Duration(seconds: 4);
    _spinController.forward(from: 0);
  }

  void _applyReward() {
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
    final reward = _rewards[_rewardIndex];
    if (reward.containsKey('coins') && (reward['coins'] as int) > 0) {
      progress.addCoins(reward['coins'] as int);
    }
    if (reward.containsKey('stars') && (reward['stars'] as int) > 0) {
      progress.addStars(reward['stars'] as int);
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.secondary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'DAILY REWARD',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.secondary, letterSpacing: 2, fontSize: 14),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Row(
                children: [
                  const Text('🎰', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Spin to Win!', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text('One free spin every day', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Spin Wheel
            AnimatedBuilder(
              animation: _spinController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _spinController.value * 10 * math.pi * (1 - _spinController.value * 0.3),
                  child: child,
                );
              },
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppTheme.primary, width: 6),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10)),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: List.generate(_rewards.length, (index) {
                    final angle = (index / _rewards.length) * 2 * math.pi - math.pi / 2;
                    final radius = 100.0;
                    return Positioned(
                      left: 140 + radius * math.cos(angle) - 20,
                      top: 140 + radius * math.sin(angle) - 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_rewards[index]['emoji'] as String, style: const TextStyle(fontSize: 28)),
                          Text(
                            _rewards[index]['label'] as String,
                            style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w800, color: AppTheme.secondary),
                          ),
                        ],
                      ),
                    );
                  })
                    ..add(
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                              boxShadow: [
                                BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 10),
                              ],
                            ),
                            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                    ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Pointer
            Icon(Icons.arrow_drop_up_rounded, size: 48, color: AppTheme.primary),
            const SizedBox(height: 20),
            // Result
            if (_hasSpun)
              ScaleTransition(
                scale: _bounceAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.amber, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 20),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(_rewards[_rewardIndex]['emoji'] as String, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(
                        'You won ${_rewards[_rewardIndex]['label']}!',
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.secondary),
                      ),
                      const SizedBox(height: 4),
                      Text('Come back tomorrow for more!', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textGray)),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            // Spin Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: GestureDetector(
                onTap: _spin,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _hasSpun
                          ? [Colors.grey, Colors.grey.shade600]
                          : [AppTheme.primary, AppTheme.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: _hasSpun ? [] : [
                      BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _hasSpun ? 'COME BACK TOMORROW' : (_isSpinning ? 'SPINNING...' : 'SPIN THE WHEEL 🎰'),
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                    ),
                  ),
                ),
              ),
            ),
            // Weekly Streak
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _buildWeekStreak(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekStreak() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now().weekday - 1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.topoSilver),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final isDone = index <= today;
          return Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDone ? AppTheme.primary : AppTheme.topoLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDone ? AppTheme.primary : AppTheme.topoSilver, width: 2),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text('${index + 1}', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textGray)),
                ),
              ),
              const SizedBox(height: 4),
              Text(days[index], style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w700, color: isDone ? AppTheme.primary : AppTheme.textGray)),
            ],
          );
        }),
      ),
    );
  }
}
