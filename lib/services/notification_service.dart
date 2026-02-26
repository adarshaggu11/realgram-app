import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// Local notifications temporarily disabled due to build compatibility issues
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();
  
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // Callbacks
  Function(RemoteMessage)? onMessageCallback;
  Function(RemoteMessage)? onMessageOpenedAppCallback;
  
  /// Initialize notifications (call once in main.dart)
  Future<void> initialize() async {
    // Request user permission for notifications
    await _requestPermission();
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background message (top-level function required)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle when app is opened from notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then(_handleMessageOpenedApp);
    
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }
  
  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('Provisional notification permission');
    } else {
      debugPrint('User denied notification permission');
    }
  }
  
  /// Get FCM token (call after initialization to save to Firestore)
  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }
  
  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received:');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    
    // Call user callback
    onMessageCallback?.call(message);
  }
  
  /// Handle background message (static function)
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    debugPrint('Background message received:');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
  }
  
  /// Handle message when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage? message) {
    if (message == null) return;
    
    debugPrint('App opened from notification:');
    debugPrint('Title: ${message.notification?.title}');
    
    // Call user callback
    onMessageOpenedAppCallback?.call(message);

    // Navigate based on message type
    _navigateToScreen(message);
  }
  
  /// Navigate to screen based on message type
  void _navigateToScreen(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    debugPrint('Navigating based on notification type: $type');
  }
  
  /// Send test notification (for testing purposes)
  Future<void> sendTestNotification(String title, String body) async {
    debugPrint('Test notification: $title - $body');
  }
}
