import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/blue_app_bar.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  static const _suggestions = [
    'Đặt lịch khám',
    'Giá khám',
    'Giờ làm việc',
    'Chỉ đường',
  ];

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text: 'Xin chào! Tôi có thể giúp gì cho bạn hôm nay?',
      isUser: false,
    ),
  ];
  Timer? _typingTimer;
  int _typingDots = 1;
  bool _isTyping = false;

  @override
  void dispose() {
    _typingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? quickMessage]) {
    final text = (quickMessage ?? _controller.text).trim();
    if (text.isEmpty) return;
    _controller.clear();
    _typingTimer?.cancel();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
      _typingDots = 1;
    });
    _scrollToBottom();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _typingDots = _typingDots % 3 + 1);
    });
    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      _typingTimer?.cancel();
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(text: _mockReply(text), isUser: false));
      });
      _scrollToBottom();
    });
  }

  String _mockReply(String input) {
    final text = input.toLowerCase();
    if (text.contains('đặt lịch') || text.contains('lịch khám')) {
      return 'Bạn có thể đặt lịch tại mục “Đặt lịch” trên Trang chủ. Chọn người khám, chuyên khoa, bác sĩ và giờ phù hợp nhé.';
    }
    if (text.contains('giá') || text.contains('chi phí') || text.contains('phí khám')) {
      return 'Chi phí khám tùy theo chuyên khoa và dịch vụ. Bạn vui lòng liên hệ hotline 1900 6422 để được hỗ trợ mức phí cụ thể.';
    }
    if (text.contains('giờ') || text.contains('làm việc') || text.contains('mở cửa')) {
      return 'Bệnh viện tiếp nhận khám từ thứ Hai đến thứ Bảy, 07:00–17:00. Một số chuyên khoa có khung giờ riêng.';
    }
    if (text.contains('đường') || text.contains('địa chỉ') || text.contains('bản đồ')) {
      return 'BV Da liễu Trung ương ở số 15A Phương Mai, Đống Đa, Hà Nội. Bạn mở mục Bản đồ bệnh viện để xem sơ đồ.';
    }
    return 'Tôi đã ghi nhận câu hỏi của bạn. Bạn có thể hỏi về đặt lịch, giá khám, giờ làm việc hoặc chỉ đường; cần hỗ trợ trực tiếp hãy gọi 1900 6422.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        appBar: BlueAppBar(
          title: 'Trợ lý ảo',
          leading: const Padding(
            padding: EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.smart_toy_outlined,
                  color: AppColors.primary, size: 22),
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.more_vert),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return _ChatBubble(
                        text: '.' * _typingDots,
                        isUser: false,
                        isTyping: true,
                      );
                    }
                    final message = _messages[index];
                    return _ChatBubble(
                        text: message.text, isUser: message.isUser);
                  },
                ),
              ),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => ActionChip(
                    label: Text(_suggestions[index]),
                    onPressed: () => _send(_suggestions[index]),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFD6E4F4)),
                    labelStyle: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 9, 10, 10),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          filled: true,
                          fillColor: const Color(0xFFF4F5F7),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _send,
                      tooltip: 'Gửi tin nhắn',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.send_rounded, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.text,
    required this.isUser,
    this.isTyping = false,
  });

  final String text;
  final bool isUser;
  final bool isTyping;

  @override
  Widget build(BuildContext context) => Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * .78),
          margin: const EdgeInsets.only(bottom: 11),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isUser ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0C000000), blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isUser ? Colors.white : AppColors.textPrimary,
              fontSize: isTyping ? 20 : 14,
              height: 1.4,
              fontWeight: isTyping ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
        ),
      );
}
