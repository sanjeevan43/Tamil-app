import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/game_logic.dart';
import '../providers/enhanced_progress_provider.dart';
import '../widgets/premium_animations.dart';

class SentenceBuilderGame extends StatefulWidget {
  final String difficulty;
  const SentenceBuilderGame({super.key, this.difficulty = 'Easy'});

  @override
  State<SentenceBuilderGame> createState() => _SentenceBuilderGameState();
}

class _SentenceBuilderGameState extends State<SentenceBuilderGame>
    with SingleTickerProviderStateMixin {
  late Map<String, dynamic> _currentRound;
  List<String> _userSentence = [];
  int _score = 0;
  int _round = 1;
  final int _maxRounds = 8;
  bool _showingResult = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _generateSentence();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _generateSentence() {
    setState(() {
      _currentRound = GameLogic.generateSentenceBuilderRound(difficulty: widget.difficulty);
      _userSentence = [];
      _showingResult = false;
    });
  }

  void _addWord(String word, int index) {
    final correctOrder = _currentRound['correctOrder'] as List;
    if (_userSentence.length >= correctOrder.length) return;
    setState(() {
      _userSentence.add(word);
      (_currentRound['words'] as List).removeAt(index);
    });
    _checkSentence();
  }

  void _removeWord(int index) {
    setState(() {
      (_currentRound['words'] as List).add(_userSentence[index]);
      _userSentence.removeAt(index);
    });
  }

  void _clearSentence() {
    final allWords = List<String>.from(_userSentence);
    setState(() {
      (_currentRound['words'] as List).addAll(allWords);
      _userSentence = [];
    });
  }

  void _checkSentence() {
    final correctOrder = _currentRound['correctOrder'] as List;
    if (_userSentence.length != correctOrder.length) return;

    final built = _userSentence.join(' ');
    final correct = _currentRound['correctSentence'] as String;

    if (built == correct) {
      setState(() {
        _score += 25;
        _showingResult = true;
      });
      Provider.of<EnhancedProgressProvider>(context, listen: false)
          .addRewards(coins: 20, stars: 2, missionId: 'game_hero');
      _showSuccess();
    } else {
      // Wrong — shake and auto-reset
      _shakeController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) _clearSentence();
      });
    }
  }

  void _showSuccess() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 25, offset: const Offset(0, 8))],
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text('✅', style: TextStyle(fontSize: 32))),
                ),
                const SizedBox(height: 16),
                Text('Perfect Sentence!',
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
                  ),
                  child: Text(
                    _currentRound['correctSentence'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary,
                      fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentRound['english'] as String? ?? '',
                  style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textGray),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFD93D), size: 20),
                      const SizedBox(width: 6),
                      Text('+25 pts', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (_round < _maxRounds) {
                        setState(() => _round++);
                        _generateSentence();
                      } else {
                        _showResults();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text(
                      _round < _maxRounds ? 'Next Sentence →' : 'See Results',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showResults() {
    final percent = (_score / (_maxRounds * 25) * 100).round();
    final stars = percent >= 90 ? 3 : percent >= 60 ? 2 : 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 25, offset: const Offset(0, 8))],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFFFD93D), Color(0xFFFF7A00)]),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Icon(Icons.emoji_events_rounded, color: Colors.white, size: 40)),
              ),
              const SizedBox(height: 20),
              Text('Sentence Master!',
                style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              const SizedBox(height: 8),
              Text('$_score / ${_maxRounds * 25} pts',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: i < stars ? const Color(0xFFFFD93D) : AppTheme.topoSilver,
                    size: 36,
                  ),
                )),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.topoSilver),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Exit', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppTheme.textGray)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _score = 0;
                          _round = 1;
                        });
                        _generateSentence();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text('Play Again', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = _currentRound['words'] as List;
    final correctOrder = _currentRound['correctOrder'] as List;
    final english = _currentRound['english'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.topoLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.topoSilver),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark, size: 20),
                ),
              ),
            ),
            title: Text('Sentence Builder',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF26A69A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFD93D), size: 18),
                    const SizedBox(width: 4),
                    Text('$_score', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w900, color: const Color(0xFF26A69A))),
                  ],
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: LinearProgressIndicator(
                value: _round / _maxRounds,
                backgroundColor: AppTheme.topoSilver,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF26A69A)),
                minHeight: 4,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Round Indicator
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.topoLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.topoSilver),
                      ),
                      child: Text(
                        'Sentence $_round / $_maxRounds  •  ${widget.difficulty}',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSlate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Clue Card
                  FadeInSlide(
                    direction: SlideDirection.down,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF26A69A), Color(0xFF00897B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF26A69A).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: Colors.white70, size: 20),
                          const SizedBox(height: 6),
                          Text(
                            english,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Arrange the Tamil words in order',
                            style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.white.withOpacity(0.75)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sentence Tray Label
                  Row(
                    children: [
                      Text(
                        'YOUR SENTENCE',
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSlate, letterSpacing: 1),
                      ),
                      const Spacer(),
                      if (_userSentence.isNotEmpty && !_showingResult)
                        GestureDetector(
                          onTap: _clearSentence,
                          child: Row(
                            children: [
                              const Icon(Icons.refresh_rounded, size: 14, color: AppTheme.textGray),
                              const SizedBox(width: 4),
                              Text('Reset', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textGray)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Sentence Tray
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: child,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 80),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _userSentence.isEmpty
                            ? AppTheme.topoLight
                            : const Color(0xFFF0FAF9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _userSentence.isEmpty
                              ? AppTheme.topoSilver
                              : const Color(0xFF26A69A).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: _userSentence.isEmpty
                          ? Center(
                              child: Text(
                                'Tap words below to form a sentence',
                                style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textGray),
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _userSentence.asMap().entries.map((entry) {
                                return GestureDetector(
                                  onTap: () => _removeWord(entry.key),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF26A69A), Color(0xFF00897B)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF26A69A).withOpacity(0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          entry.value,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.close_rounded, color: Colors.white60, size: 12),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ),

                  // Progress dots
                  if (correctOrder.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(correctOrder.length, (i) {
                        final filled = i < _userSentence.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: filled ? 20 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: filled ? const Color(0xFF26A69A) : AppTheme.topoSilver,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Word Tiles
                  Text(
                    'AVAILABLE WORDS',
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSlate, letterSpacing: 1),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: words.asMap().entries.map((entry) {
                      return FadeInSlide(
                        direction: SlideDirection.up,
                        delay: Duration(milliseconds: 40 * entry.key),
                        child: SpringyTap(
                          onTap: () => _addWord(entry.value as String, entry.key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF26A69A).withOpacity(0.2), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF26A69A).withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              entry.value as String,
                              style: TextStyle(
                                fontSize: 18,
                                color: const Color(0xFF26A69A),
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
