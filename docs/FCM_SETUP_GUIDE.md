# Firebase Cloud Messaging (FCM) Setup Guide for RealGram

## Overview
This guide covers complete FCM setup for iOS and Android push notifications in the RealGram Flutter app.

---

## ✅ Already Implemented

### 1. **NotificationService** (`lib/services/notification_service.dart`)
- Initializes FCM on app startup
- Requests notification permissions
- Handles foreground messages
- Handles background messages
- Stores FCM token in Firestore user profile
- Local notifications for offline messages

### 2. **Main App Initialization** (`lib/main.dart`)
```dart
await NotificationService().initialize();  // Called before runApp()
```

### 3. **User Model Updated** (`lib/models/user_model.dart`)
- Added `fcmToken` field to store user's device token
- Token saved during profile completion

### 4. **Profile Completion** (`lib/screens/auth/profile_completion_screen.dart`)
- Gets FCM token after profile creation
- Saves token to Firestore automatically

---

## 🔧 Android Setup

### Step 1: Verify google-services.json
✅ Already configured in `android/app/google-services.json`

### Step 2: Update android/build.gradle (Project Level)
```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```

### Step 3: Update android/app/build.gradle (App Level)
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
  implementation 'com.google.firebase:firebase-messaging:23.4.1'
}
```

### Step 4: AndroidManifest.xml Configuration
Ensure `android/app/src/main/AndroidManifest.xml` contains:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Firebase Messaging -->
<service
    android:name="com.google.firebase.messaging.FirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

### Step 5: Android 13+ Notification Permission
The app requests notification permission at runtime (handled by NotificationService).

For testing on Android 13+:
```bash
adb shell pm grant com.example.realgram_app android.permission.POST_NOTIFICATIONS
```

---

## 🍎 iOS Setup

### Step 1: Get APNs Certificates
1. Go to **Firebase Console** → Project Settings → Cloud Messaging
2. Click "Upload APNS Certificates"
3. Go to **Apple Developer Portal** → Certificates, Identifiers & Profiles
4. Create APNs certificate:
   - Development: For testing
   - Production: For App Store

### Step 2: Download Certificate
1. Download `.cer` file from Apple Developer
2. Open Keychain Access
3. Find the certificate → Right-click → Export as `.p8` (recommended) or `.p12`
4. Upload to Firebase Console

### Step 3: Update iOS Project (Xcode)
1. Open `ios/Podfile`:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

2. Open `ios/Runner.xcworkspace` (NOT .xcodeproj):
```
- Select Runner (Project)
- Select Runner (Target)
- Capabilities tab
- Toggle "Push Notifications" ON
- Toggle "Background Modes" → Check "Remote notifications"
- Add "App Groups" capability if needed
```

### Step 4: Info.plist Configuration
Add to `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
    <string>processing</string>
</array>
```

### Step 5: iOS Permission Strings
Add to `ios/Runner/Info.plist`:
```xml
<key>NSUserNotificationUsageDescription</key>
<string>RealGram needs notification permission to keep you updated on new properties and messages</string>
```

---

## 🧪 Testing Push Notifications

### 1. **Test Device Setup**

**Android:**
```bash
# Check if FCM token is printed
flutter run -v | grep "FCM Token"

# Grant notification permission
adb shell pm grant <app-package> android.permission.POST_NOTIFICATIONS
```

**iOS:**
```bash
# Run on physical device (simulator doesn't support remote push)
flutter run -t lib/main.dart
```

### 2. **Using Firebase Console**
1. Firebase Console → Cloud Messaging tab
2. Send Test Message:
   - Select Android/iOS
   - Add FCM token
   - Title: "Test Notification"
   - Body: "This is a test"
   - Click "Send Test Message"

**To find FCM token:**
- Check app logs: `flutter run -v | grep "FCM Token"`
- Check Firestore: `users/{userId}` → `fcmToken` field

### 3. **Using Cloud Functions (Recommended)**
Deploy functions:
```bash
cd functions
npm install
firebase deploy --only functions
```

Then trigger events:
- Create a new lead → Agent gets notification
- Send a chat message → Recipient gets notification
- Get property approved → Owner gets notification

### 4. **Test with curl (Postman Alternative)**
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Content-Type: application/json" \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -d '{
    "notification": {
      "title": "Test Notification",
      "body": "This is a test from curl"
    },
    "to": "DEVICE_FCM_TOKEN"
  }'
```

