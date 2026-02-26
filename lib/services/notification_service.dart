import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();
  
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  // Callbacks
  Function(RemoteMessage)? onMessageCallback;
  Function(RemoteMessage)? onMessageOpenedAppCallback;
  
  /// Initialize notifications (call once in main.dart)
  Future<void> initialize() async {
    // Request user permission for notifications
    await _requestPermission();
    
    // Setup local notifications for Android
    await _setupLocalNotifications();
    
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
      debugPrint('✅ User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('⚠️ Provisional notification permission');
    } else {
      debugPrint('❌ User denied notification permission');
    }
  }
  
  /// Setup local notifications for Android
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
    
    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'realgram_notifications',
      'RealGram Notifications',
      description: 'Notifications for RealGram real estate app',
      importance: Importance.max,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  /// Get FCM token (call after initialization to save to Firestore)
  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('🔑 FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }
  
  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📬 Foreground message received:');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    
    // Show local notification for foreground message
    _showLocalNotification(message);
    
    // Call user callback
    onMessageCallback?.call(message);
  }
  
  /// Handle background message (static function)
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    debugPrint('📬 Background message received:');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    
    // Background message already shows system notification automatically
    // No need to call _showLocalNotification here
  }
  
  /// Handle message when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage? message) {
    if (message == null) return;
    
    debugPrint('👉 App opened from notification:');
    debugPrint('Title: ${message.notification?.title}');
    
    // Call user callback
    onMessageOpenedAppCallback?.call(message);
    
    // Navigate based on message type in main.dart
    _navigateToScreen(message);
  }
  
  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    
    if (notification == null) return;
    
    try {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'realgram_notifications',
            'RealGram Notifications',
            channelDescription: 'Notifications for RealGram real estate app',
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
            showProgress: false,
            ongoing: false,
            enableVibration: true,
            enableLights: true,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    } catch (e) {
      debugPrint('❌ Error showing local notification: $e');
    }
  }
  
  /// Handle notification tap
  void _handleNotificationTap(NotificationResponse response) {
    debugPrint('👆 Notification tapped: ${response.payload}');
    // Navigate to appropriate screen based on payload
  }
  
  /// Navigate to screen based on message type
  void _navigateToScreen(RemoteMessage message) {
    final data = message.data;
    final type = data['type']; // 'new_message', 'new_lead', etc.
    
    debugPrint('Navigating based on notification type: $type');
    
    // Navigation logic would go here
    // Can be handled in main.dart or with named routes
  }
  
  /// Send test notification (for testing purposes)
  Future<void> sendTestNotification(String title, String body) async {
    try {
      await _localNotifications.show(
        DateTime.now().millisecond,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'realgram_notifications',
            'RealGram Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error sending test notification: $e');
    }
  }
}
