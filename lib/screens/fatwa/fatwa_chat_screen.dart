import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:islamic_app/screens/fatwa/services/local_search_service.dart';
import 'package:islamic_app/screens/fatwa/services/unified_fatwa_assistant.dart';
import 'models/chat_message.dart';
import 'models/fatwa_model.dart';

class FatwaChatScreen extends StatefulWidget {
  const FatwaChatScreen({super.key});

  @override
  State<FatwaChatScreen> createState() => _FatwaChatScreenState();
}

class _FatwaChatScreenState extends State<FatwaChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  List<Fatwa> _fatawa = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFatawa();
    _messages.add(ChatMessage.welcome());
  }

  Future<void> _loadFatawa() async {
    try {
      await LocalSearchService.loadFatawa();
      if (!mounted) return;
      setState(() {
        _fatawa = LocalSearchService.allFatawa;
      });
    } catch (e) {
      debugPrint('❌ تحميل: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage.fromUser(text));
      _messages.add(ChatMessage.loading());
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    ChatMessage answer;
    try {
      answer = await UnifiedFatwaAssistant.getAnswer(
        userQuestion: text,
        localFatawa: _fatawa,
      );
    } catch (e) {
      answer = ChatMessage.fromAssistantText(
        'تعذر إكمال البحث حالياً. حاول مرة أخرى بعد قليل.',
      );
      debugPrint('❌ خطأ في بحث الفتوى: $e');
    }

    if (!mounted) return;

    setState(() {
      _messages.removeWhere((m) => m.type == MessageType.loading);
      _messages.add(answer);
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F0),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B5E20),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مساعد الفتاوى',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                'يبحث في آلاف الفتاوى',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () {
                setState(() {
                  _messages.clear();
                  _messages.add(ChatMessage.welcome());
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _buildBubble(_messages[i]),
              ),
            ),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    switch (msg.type) {
      case MessageType.user:
        return _userBubble(msg);
      case MessageType.loading:
        return _loadingBubble();
      case MessageType.notFound:
        return _notFoundBubble(msg);
      case MessageType.assistant:
        if (msg.sourceOptions.isNotEmpty && msg.sourceFatwa == null) {
          return _chooseSourceBubble(msg);
        }
        if (msg.sourceOptions.isNotEmpty && msg.sourceFatwa != null) {
          return Column(
            children: [_assistantBubble(msg), _otherSourcesList(msg)],
          );
        }
        return _assistantBubble(msg);
    }
  }

  Widget _userBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 40),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'Cairo',
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 40),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'جاري البحث...',
                style: TextStyle(color: Colors.grey[600], fontFamily: 'Cairo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notFoundBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 40),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Text(
            msg.introText,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 14,
              fontFamily: 'Cairo',
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _assistantBubble(ChatMessage msg) {
    if (msg.sourceFatwa == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 20),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              msg.introText.isNotEmpty ? msg.introText : msg.text,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'Cairo',
                height: 1.7,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Text(
                  msg.introText,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Cairo',
                    height: 1.6,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(
                    right: BorderSide(color: Color(0xFF2E7D32), width: 4),
                  ),
                ),
                child: Text(
                  msg.extractedAnswer,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Cairo',
                    height: 1.9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.library_books,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      msg.sourceFatwa!.scholar,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: msg.extractedAnswer),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'تم النسخ',
                              style: TextStyle(fontFamily: 'Cairo'),
                            ),
                            backgroundColor: const Color(0xFF2E7D32),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF2E7D32,
                          ).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.copy,
                              size: 14,
                              color: Color(0xFF2E7D32),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'نسخ',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Cairo',
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ط¨ط¹ط¯ ط²ط± ط§ظ„ظ†ط³ط® ط£ط¶ظپ ظ‡ط°ط§
                    if (msg.sourceFatwa != null && msg.sourceFatwa!.hasAudio)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () async {
                            final uri = Uri.tryParse(msg.sourceFatwa!.audio);
                            if (uri == null || !await canLaunchUrl(uri)) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تعذر فتح الملف الصوتي'),
                                ),
                              );
                              return;
                            }
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF1565C0,
                              ).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.headphones,
                                  size: 14,
                                  color: Color(0xFF1565C0),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'صوتي',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Cairo',
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chooseSourceBubble(ChatMessage msg) {
    final sourceColors = {
      'إسلام سؤال وجواب': const Color(0xFF1565C0),
      'فتاوى ابن باز': const Color(0xFF6A1B9A),
      'الدرر السنية': const Color(0xFF00695C),
      'إسلام ويب': const Color(0xFF2E7D32),
    };

    final sourceIcons = {
      'إسلام سؤال وجواب': Icons.menu_book,
      'فتاوى ابن باز': Icons.person,
      'الدرر السنية': Icons.auto_stories,
      'إسلام ويب': Icons.language,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  msg.introText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    height: 1.6,
                  ),
                ),
              ),
              ...msg.sourceOptions.map((option) {
                final color =
                    sourceColors[option.sourceName] ?? const Color(0xFF2E7D32);
                final icon = sourceIcons[option.sourceName] ?? Icons.book;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _onSourceSelected(option, msg.sourceOptions),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.sourceName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                Text(
                                  option.title,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Cairo',
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 14, color: color),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otherSourcesList(ChatMessage msg) {
    if (msg.sourceOptions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 12, right: 40),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'نتائج من مصادر أخرى:',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...msg.sourceOptions.map((other) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap:
                        () => _onSourceSelected(other, [
                          ...msg.sourceOptions,
                          SourceOption(
                            sourceName: msg.sourceFatwa!.scholar,
                            title: msg.sourceFatwa!.question,
                            answer: msg.extractedAnswer,
                            url: '',
                            relevance: 0,
                            fatwa: msg.sourceFatwa!,
                          ),
                        ]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.library_books,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              other.sourceName,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          const Text(
                            'عرض',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _onSourceSelected(SourceOption selected, List<SourceOption> all) async {
    setState(() {
      _messages.add(ChatMessage.loading());
    });
    _scrollToBottom();

    final lastQ = _messages.lastWhere((m) => m.type == MessageType.user).text;
    ChatMessage message;
    try {
      message = await UnifiedFatwaAssistant.onSourceSelected(
        lastQ,
        selected,
        all,
      );
    } catch (e) {
      message = ChatMessage.fromAssistantText(
        'تعذر تحميل هذا المصدر حالياً. حاول مرة أخرى.',
      );
      debugPrint('❌ خطأ في اختيار مصدر الفتوى: $e');
    }

    if (!mounted) return;

    setState(() {
      _messages.removeWhere((m) => m.type == MessageType.loading);
      _messages.add(message);
    });
    _scrollToBottom();
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                textDirection: TextDirection.rtl,
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'اكتب سؤالك...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontFamily: 'Cairo',
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isLoading ? Colors.grey[300] : const Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isLoading ? Icons.hourglass_top : Icons.send,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
