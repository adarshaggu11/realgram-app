import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String agentName;
  final String agentAvatar;

  const ChatDetailScreen({
    Key? key,
    required this.chatId,
    required this.agentName,
    required this.agentAvatar,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _showQuickReplies = true;

  // Mock messages for demo
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      text: 'Hi, is this property still available?',
      isFromCurrentUser: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      readAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
    ),
    ChatMessage(
      id: '2',
      text: 'Yes, it is! Would you like to schedule a visit?',
      isFromCurrentUser: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
    ),
    ChatMessage(
      id: '3',
      text: 'What are the timings for viewing?',
      isFromCurrentUser: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      readAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 25)),
    ),
    ChatMessage(
      id: '4',
      text:
          'We are available from 10 AM to 6 PM on weekdays and 10 AM to 8 PM on weekends.',
      isFromCurrentUser: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ChatMessage(
      id: '5',
      text: 'Sure, can we come tomorrow at 2 PM?',
      isFromCurrentUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      readAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    ChatMessage(
      id: '6',
      text: 'Perfect! I will be waiting. Please bring ID proof.',
      isFromCurrentUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  final List<String> _quickReplies = [
    '📅 Schedule a tour',
    '❓ More details',
    '💰 Price negotiation',
    '📍 Get directions',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().toString(),
        text: _messageController.text.trim(),
        isFromCurrentUser: true,
        timestamp: DateTime.now(),
        readAt: DateTime.now().add(const Duration(seconds: 2)),
      ));
      _showQuickReplies = false;
    });

    _messageController.clear();
    _triggerTypingIndicator();
    _scrollToBottom();
  }

  void _triggerTypingIndicator() {
    setState(() => _isTyping = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scheduleCallback() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ScheduleCallbackSheet(
        onScheduled: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Callback scheduled for tomorrow at 3 PM'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.agentName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star,
                          size: 12, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        '4.8',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Online · Typically replies in 5 minutes',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.green,
              ),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Starting voice call...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Agent verified and trusted'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                3,
                                (i) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3),
                                  child: _TypingDot(
                                    delay: i * 100,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final message = _messages[index];
                return ChatBubble(
                  message: message,
                );
              },
            ),
          ),
          // Quick Replies
          if (_showQuickReplies)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: _quickReplies
                    .map(
                      (reply) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(
                            reply,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            _messageController.text = reply;
                            _sendMessage();
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          // Divider
          Divider(height: 1, color: Colors.grey[300]),
          // Input Area
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Message...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.emoji_emotions_outlined),
                              color: Colors.grey[600],
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Emoji picker coming soon'),
                                    duration: Duration(milliseconds: 500),
                                  ),
                                );
                              },
                            ),
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        mini: true,
                        onPressed: _messageController.text.isEmpty
                            ? null
                            : _sendMessage,
                        child: const Icon(Icons.send),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.schedule),
            label: const Text('Schedule callback', style: TextStyle(fontSize: 12)),
            onPressed: _scheduleCallback,
          ),
        ),
      ],
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isFromCurrentUser;
  final DateTime timestamp;
  final DateTime? readAt;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isFromCurrentUser,
    required this.timestamp,
    this.readAt,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isFromCurrentUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: message.isFromCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: message.isFromCurrentUser
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: message.isFromCurrentUser
                        ? Colors.white
                        : Colors.black87,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
                if (message.isFromCurrentUser && message.readAt != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 12,
                    color: Colors.blue,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.grey[600],
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ScheduleCallbackSheet extends StatefulWidget {
  final VoidCallback onScheduled;

  const _ScheduleCallbackSheet({required this.onScheduled});

  @override
  State<_ScheduleCallbackSheet> createState() => _ScheduleCallbackSheetState();
}

class _ScheduleCallbackSheetState extends State<_ScheduleCallbackSheet> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule a callback',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          // Date picker
          ListTile(
            title: const Text('Date'),
            trailing: Text(
              _selectedDate == null
                  ? 'Select date'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
          // Time picker
          ListTile(
            title: const Text('Time'),
            trailing: Text(
              _selectedTime == null
                  ? 'Select time'
                  : _selectedTime!.format(context),
            ),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                setState(() => _selectedTime = time);
              }
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedDate != null && _selectedTime != null
                  ? widget.onScheduled
                  : null,
              child: const Text('Schedule'),
            ),
          ),
        ],
      ),
    );
  }
}


