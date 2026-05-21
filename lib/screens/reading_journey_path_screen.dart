import '../constants/app_theme.dart';

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../data/level_game_data.dart';
import '../services/audio_service.dart';
import '../constants/tamil_data.dart';

class ReadingJourneyPathScreen extends StatefulWidget {
  final Map<String, dynamic> level;
  final Color stageColor;
  final Function(int stars) onComplete;

  const ReadingJourneyPathScreen({
    super.key,
    required this.level,
    required this.stageColor,
    required this.onComplete,
  });

  @override
  State<ReadingJourneyPathScreen> createState() => _ReadingJourneyPathScreenState();
}

class _ReadingJourneyPathScreenState extends State<ReadingJourneyPathScreen>
    with TickerProviderStateMixin {
  late List<Map<String, dynamic>> _rounds;
  int _currentRound = 0;
  int _correctAnswers = 0;
  int _totalRounds = 5;
  bool _isGameOver = false;
  bool _showFeedback = false;
  bool _lastAnswerCorrect = false;
  Timer? _timer;
  int _timeLeft = 60;
  int _lastPlayedRound = -1; // Track which round we last auto-played audio for
  late AnimationController _feedbackController;
  late ConfettiController _confettiController;

  // Match pairs state
  List<Map<String, dynamic>> _matchCards = [];
  int? _firstFlippedIndex;
  int? _secondFlippedIndex;
  final Set<int> _matchedIndices = {};
  int _matchPairsCorrect = 0;
  int _matchPairsTotal = 0;

  // Arrange state
  List<String> _arrangedItems = [];
  List<String> _availableItems = [];

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _initializeGame();
  }

  void _initializeGame() {
    final gameType = widget.level['gameType'] as String;
    _rounds = LevelGameData.generateRounds(gameType, _totalRounds);

    if (gameType == 'match_pairs' || gameType == 'memory_match') {
      _totalRounds = 1;
      if (_rounds.isNotEmpty) {
        _matchCards = List<Map<String, dynamic>>.from(_rounds[0]['pairs']);
        _matchPairsTotal = _rounds[0]['totalPairs'] as int;
      }
    }

    if (_rounds.isNotEmpty && _rounds[0]['type'] == 'arrange') {
      _setupArrangeRound();
    }

    _startTimer();
  }

  void _setupArrangeRound() {
    if (_currentRound < _rounds.length) {
      final round = _rounds[_currentRound];
      _arrangedItems = [];
      _availableItems = List<String>.from(round['scrambled']);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endGame();
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _isGameOver = true);
    
    // Play confetti if performance was good
    int stars;
    if (_rounds.isNotEmpty && _rounds[0]['type'] == 'match_pairs') {
      final ratio = _matchPairsCorrect / (_matchPairsTotal > 0 ? _matchPairsTotal : 1);
      stars = ratio >= 1.0 ? 3 : (ratio >= 0.5 ? 2 : 1);
    } else {
      final ratio = _correctAnswers / (_totalRounds > 0 ? _totalRounds : 1);
      stars = ratio >= 0.9 ? 3 : (ratio >= 0.6 ? 2 : 1);
    }

    if (stars >= 2) {
      _confettiController.play();
    }

    widget.onComplete(stars);
  }

  /// Play sound for the current round's content
  void _autoPlayRoundAudio() {
    if (_currentRound >= _rounds.length) return;
    if (_currentRound == _lastPlayedRound) return;
    _lastPlayedRound = _currentRound;

    final round = _rounds[_currentRound];
    final type = round['type'];

    if (type == 'multiple_choice') {
      // Auto-play the displayed letter or the correct answer word
      if (round['displayLetter'] != null) {
        AudioService.playLetter(round['displayLetter']);
      } else if (round['correct'] != null) {
        // For word-based multiple choice, speak the correct answer to teach
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) AudioService.playWord(round['correct'].toString());
        });
      }
    } else if (type == 'fill_blank') {
      // Play the full word so student hears what it should sound like
      if (round['word'] != null) {
        AudioService.playWord(round['word']);
      }
    } else if (type == 'arrange') {
      // Play the target word so student knows what they're building
      if (round['word'] != null) {
        AudioService.playWord(round['word']);
      }
    } else if (type == 'listen_choose') {
      // Handled separately in its widget
    } else if (type == 'listen_speak') {
      // Auto-play the word/sentence
      if (round['word'] != null) {
        AudioService.playWord(round['word']);
      }
    }
  }

  void _handleAnswer(dynamic selected) {
    if (_showFeedback) return;
    final round = _rounds[_currentRound];
    final isCorrect = selected == round['correct'];

    // Play the tapped option's sound so student hears the pronunciation
    AudioService.playLetter(selected.toString());

    setState(() {
      _showFeedback = true;
      _lastAnswerCorrect = isCorrect;
      if (isCorrect) _correctAnswers++;
    });

    _feedbackController.forward(from: 0);

    // After feedback, play reinforcement audio
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      if (isCorrect) {
        // Speak a random motivational quote
        const quotes = TamilData.motivationalQuotes;
        final quote = quotes[math.Random().nextInt(quotes.length)];
        AudioService.playWord(quote);
      } else {
        // Speak the correct answer to help them learn
        AudioService.playWord(round['correct'].toString());
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _showFeedback = false;
        _currentRound++;
        if (_currentRound >= _rounds.length) {
          _endGame();
        } else if (_rounds[_currentRound]['type'] == 'arrange') {
          _setupArrangeRound();
        }
      });
    });
  }

  void _handleArrangeSubmit() {
    final round = _rounds[_currentRound];
    final correct = List<String>.from(round['correct']);
    final isCorrect = _arrangedItems.join() == correct.join();

    // Play the correct word so student hears it
    AudioService.playWord(round['word']);

    setState(() {
      _showFeedback = true;
      _lastAnswerCorrect = isCorrect;
      if (isCorrect) _correctAnswers++;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _showFeedback = false;
        _currentRound++;
        if (_currentRound >= _rounds.length) {
          _endGame();
        } else {
          _setupArrangeRound();
        }
      });
    });
  }

  void _handleMatchPairsTap(int index) {
    if (_matchedIndices.contains(index)) return;
    if (_firstFlippedIndex == index) return;
    if (_secondFlippedIndex != null) return;

    // Play the sound of the card being flipped
    final card = _matchCards[index];
    final cardText = card['text'] as String;
    // Only play if it's a Tamil text (not emoji)
    if (card['type'] == 'tamil' || card['type'] == 'a' || card['type'] == 'b') {
      AudioService.playLetter(cardText);
    }

    setState(() {
      if (_firstFlippedIndex == null) {
        _firstFlippedIndex = index;
      } else {
        _secondFlippedIndex = index;
        final first = _matchCards[_firstFlippedIndex!];
        final second = _matchCards[index];

        if (first['id'] == second['id'] && first['type'] != second['type']) {
          _matchedIndices.add(_firstFlippedIndex!);
          _matchedIndices.add(index);
          _matchPairsCorrect++;
          // Play the matched word/letter sound
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) AudioService.playLetter(first['id']);
          });
          _firstFlippedIndex = null;
          _secondFlippedIndex = null;

          if (_matchPairsCorrect >= _matchPairsTotal) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) _endGame();
            });
          }
        } else {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              setState(() {
                _firstFlippedIndex = null;
                _secondFlippedIndex = null;
              });
            }
          });
        }
      }
    });
  }

  void _handleListenSpeak() {
    final round = _rounds[_currentRound];
    AudioService.playWord(round['word']);
  }

  void _handleListenSpeakDone() {
    setState(() {
      _correctAnswers++;
      _currentRound++;
      if (_currentRound >= _rounds.length) {
        _endGame();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _feedbackController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isGameOver) return _buildGameOverScreen();
    if (_rounds.isEmpty) return _buildGameOverScreen();

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Game Header
            _buildGameHeader(),

            // Game Content
            Expanded(
              child: _buildCurrentGame(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameHeader() {
    final levelId = widget.level['id'];
    final progress = _rounds.isNotEmpty && _rounds[0]['type'] == 'match_pairs'
        ? _matchPairsCorrect / (_matchPairsTotal > 0 ? _matchPairsTotal : 1)
        : _currentRound / _totalRounds;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.white,
      child: Column(
        children: [
          Row(
            children: [
              // Close button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppTheme.topoLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: AppTheme.textDark),
                ),
              ),
              const SizedBox(width: 12),

              // Progress bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: AppTheme.topoSilver,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.stageColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _timeLeft <= 10 ? AppTheme.primary : AppTheme.topoLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer, size: 16,
                        color: _timeLeft <= 10 ? AppTheme.primary : AppTheme.textSlate),
                    const SizedBox(width: 4),
                    Text(
                      '$_timeLeft',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _timeLeft <= 10 ? AppTheme.primary : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Level $levelId',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.stageColor,
                ),
              ),
              const Text(
                '  •  ',
                style: TextStyle(color: AppTheme.textGray),
              ),
              Text(
                '${widget.level['title']}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSlate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentGame() {
    if (_currentRound >= _rounds.length) return const SizedBox();
    final round = _rounds[_currentRound];

    switch (round['type']) {
      case 'multiple_choice':
        return _buildMultipleChoiceGame(round);
      case 'listen_choose':
        return _buildListenChooseGame(round);
      case 'match_pairs':
        return _buildMatchPairsGame(round);
      case 'arrange':
        return _buildArrangeGame(round);
      case 'fill_blank':
        return _buildFillBlankGame(round);
      case 'listen_speak':
        return _buildListenSpeakGame(round);
      default:
        return _buildMultipleChoiceGame(round);
    }
  }

  // === MULTIPLE CHOICE GAME ===
  Widget _buildMultipleChoiceGame(Map<String, dynamic> round) {
    // Auto-play when this round appears
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlayRoundAudio());

    final options = round['options'] as List;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          // Display area — tappable to hear sound
          if (round['displayEmoji'] != null)
            Text(round['displayEmoji'], style: const TextStyle(fontSize: 72)),
          if (round['displayLetter'] != null)
            GestureDetector(
              onTap: () => AudioService.playLetter(round['displayLetter']),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: widget.stageColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      round['displayLetter'],
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: widget.stageColor,
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Icon(Icons.volume_up_rounded, size: 20,
                          color: widget.stageColor.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Prompt
          Text(
            round['tamilPrompt'] ?? round['prompt'],
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansTamil(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),

          const Spacer(),

          // Options grid — each option is tappable to hear & answer
          ...List.generate(options.length, (i) {
            final option = options[i];
            final isCorrectOption = option == round['correct'];
            Color bgColor = AppTheme.white;
            Color borderColor = AppTheme.borderLight;

            if (_showFeedback) {
              if (isCorrectOption) {
                bgColor = AppTheme.success.withOpacity(0.1);
                borderColor = AppTheme.success;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: _showFeedback ? null : () => _handleAnswer(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.textDark.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.volume_up_rounded, size: 18,
                          color: AppTheme.textGray),
                      const SizedBox(width: 10),
                      Text(
                        option.toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const Spacer(),

          // Feedback indicator
          if (_showFeedback)
            Icon(
              _lastAnswerCorrect ? Icons.check_circle : Icons.cancel,
              color: _lastAnswerCorrect ? AppTheme.success : AppTheme.primary,
              size: 48,
            ),
        ],
      ),
    );
  }

  // === LISTEN & CHOOSE GAME ===
  Widget _buildListenChooseGame(Map<String, dynamic> round) {
    // Auto-play the audio when this round starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.playLetter(round['audioText']);
    });

    final options = round['options'] as List;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          // Speaker button
          GestureDetector(
            onTap: () => AudioService.playLetter(round['audioText']),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: widget.stageColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: widget.stageColor.withOpacity(0.3), width: 3),
              ),
              child: Icon(Icons.volume_up_rounded, size: 56, color: widget.stageColor),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            round['tamilPrompt'] ?? round['prompt'],
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansTamil(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),

          const Spacer(),

          // 2x2 grid options
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.0,
            physics: const NeverScrollableScrollPhysics(),
            children: options.map((option) {
              final isCorrectOption = option == round['correct'];
              Color bgColor = AppTheme.white;
              if (_showFeedback && isCorrectOption) {
                bgColor = AppTheme.success.withOpacity(0.1);
              }
              return GestureDetector(
                onTap: _showFeedback ? null : () => _handleAnswer(option),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _showFeedback && isCorrectOption
                          ? AppTheme.success
                          : AppTheme.borderLight,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option.toString(),
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  // === MATCH PAIRS GAME ===
  Widget _buildMatchPairsGame(Map<String, dynamic> round) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            round['tamilPrompt'] ?? round['prompt'],
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansTamil(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          Text(
            '$_matchPairsCorrect / $_matchPairsTotal pairs',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppTheme.textSlate,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemCount: _matchCards.length,
              itemBuilder: (context, index) {
                final card = _matchCards[index];
                final isFlipped = index == _firstFlippedIndex ||
                    index == _secondFlippedIndex ||
                    _matchedIndices.contains(index);
                final isMatched = _matchedIndices.contains(index);

                return GestureDetector(
                  onTap: isMatched ? null : () => _handleMatchPairsTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isMatched
                          ? AppTheme.success.withOpacity(0.1)
                          : (isFlipped ? AppTheme.white : widget.stageColor),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isMatched
                            ? AppTheme.success
                            : (isFlipped ? widget.stageColor : Colors.transparent),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.textDark.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isFlipped
                          ? Text(
                              card['text'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.notoSansTamil(
                                fontSize: card['text'].length > 3 ? 16 : 24,
                                fontWeight: FontWeight.bold,
                                color: isMatched
                                    ? AppTheme.success
                                    : AppTheme.textDark,
                              ),
                            )
                          : const Icon(Icons.help_outline,
                              color: AppTheme.white, size: 32),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // === ARRANGE GAME ===
  Widget _buildArrangeGame(Map<String, dynamic> round) {
    // Auto-play the target word when this round appears
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlayRoundAudio());

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  round['tamilPrompt'] ?? round['prompt'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => AudioService.playWord(round['word']),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.stageColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.volume_up_rounded, size: 22, color: widget.stageColor),
                ),
              ),
            ],
          ),
          if (round['hint'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '💡 ${round['hint']}',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppTheme.textSlate,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 30),

          // Target area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: widget.stageColor.withOpacity(0.15), width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.textDark.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => AudioService.playWord(round['word']),
                  icon: Icon(Icons.volume_up_rounded, color: widget.stageColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _arrangedItems.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () {
                          AudioService.playLetter(entry.value);
                          setState(() {
                            _availableItems.add(_arrangedItems.removeAt(entry.key));
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: widget.stageColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: widget.stageColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            entry.value,
                            style: GoogleFonts.notoSansTamil(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.stageColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (_arrangedItems.isEmpty)
            Text(
              'Tap letters below to arrange',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppTheme.textGray,
              ),
            ),

          const SizedBox(height: 30),

          // Available items
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _availableItems.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  AudioService.playLetter(entry.value);
                  setState(() {
                    _arrangedItems.add(_availableItems.removeAt(entry.key));
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderLight, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.textDark.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    entry.value,
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const Spacer(),

          // Submit button
          if (_availableItems.isEmpty && _arrangedItems.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _showFeedback ? null : _handleArrangeSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.stageColor,
                  foregroundColor: AppTheme.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'CHECK',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

          // Feedback
          if (_showFeedback)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _lastAnswerCorrect ? Icons.check_circle : Icons.cancel,
                    color: _lastAnswerCorrect ? AppTheme.success : AppTheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _lastAnswerCorrect ? 'Correct!' : 'Try again!',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _lastAnswerCorrect ? AppTheme.success : AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // === FILL BLANK GAME ===
  Widget _buildFillBlankGame(Map<String, dynamic> round) {
    // Auto-play the full word when round appears
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlayRoundAudio());

    final options = round['options'] as List;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          // Prompt/Question
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _autoPlayRoundAudio(),
                icon: Icon(Icons.volume_up_rounded, color: widget.stageColor),
                iconSize: 28,
              ),
              const SizedBox(width: 8),
              if (round['displayLetter'] != null || round['displayEmoji'] != null)
                Text(
                  round['displayLetter'] ?? round['displayEmoji']!,
                  style: GoogleFonts.notoSansTamil(
                    fontSize: round['displayLetter'] != null ? 80 : 64,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
            ],
          ),
          Text(
            round['tamilPrompt'] ?? round['prompt'],
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansTamil(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 24),

          // Word with blank — tap to hear the full word
          GestureDetector(
            onTap: () => AudioService.playWord(round['word']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.stageColor.withOpacity(0.2), width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    round['display'],
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(Icons.volume_up_rounded, size: 20,
                      color: widget.stageColor.withOpacity(0.4)),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Options
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
            physics: const NeverScrollableScrollPhysics(),
            children: options.map((option) {
              final isCorrectOption = option == round['correct'];
              Color bgColor = AppTheme.white;
              if (_showFeedback && isCorrectOption) {
                bgColor = AppTheme.success.withOpacity(0.1);
              }
              return GestureDetector(
                onTap: _showFeedback ? null : () {
                  AudioService.playLetter(option.toString());
                  _handleAnswer(option);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _showFeedback && isCorrectOption
                          ? AppTheme.success
                          : AppTheme.borderLight,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option.toString(),
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  // === LISTEN & SPEAK GAME ===
  Widget _buildListenSpeakGame(Map<String, dynamic> round) {
    // Auto-play the word/sentence when this round appears
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlayRoundAudio());

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          if (round['emoji'] != null)
            Text(round['emoji'], style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 20),

          Text(
            round['tamilPrompt'] ?? round['prompt'],
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansTamil(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),

          const SizedBox(height: 24),

          // Word to read
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.stageColor.withOpacity(0.2), width: 2),
            ),
            child: Text(
              round['word'],
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansTamil(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),

          if (round['english'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                round['english'],
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: AppTheme.textGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 40),

          // Listen button
          GestureDetector(
            onTap: _handleListenSpeak,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: widget.stageColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: widget.stageColor.withOpacity(0.3), width: 3),
              ),
              child: Icon(Icons.volume_up_rounded, size: 44, color: widget.stageColor),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            'Tap to listen',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.textGray,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // Done button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _handleListenSpeakDone,
              icon: const Icon(Icons.check_rounded),
              label: Text(
                'I CAN SAY IT!',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.stageColor,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // === GAME OVER SCREEN ===
  Widget _buildGameOverScreen() {
    final total = _rounds.isNotEmpty && _rounds[0]['type'] == 'match_pairs'
        ? _matchPairsTotal
        : _totalRounds;
    final correct = _rounds.isNotEmpty && _rounds[0]['type'] == 'match_pairs'
        ? _matchPairsCorrect
        : _correctAnswers;
    final ratio = correct / (total > 0 ? total : 1);
    final stars = ratio >= 0.9 ? 3 : (ratio >= 0.6 ? 2 : 1);

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),

                    Text(
                      'Level ${widget.level['id']} Complete!',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Star display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: i < stars ? 1.0 : 0.3),
                          duration: Duration(milliseconds: 500 + (i * 250)),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.4 + (value * 0.6),
                              child: Icon(
                                Icons.star_rounded,
                                color: i < stars
                                    ? AppTheme.gold
                                    : AppTheme.borderLight,
                                size: 56,
                              ),
                            );
                          },
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      '$correct / $total correct',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSlate,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      stars == 3
                          ? 'Perfect! ⭐⭐⭐'
                          : stars == 2
                              ? 'Great job! ⭐⭐'
                              : 'Good work! ⭐',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textGray,
                      ),
                    ),

                    // XP earned
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.offWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '⚡ +${widget.level['xp']} XP',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.warning,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.stageColor,
                          foregroundColor: AppTheme.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'CONTINUE',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Confetti overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppTheme.success,
                  AppTheme.info,
                  AppTheme.primary,
                  AppTheme.warning,
                  AppTheme.primaryDark,
                ],
                numberOfParticles: 30,
                gravity: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
