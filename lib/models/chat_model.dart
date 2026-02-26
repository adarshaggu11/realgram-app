import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String propertyId;
  final String buyerId;
  final String agentId;
  final DateTime lastMessageTime;
  final String lastMessage;
  final int unreadCount;
  final bool isArchived;

  ChatModel({
    required this.id,
    required this.propertyId,
    required this.buyerId,
    required this.agentId,
    required this.lastMessageTime,
    required this.lastMessage,
    this.unreadCount = 0,
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'buyerId': buyerId,
      'agentId': agentId,
      'lastMessageTime': lastMessageTime,
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'isArchived': isArchived,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ChatModel(
      id: documentId,
      propertyId: map['propertyId'] ?? '',
      buyerId: map['buyerId'] ?? '',
      agentId: map['agentId'] ?? '',
      lastMessageTime: map['lastMessageTime'] is Timestamp
          ? (map['lastMessageTime'] as Timestamp).toDate()
          : DateTime.now(),
      lastMessage: map['lastMessage'] ?? '',
      unreadCount: map['unreadCount'] ?? 0,
      isArchived: map['isArchived'] ?? false,
    );
  }

  factory ChatModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    return ChatModel.fromMap(doc.data() ?? {}, doc.id);
  }
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? videoUrl;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.videoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
      'isRead': isRead,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MessageModel(
      id: documentId,
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
    );
  }

  factory MessageModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    return MessageModel.fromMap(doc.data() ?? {}, doc.id);
  }
}