Get Server Key from:
- Firebase Console → Project Settings → Cloud Messaging tab → Server Key

---

## 📊 Firestore Structure for FCM

### Users Collection
```firestore
users/{userId}
├── fcmToken: "android_token_here"        // Device token
├── notificationSettings: {
│   ├── enablePush: true
│   ├── enableChat: true
│   ├── enableLeads: true
│   └── enableDaily: false
│ }
└── ...other fields
```

---

## 🔔 Notification Types

### 1. New Lead Notification
**When:** Agent receives a new lead
```
Title: 🔥 New Lead!
Body: John Doe is interested in your property
Type: new_lead
```

### 2. New Message Notification
**When:** User receives a chat message
```
Title: 💬 Rajesh Kumar
Body: Thanks for reaching out!
Type: new_message
```

### 3. Property Approval Notification
**When:** Agent's property is approved
```
Title: ✅ Property Approved!
Body: Your property "3BHK in Delhi" is now live
Type: property_approved
```

### 4. Daily Digest Notification
**When:** 8 AM IST (scheduled)
```
Title: 📧 RealGram Daily Update
Body: You have 3 unread messages
Type: daily_digest
```

### 5. Location-Based Notification
**When:** User is near a property
```
Title: 📍 Properties Near You!
Body: Found 2 properties within 1km
Type: nearby_properties
```

---

## ⚠️ Common Issues & Solutions

### Issue 1: "FCM Token is null"
**Cause:** Notification permission was denied
**Solution:** 
- Reinstall app
- Grant notification permission when prompted
- Check Firestore: `users/{userId}` should have `fcmToken`

### Issue 2: "Device token is invalid"
**Cause:** Token expired or corrupted
**Solution:**
```dart
// Force refresh token
final fcmToken = await FirebaseMessaging.instance.deleteToken();
final newToken = await FirebaseMessaging.instance.getToken();
```

### Issue 3: Background notifications not received
**Cause:** Background handler not registered
**Solution:**
- Ensure `_firebaseMessagingBackgroundHandler` is top-level function
- Handler must have `@pragma('vm:entry-point')` on some Flutter versions

### Issue 4: Notifications appear but don't navigate
**Cause:** `onMessageOpenedApp` callback not set
**Solution:**
```dart
FirebaseMessaging.onMessageOpenedApp.listen((message) {
  // Navigate based on message.data['type']
});
```

### Issue 5: iOS notifications not working in production
**Cause:** APNs certificate missing or expired
**Solution:**
1. Check Firebase Console → Cloud Messaging
2. Verify APNs certificate is active
3. Ensure certificate matches Bundle ID

---

## 📱 Testing Matrix

| Feature | Android | iOS | Status |
|---------|---------|-----|--------|
| Foreground notifications | ✅ | ✅ | Ready |
| Background notifications | ✅ | ✅ | Ready |
| Terminated state | ✅ | ✅ | Ready |
| Notification tap | ✅ | ✅ | Ready |
| Custom payload | ✅ | ✅ | Ready |
| Large images | ✅ | ⚠️ | iOS needs iOS 16+ |
| Sound | ✅ | ✅ | Ready |
| Badge | ✅ | ✅ | Ready |
| Scheduled | ⚠️ | ⚠️ | Use Cloud Functions |

---

## 📈 Production Checklist

- [ ] APNs certificates uploaded to Firebase
- [ ] Android App Signing configured
- [ ] Notification permissions requested in app
- [ ] Cloud Functions deployed (`firebase deploy --only functions`)
- [ ] Firestore security rules allow reads/writes
- [ ] Max notification frequency set (avoid spam)
- [ ] Unsubscribe option available in settings
- [ ] Test on physical iOS device
- [ ] Test on Android device with Android 13+
- [ ] Monitor FCM delivery in Firebase Console

---

## 🚀 Deployment

### Deploy Cloud Functions
```bash
cd functions
npm install
firebase deploy --only functions
```

### Deploy to App Stores
```bash
# Android
flutter build apk --release

# iOS  
flutter build ipa --release
```

---

## 📚 References
- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [Flutter FCM Plugin](https://pub.dev/packages/firebase_messaging)
- [Apple Push Notification Service (APNs)](https://developer.apple.com/notification-hub/)

---

## 📞 Support
For issues:
1. Check Firebase Console logs
2. Review Flutter logs: `flutter run -v`
3. Test FCM token validity in Firestore
4. Verify Cloud Functions are deployed: `firebase functions:list`
