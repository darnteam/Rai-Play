import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  // Predefined responses for common financial questions
  final Map<String, String> _predefinedResponses = {
    'what is a budget': 'A budget is a plan for how you will spend your money. It helps you track your income and expenses so you can save for your goals!',
    'how do i save money': 'Great question! Start by setting a savings goal, tracking your spending, and putting aside a small amount each week. Even saving 5-10 per week can add up over time!',
    'what is interest': 'Interest is either money you earn when you save (like in a savings account) or money you pay when you borrow (like with a credit card). It\'s usually calculated as a percentage of the amount.',
    'what is a credit score': 'A credit score is a number (usually between 300-850) that represents how reliable you are with borrowed money. Higher scores help you get better interest rates on loans in the future!',
    'what is cryptocurrency': 'Cryptocurrency is a digital or virtual currency that uses cryptography for security. Bitcoin and Ethereum are popular examples. Unlike regular currency, it\'s not controlled by any government.',
    'what is investing': 'Investing means putting your money into something with the hope it will grow over time. This could be stocks, bonds, real estate, or even education to increase your future earning potential!',
    'how do taxes work': 'Taxes are money we pay to the government to fund public services like schools, roads, and healthcare. When you earn money, a portion of it goes to taxes based on how much you earn.',
    'what is a stock': 'A stock is a small piece of ownership in a company. When you buy stocks, you become a partial owner of that company and can benefit if the company grows and becomes more valuable!',
    'what is a bank account': 'A bank account is a safe place to keep your money. Checking accounts let you easily spend your money, while savings accounts help you save and earn some interest.',
    'how do credit cards work': 'Credit cards let you borrow money to make purchases. You need to pay back what you spend - ideally the full amount each month. If you don\'t pay in full, you\'ll owe extra money as interest!',
  };

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;

    _messageController.clear();
    
    setState(() {
      // Add user message
      _messages.add(_ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      
      // Show typing indicator
      _isTyping = true;
    });
    
    _scrollToBottom();
    
    // Simulate AI response after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isTyping = false;
        
        // Generate response based on predefined responses or a default
        final String normalizedQuestion = text.trim().toLowerCase();
        String response = 'I don\'t have an answer for that yet. In the future, I\'ll be able to answer all your financial questions!';
        
        // Check if the question contains any of our predefined keywords
        for (final entry in _predefinedResponses.entries) {
          if (normalizedQuestion.contains(entry.key)) {
            response = entry.value;
            break;
          }
        }
        
        // Add AI response
        _messages.add(_ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinBot Assistant'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Suggested questions
          Container(
            color: theme.colorScheme.primary.withOpacity(0.05),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildSuggestedQuestion(theme, 'What is a budget?'),
                  _buildSuggestedQuestion(theme, 'How do I save money?'),
                  _buildSuggestedQuestion(theme, 'What is a credit score?'),
                  _buildSuggestedQuestion(theme, 'How do taxes work?'),
                ],
              ),
            ),
          ),
          
          // Message list
          Expanded(
            child: Container(
              color: theme.colorScheme.background,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(theme, message);
                },
              ),
            ),
          ),
          
          // Typing indicator
          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          
          // Message input bar
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Message input field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.background,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Ask a financial question...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _handleSubmit,
                      ),
                    ),
                  ),
                  
                  // Send button
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      color: theme.colorScheme.onPrimary,
                      onPressed: () {
                        _handleSubmit(_messageController.text);
                      },
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
  
  Widget _buildSuggestedQuestion(ThemeData theme, String question) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          _handleSubmit(question);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Text(
            question,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMessageBubble(ThemeData theme, _ChatMessage message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // Bot avatar
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              radius: 16,
              child: const Text(
                '🤖',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser ? null : const Radius.circular(0),
                  bottomRight: isUser ? const Radius.circular(0) : null,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message text
                  Text(
                    message.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isUser 
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  
                  // Timestamp
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isUser 
                          ? theme.colorScheme.onPrimary.withOpacity(0.7)
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            // User avatar
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondary,
              radius: 16,
              child: const Text(
                '👤',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}