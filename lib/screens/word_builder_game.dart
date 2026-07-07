import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../constants/app_theme.dart';
import '../services/audio_service.dart';
import '../services/game_logic.dart';
import '../providers/enhanced_progress_provider.dart';
import '../widgets/premium_animations.dart';

class WordBuilderGame extends StatefulWidget {
  final String difficulty;
  const WordBuilderGame({super.key, this.difficulty = 'Easy'});

  @override
  State<WordBuilderGame> createState() => _WordBuilderGameState();
}

class _WordBuilderGameState extends State<WordBuilderGame>
    with TickerProviderStateMixin {
  String _targetWord = '';
  String _english = '';
  String _emoji = '';
  List<String> _scrambledLetters = [];
  List<String> _userAnswer = [];
  int _score = 0;
  int _round = 1;
  final int _maxRounds = 8;
  bool _showingResult = false;
  bool _lastWasWrong = false;

  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _generateWord();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _generateWord() {
    final wordData = GameLogic.generateWordBuilderRound(difficulty: widget.difficulty);
    setState(() {
      _targetWord = wordData['word']!;
      _english = wordData['english']!;
      _emoji = wordData['emoji'] ?? '📝';
      _scrambledLetters = List<String>.from(wordData['scrambled'] as List);
      _userAnswer = [];
      _showingResult = false;
      _lastWasWrong = false;
    });
  }

  void _addLetter(String letter, int index) {
    if (_showingResult) return;
    if (_userAnswer.length >= _targetWord.characters.length) return;
    setState(() {
      _userAnswer.add(letter);
      _scrambledLetters.removeAt(index);
      _lastWasWrong = false;
    });
    _checkAnswer();
  }

  void _removeLetter(int index) {
    if (_showingResult) return;
    setState(() {
      _scrambledLetters.add(_userAnswer[index]);
      _userAnswer.removeAt(index);
      _lastWasWrong = false;
    });
  }

  void _clearAll() {
    if (_showingResult) return;
    setState(() {
      _scrambledLetters.addAll(_userAnswer);
      _userAnswer = [];
      _lastWasWrong = false;
    });
  }

  void _checkAnswer() {
    if (_userAnswer.length != _targetWord.characters.length) return;

    final builtWord = _userAnswer.join();
    if (builtWord == _targetWord) {
      setState(() {
        _showingResult = true;
        _score += 20;
        _lastWasWrong = false;
      });
      Provider.of<EnhancedProgressProvider>(context, listen: false).addQuizScore(20);
      AudioService.playWord(_targetWord);
      _bounceController.forward(from: 0);
      _showSuccess();
    } else {
      setState(() => _lastWasWrong = true);
      _shakeController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && _lastWasWrong) {
          setState(() {
            _scrambledLetters = _targetWord.characters.toList()..shuffle(Random());
            _userAnswer = [];
            _showingResult = false;
            _lastWasWrong = false;
          });
        }
      });
    }
  }

  void _showSuccess() {
    Future.delayed(const Duration(milliseconds: 300), () {
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
                Text(_emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  _targetWord,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                  ),
                ),
                const SizedBox(height: 4),
                Text(_english, style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textGray)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFD93D), size: 20),
                      const SizedBox(width: 6),
                      Text('+20 pts', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.success)),
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
                        _generateWord();
                      } else {
                        _showFinalResults();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text(
                      _round < _maxRounds ? 'Next Word →' : 'See Results',
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

  void _showFinalResults() {
    final percent = (_score / (_maxRounds * 20) * 100).round();
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
              Text('Word Master!',
                style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              const SizedBox(height: 8),
              Text('$_score / ${_maxRounds * 20} pts',
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
                        _generateWord();
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

  void _skipWord() {
    if (_round < _maxRounds) {
      setState(() => _round++);
      _generateWord();
    } else {
      _showFinalResults();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            title: Text('Word Builder',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFD93D), size: 18),
                    const SizedBox(width: 4),
                    Text('$_score', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                  ],
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: ClipRRect(
                child: LinearProgressIndicator(
                  value: _round / _maxRounds,
                  backgroundColor: AppTheme.topoSilver,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                  minHeight: 4,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                children: [
                  // Round Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.topoLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.topoSilver),
                        ),
                        child: Text(
                          'Word $_round / $_maxRounds  •  ${widget.difficulty}',
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSlate),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Clue Card
                  FadeInSlide(
                    direction: SlideDirection.down,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.secondary, AppTheme.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(_emoji, style: const TextStyle(fontSize: 52)),
                          const SizedBox(height: 10),
                          Text(
                            _english,
                            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Build the Tamil word!',
                            style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.white.withOpacity(0.75)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Answer Tray Label
                  Row(
                    children: [
                      Text(
                        'YOUR ANSWER',
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSlate, letterSpacing: 1),
                      ),
                      const Spacer(),
                      if (_userAnswer.isNotEmpty)
                        GestureDetector(
                          onTap: _clearAll,
                          child: Row(
                            children: [
                              const Icon(Icons.refresh_rounded, size: 14, color: AppTheme.textGray),
                              const SizedBox(width: 4),
                              Text('Clear', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textGray)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Answer Slots
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: _lastWasWrong ? Offset(_shakeAnimation.value, 0) : Offset.zero,
                      child: child,
                    ),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 80),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _lastWasWrong
                            ? const Color(0xFFFFEBEE)
                            : _userAnswer.isNotEmpty
                                ? const Color(0xFFF0F7FF)
                                : AppTheme.topoLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _lastWasWrong
                              ? AppTheme.error.withOpacity(0.4)
                              : _userAnswer.isNotEmpty
                                  ? AppTheme.secondary.withOpacity(0.3)
                                  : AppTheme.topoSilver,
                          width: 1.5,
                        ),
                      ),
                      child: _userAnswer.isEmpty
                          ? Center(
                              child: Text(
                                'Tap letters below to build the word',
                                style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textGray),
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: _userAnswer.asMap().entries.map((entry) {
                                return GestureDetector(
                                  onTap: () => _removeLetter(entry.key),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: _lastWasWrong ? AppTheme.error : AppTheme.secondary,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_lastWasWrong ? AppTheme.error : AppTheme.secondary).withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        entry.value,
                                        style: TextStyle(
                                          fontSize: 26,
                                          color: AppTheme.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ),

                  if (_lastWasWrong) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.error),
                        const SizedBox(width: 6),
                        Text('Not quite! Try a different order.',
                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.error)),
                      ],
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Letter Tiles
                  Text(
                    'TAP TO ADD LETTERS',
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSlate, letterSpacing: 1),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _scrambledLetters.asMap().entries.map((entry) {
                      return FadeInSlide(
                        direction: SlideDirection.up,
                        delay: Duration(milliseconds: 30 * entry.key),
                        child: SpringyTap(
                          onTap: () => _addLetter(entry.value, entry.key),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 26,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Skip Button
                  TextButton.icon(
                    onPressed: _skipWord,
                    icon: const Icon(Icons.skip_next_rounded, color: AppTheme.textGray, size: 18),
                    label: Text('Skip this word', style: GoogleFonts.outfit(color: AppTheme.textGray, fontSize: 13, fontWeight: FontWeight.w700)),
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
