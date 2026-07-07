import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/audio_service.dart';
import '../services/game_logic.dart';
import '../providers/enhanced_progress_provider.dart';
import '../widgets/premium_animations.dart';

class LetterHuntGame extends StatefulWidget {
  final String difficulty;
  const LetterHuntGame({super.key, this.difficulty = 'Easy'});

  @override
  State<LetterHuntGame> createState() => _LetterHuntGameState();
}

class _LetterHuntGameState extends State<LetterHuntGame>
    with TickerProviderStateMixin {
  late Map<String, dynamic> _currentRound;
  int _score = 0;
  int _round = 1;
  final int _maxRounds = 10;
  bool _isAnswered = false;
  int? _selectedIndex;
  bool _isCorrect = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  static const _difficultyColors = {
    'Easy': Color(0xFF4CAF50),
    'Medium': Color(0xFFFF9800),
    'Hard': Color(0xFFF44336),
    'Expert': Color(0xFF9C27B0),
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _generateRound();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _generateRound() {
    setState(() {
      _currentRound = GameLogic.generateLetterHuntRoundWithDifficulty(widget.difficulty);
      _isAnswered = false;
      _selectedIndex = null;
      _isCorrect = false;
    });
    AudioService.playLetter(_currentRound['targetLetter']);
  }

  void _checkAnswer(int selectedIndex) {
    if (_isAnswered) return;
    final correct = selectedIndex == _currentRound['correctIndex'];
    setState(() {
      _isAnswered = true;
      _selectedIndex = selectedIndex;
      _isCorrect = correct;
    });

    if (correct) {
      setState(() => _score += 10);
      Provider.of<EnhancedProgressProvider>(context, listen: false).addQuizScore(10);
    } else {
      _shakeController.forward(from: 0);
    }

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (correct) {
        if (_round < _maxRounds) {
          setState(() => _round++);
          _generateRound();
        } else {
          _showResults();
        }
      } else {
        setState(() {
          _isAnswered = false;
          _selectedIndex = null;
          _isCorrect = false;
        });
      }
    });
  }

  void _showResults() {
    Provider.of<EnhancedProgressProvider>(context, listen: false).addQuizScore(_score);
    final percent = (_score / (_maxRounds * 10) * 100).round();
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
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10)),
            ],
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
                child: const Center(child: Text('🎉', style: TextStyle(fontSize: 36))),
              ),
              const SizedBox(height: 20),
              Text('Game Complete!',
                style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              const SizedBox(height: 8),
              Text('$_score / ${_maxRounds * 10} pts',
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
                        _generateRound();
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

  Color get _difficultyColor => _difficultyColors[widget.difficulty] ?? AppTheme.primary;

  @override
  Widget build(BuildContext context) {
    final options = _currentRound['options'] as List;
    final correctIndex = _currentRound['correctIndex'] as int;
    final targetLetter = _currentRound['targetLetter'] as String;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Gradient Header App Bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: _difficultyColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
              ),
            ),
            actions: [
              // Score pill
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFD93D), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$_score',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_difficultyColor, _difficultyColor.withOpacity(0.75)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Round progress
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Round $_round / $_maxRounds',
                                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white70),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.difficulty.toUpperCase(),
                                    style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _round / _maxRounds,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pulsing Target Letter Card
                      GestureDetector(
                        onTap: () => AudioService.playLetter(targetLetter),
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) => Transform.scale(
                            scale: _pulseAnimation.value,
                            child: child,
                          ),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: AppTheme.kidStyleCard(
                              color: Colors.white,
                              borderWidth: 4,
                              borderRadius: 50,
                              shadowColor: Colors.black.withOpacity(0.15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  targetLetter,
                                  style: TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    color: _difficultyColor,
                                    fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.touch_app_rounded, color: Colors.white60, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Tap letter to hear it • Find the matching letter below',
                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Answer Options Grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final letter = options[index] as String;
                  final isSelected = _selectedIndex == index;
                  final isCorrectAnswer = index == correctIndex;

                  Color cardColor = AppTheme.white;
                  Color borderColor = AppTheme.topoSilver;
                  Color letterColor = AppTheme.textDark;
                  Widget? overlay;

                  if (_isAnswered && isSelected && _isCorrect) {
                    cardColor = const Color(0xFFE8F5E9);
                    borderColor = AppTheme.success;
                    letterColor = AppTheme.success;
                    overlay = const Positioned(
                      top: 6, right: 6,
                      child: Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 18),
                    );
                  } else if (_isAnswered && isSelected && !_isCorrect) {
                    cardColor = const Color(0xFFFFEBEE);
                    borderColor = AppTheme.error;
                    letterColor = AppTheme.error;
                    overlay = const Positioned(
                      top: 6, right: 6,
                      child: Icon(Icons.cancel_rounded, color: Color(0xFFF44336), size: 18),
                    );
                  } else if (_isAnswered && !_isCorrect && isCorrectAnswer) {
                    cardColor = const Color(0xFFE8F5E9);
                    borderColor = AppTheme.success;
                    letterColor = AppTheme.success;
                  }

                  return FadeInSlide(
                    direction: SlideDirection.up,
                    delay: Duration(milliseconds: 40 * index),
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: (_isAnswered && isSelected && !_isCorrect)
                            ? Offset(_shakeAnimation.value, 0)
                            : Offset.zero,
                        child: child,
                      ),
                      child: SpringyTap(
                        onTap: _isAnswered ? null : () => _checkAnswer(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: AppTheme.kidStyleCard(
                            color: borderColor,
                            borderWidth: 3,
                            borderRadius: 20,
                          ).copyWith(color: cardColor),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  letter,
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: letterColor,
                                    fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                                  ),
                                ),
                              ),
                              if (overlay != null) overlay,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: options.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
