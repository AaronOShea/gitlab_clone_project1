import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
          "Hi, I’m your finance coach. Ask me anything about your spending, budget, or goals and I’ll give you practical tips.",
      fromCoach: true,
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7F5),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF1B5E20),
                  ],
                ),
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Coach',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                Text(
                  'Friendly guidance for your money',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: _SuggestionChips(
                onTap: _handleSuggestionTapped,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _ChatBubble(message: message);
                  },
                ),
              ),
            ),
            const Divider(height: 1),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _handleSend(),
                          decoration: const InputDecoration(
                            hintText: 'Ask a question about your money…',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _handleSend,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSuggestionTapped(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  void _handleSend() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: raw,
          fromCoach: false,
        ),
      );
      _messages.add(
        _ChatMessage(
          text: _buildCoachReply(raw),
          fromCoach: true,
        ),
      );
    });

    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _buildCoachReply(String userMessage) {
    final lower = userMessage.toLowerCase();

    if (lower.contains('grocer') ||
        lower.contains('food') ||
        lower.contains('eating out') ||
        lower.contains('restaurant')) {
      return "Food is one of the easiest areas to overspend.\n\n"
          "• Try setting a simple weekly cap for groceries and eating out.\n"
          "• Before you shop, write a short list and avoid ‘just browsing’ the aisles.\n"
          "• If you’d like, we can create a realistic food budget you can actually stick to.";
    }

    if (lower.contains('rent') || lower.contains('housing') || lower.contains('bills')) {
      return "Housing and fixed bills take a big chunk of most budgets.\n\n"
          "Start by listing all your fixed bills (rent, utilities, phone, subscriptions) and compare them to your income.\n"
          "From there, we can see what’s left for savings and day‑to‑day spending, then look for easy places to trim.";
    }

    if (lower.contains('debt') ||
        lower.contains('credit card') ||
        lower.contains('loan') ||
        lower.contains('owe')) {
      return "A simple way to handle debt is the ‘debt snowball’ or ‘debt avalanche’.\n\n"
          "1) List your debts with balance and interest rate.\n"
          "2) Pay the minimum on all but one debt.\n"
          "3) Put any extra money towards the target debt until it’s cleared.\n\n"
          "Tell me your balances and rates and I can suggest which strategy fits you best.";
    }

    if (lower.contains('save') ||
        lower.contains('savings') ||
        lower.contains('emergency fund') ||
        lower.contains('goal')) {
      return "Let’s turn this into a clear savings plan.\n\n"
          "Think about:\n"
          "• What you’re saving for\n"
          "• How much you need\n"
          "• When you’d like to reach it\n\n"
          "From there we can break it into a monthly amount that fits your budget.";
    }

    if (lower.contains('budget') || lower.contains('spend') || lower.contains('spending')) {
      return "A good budget isn’t about restriction, it’s about clarity.\n\n"
          "Try a simple 50/30/20 split of your income:\n"
          "• 50% needs (rent, bills, groceries)\n"
          "• 30% wants (fun, treats, non‑essentials)\n"
          "• 20% future you (savings, debt payments above the minimum)\n\n"
          "We can adjust those percentages to fit your real numbers.";
    }

    return "Thanks for sharing that.\n\n"
        "I’m here to help you understand where your money is going and how to make steady progress.\n"
        "You can ask me about your budget, cutting a specific expense, building savings, or tackling debt.";
  }
}

class _ChatMessage {
  final String text;
  final bool fromCoach;

  const _ChatMessage({
    required this.text,
    required this.fromCoach,
  });
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isCoach = message.fromCoach;
    final alignment =
        isCoach ? Alignment.centerLeft : Alignment.centerRight;
    final bubbleColor = isCoach
        ? const Color(0xFFE8F5E9)
        : const Color(0xFF2E7D32);
    final textColor = isCoach ? const Color(0xFF1B5E20) : Colors.white;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isCoach ? 4 : 18),
                bottomRight: Radius.circular(isCoach ? 18 : 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  final void Function(String text) onTap;

  const _SuggestionChips({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'How can I cut my food spending?',
      'Help me create a simple budget',
      'What’s a good savings goal?',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final suggestion in suggestions) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
                label: Text(
                  suggestion,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => onTap(suggestion),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
