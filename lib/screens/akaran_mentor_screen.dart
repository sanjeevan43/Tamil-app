import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamil_app/constants/app_theme.dart';
import 'package:tamil_app/services/claude_api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:tamil_app/providers/enhanced_progress_provider.dart';

class AkaranMentorScreen extends StatefulWidget {
  final int childAge;

  const AkaranMentorScreen({super.key, required this.childAge});

  @override
  State<AkaranMentorScreen> createState() => _AkaranMentorScreenState();
}

class _AkaranMentorScreenState extends State<AkaranMentorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _regionalMode = false;
  bool _isInitializing = true;
  String? _userId;

  final List<String> gameModes = [
    'Spot the Spoken',
    'Fix It!',
    'Flip It!',
    'Street Scene',
    'Voice Comparison'
  ];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
      _userId = progress.userId;
      
      if (_userId != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('akaran_messages')
            .orderBy('timestamp', descending: false)
            .get();
            
        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            _messages.clear();
            for (var doc in querySnapshot.docs) {
              final data = doc.data();
              _messages.add({
                'role': data['role']?.toString() ?? 'assistant',
                'content': data['content']?.toString() ?? '',
              });
            }
            _isInitializing = false;
          });
          _scrollToBottom();
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading Akaran chat history: $e');
    }

    // Default greeting if Firestore is empty or user is anonymous
    setState(() {
      _messages.clear();
      _messages.add({
        'role': 'assistant',
        'content': 'வணக்கம்! நான் அகர்ன் (Akaran). உனது தமிழ் வழிகாட்டி! எழுத்து தமிழ் மற்றும் பேச்சு தமிழ் இரண்டையும் நாம் சேர்ந்து கற்றுக்கொள்ளலாம். உனக்கு எந்த கேம் விளையாட பிடிக்கும்?',
      });
      _isInitializing = false;
    });

    // Write default greeting to Firestore if logged in
    try {
      if (_userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('akaran_messages')
            .add({
          'role': 'assistant',
          'content': 'வணக்கம்! நான் அகர்ன் (Akaran). உனது தமிழ் வழிகாட்டி! எழுத்து தமிழ் மற்றும் பேச்சு தமிழ் இரண்டையும் நாம் சேர்ந்து கற்றுக்கொள்ளலாம். உனக்கு எந்த கேம் விளையாட பிடிக்கும்?',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error saving initial greeting to Firestore: $e');
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userText = text.trim();
    _messageController.clear();

    setState(() {
      _messages.add({'role': 'user', 'content': userText});
      _isLoading = true;
    });

    _scrollToBottom();

    // Save user message to Firestore
    try {
      if (_userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('akaran_messages')
            .add({
          'role': 'user',
          'content': userText,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error saving user message to Firestore: $e');
    }

    try {
      final response = await ClaudeApiService.chatWithAkaran(
        messages: _messages,
        childAge: widget.childAge,
        regionalMode: _regionalMode,
      );

      if (!mounted) return;

      setState(() {
        _messages.add({'role': 'assistant', 'content': response});
        _isLoading = false;
      });
      _scrollToBottom();

      // Save assistant response to Firestore
      try {
        if (_userId != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_userId)
              .collection('akaran_messages')
              .add({
            'role': 'assistant',
            'content': response,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        debugPrint('Error saving assistant response to Firestore: $e');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _messages.add({
          'role': 'assistant',
          'content': 'மன்னிக்கவும், நெட்வொர்க் பிழை. மீண்டும் முயற்சிக்கவும்! (Error: $e)'
        });
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMarkdownText(String text, bool isUser) {
    // A very simple markdown parser for **bold** text
    final spans = <TextSpan>[];
    final parts = text.split('**');
    
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        // Bold part
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(fontWeight: FontWeight.w900, color: isUser ? AppTheme.white : AppTheme.primaryDark),
        ));
      } else {
        // Regular part
        spans.add(TextSpan(
          text: parts[i],
        ));
      }
    }

    return RichText(
      text: TextSpan(
        style: GoogleFonts.outfit(
          fontSize: 15,
          color: isUser ? AppTheme.white : AppTheme.secondary,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUser ? null : AppTheme.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: isUser ? const Radius.circular(24) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(24),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppTheme.borderLight, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? AppTheme.primary.withOpacity(0.2)
                        : AppTheme.secondary.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildMarkdownText(message['content'] ?? '', isUser),
            ),
          ),
          if (isUser) const SizedBox(width: 40),
          if (!isUser) const SizedBox(width: 40),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Emojis for each game mode
    final Map<String, String> modeEmojis = {
      'Spot the Spoken': '🎯',
      'Fix It!': '🔧',
      'Flip It!': '🔄',
      'Street Scene': '🛣️',
      'Voice Comparison': '🗣️',
    };

    // Color theme for chips
    final List<Color> chipColors = [
      const Color(0xFFFF7043),
      const Color(0xFF42A5F5),
      AppTheme.success,
      const Color(0xFFAB47BC),
      const Color(0xFFEC407A),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppTheme.textDark.withOpacity(0.08), blurRadius: 8)],
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: AppTheme.secondary, size: 20),
                  ),
                ),
              )
            : null,
        title: Text(
          'Akaran AI Mentor',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            color: AppTheme.secondary,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: const BoxDecoration(
              color: AppTheme.white,
              border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Online Tamil Guide',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textGray,
                  ),
                ),
                const Spacer(),
                Text(
                  'Regional Dialect',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.secondary,
                  ),
                ),
                const SizedBox(width: 4),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: _regionalMode,
                    activeThumbColor: AppTheme.primary,
                    onChanged: (val) {
                      setState(() => _regionalMode = val);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              children: [
                // Game Mode Chips
                Container(
                  color: AppTheme.offWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(gameModes.length, (index) {
                        final mode = gameModes[index];
                        final emoji = modeEmojis[mode] ?? '🎮';
                        final color = chipColors[index % chipColors.length];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: InkWell(
                            onTap: () {
                              _sendMessage("Let's play $mode!");
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: color.withOpacity(0.2), width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Text(emoji, style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    mode,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                // Chat Area
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.offWhite,
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: AppTheme.offWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('🤖', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
                        ),
                      ],
                    ),
                  ),
                // Input Area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondary.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    border: const Border(top: BorderSide(color: AppTheme.borderLight)),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: GoogleFonts.notoSansTamil(
                              fontSize: 15,
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type your message in Tamil or English...',
                              hintStyle: GoogleFonts.outfit(
                                color: AppTheme.textGray.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                              ),
                              filled: true,
                              fillColor: AppTheme.offWhite,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            ),
                            onSubmitted: (val) => _sendMessage(val),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send_rounded, color: AppTheme.white, size: 20),
                            onPressed: () => _sendMessage(_messageController.text),
                          ),
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

