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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              child: const Text('🌟', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primary : AppTheme.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondary.withOpacity(0.05),
                    blurRadius: 10,
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Akaran Interactive Mentor',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            color: AppTheme.secondary,
          ),
        ),
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.secondary),
        actions: [
          Row(
            children: [
              Text(
                'Regional',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.secondary,
                ),
              ),
              Switch(
                value: _regionalMode,
                activeColor: AppTheme.primary,
                onChanged: (val) {
                  setState(() => _regionalMode = val);
                },
              ),
            ],
          ),
        ],
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              children: [
                // Game Mode Chips
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: gameModes.map((mode) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            label: Text(
                              mode,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.white,
                              ),
                            ),
                            backgroundColor: AppTheme.secondary,
                            onPressed: () {
                              _sendMessage("Let's play $mode!");
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Chat Area
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
                ),
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primary.withOpacity(0.2),
                          child: const Text('🌟', style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 16),
                        const CircularProgressIndicator(color: AppTheme.primary),
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
                        color: AppTheme.secondary.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: GoogleFonts.notoSansTamil(
                            fontSize: 16,
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: GoogleFonts.outfit(
                              color: AppTheme.textGray,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppTheme.backgroundLight,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          onSubmitted: (val) => _sendMessage(val),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: AppTheme.white),
                          onPressed: () => _sendMessage(_messageController.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
