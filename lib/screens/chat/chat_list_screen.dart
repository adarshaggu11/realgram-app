import 'package:flutter/material.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // Mock data for demo - will be replaced with Firestore queries
  final List<ChatPreview> _mockChats = [
    ChatPreview(
      id: '1',
      agentName: 'Rajesh Kumar',
      agentAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Rajesh',
      lastMessage: 'Sure, the property has parking available',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      propertyTitle: 'Luxury 3BHK Apartment',
      agentRating: 4.8,
      isOnline: true,
      responseTime: '5 min',
    ),
    ChatPreview(
      id: '2',
      agentName: 'Priya Singh',
      agentAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Priya',
      lastMessage: 'Can you visit the property tomorrow at 2 PM?',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
      propertyTitle: 'Plot in Dwarka',
      agentRating: 4.9,
      isOnline: true,
      responseTime: '3 min',
    ),
    ChatPreview(
      id: '3',
      agentName: 'Amit Patel',
      agentAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Amit',
      lastMessage: 'Price is negotiable for bulk purchase',
      timestamp: DateTime.now().subtract(const Duration(hours: 24)),
      unreadCount: 0,
      propertyTitle: '4BHK Villa',
      agentRating: 4.6,
      isOnline: false,
      responseTime: '2 hours',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
      ),
      body: _mockChats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start chatting with agents',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _mockChats.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 72,
                color: Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final chat = _mockChats[index];
                return ChatListTile(
                  chat: chat,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          chatId: chat.id,
                          agentName: chat.agentName,
                          agentAvatar: chat.agentAvatar,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class ChatPreview {
  final String id;
  final String agentName;
  final String agentAvatar;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final String propertyTitle;
  final double agentRating;
  final bool isOnline;
  final String responseTime;

  ChatPreview({
    required this.id,
    required this.agentName,
    required this.agentAvatar,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.propertyTitle,
    required this.agentRating,
    required this.isOnline,
    required this.responseTime,
  });
}

class ChatListTile extends StatelessWidget {
  final ChatPreview chat;
  final VoidCallback onTap;

  const ChatListTile({
    Key? key,
    required this.chat,
    required this.onTap,
  }) : super(key: key);

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(chat.agentAvatar),
            backgroundColor: Colors.grey[300],
          ),
          if (chat.isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                width: 14,
                height: 14,
              ),
            ),
          if (chat.unreadCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  chat.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  chat.agentName,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    chat.agentRating.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  chat.propertyTitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: chat.isOnline
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  chat.isOnline ? 'Online' : 'Away',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color:
                            chat.isOnline ? Colors.green[700] : Colors.grey[600],
                        fontSize: 10,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                chat.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatTime(chat.timestamp),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
