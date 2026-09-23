import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../../core/state/smart_soil_scope.dart';
import '../view_models/ai_chat_view_model.dart';

/// Conversational Agronomic AI Chatbot Screen ("Ask AI / Aksara").
class AgronomicChatScreen extends StatefulWidget {
  const AgronomicChatScreen({super.key});

  @override
  State<AgronomicChatScreen> createState() => _AgronomicChatScreenState();
}

class _AgronomicChatScreenState extends State<AgronomicChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(AiChatViewModel vm) {
    final text = _controller.text;
    if (text.trim().isNotEmpty) {
      vm.sendMessage(text);
      _controller.clear();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = SmartSoilScope.of(context);
    final lang = scope.language;
    final chatVm = scope.chat;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPromptChip(chatVm, lang.tr('chip_fungal')),
                const SizedBox(width: 8),
                _buildPromptChip(chatVm, lang.tr('chip_npk')),
                const SizedBox(width: 8),
                _buildPromptChip(chatVm, lang.tr('chip_moisture')),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: chatVm.messages.length,
            itemBuilder: (context, index) {
              final msg = chatVm.messages[index];
              return _buildChatBubble(msg);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                offset: const Offset(0, -2),
                blurRadius: 6,
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _send(chatVm),
                    decoration: InputDecoration(
                      hintText: lang.tr('chat_placeholder'),
                      hintStyle: const TextStyle(fontSize: 13, color: SmartSoilTheme.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      filled: true,
                      fillColor: SmartSoilTheme.creamBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: SmartSoilTheme.forestGreen,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: () => _send(chatVm),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptChip(AiChatViewModel vm, String text) {
    return ActionChip(
      label: Text(text),
      labelStyle: const TextStyle(fontSize: 11, color: SmartSoilTheme.forestGreen, fontWeight: FontWeight.bold),
      backgroundColor: SmartSoilTheme.forestGreen.withOpacity(0.08),
      onPressed: () => vm.sendMessage(text),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              backgroundColor: SmartSoilTheme.forestGreen,
              radius: 14,
              child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? SmartSoilTheme.forestGreen : Colors.white,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                  bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 13,
                  color: isUser ? Colors.white : SmartSoilTheme.textDark,
                  height: 1.35,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 24),
        ],
      ),
    );
  }
}
