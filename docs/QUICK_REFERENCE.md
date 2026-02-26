# RealGram - Quick Reference Card

## 🚀 Commands Cheat Sheet

### Setup (First Time)
```bash
dart pub global activate flutterfire_cli
flutterfire configure
flutter pub get
```

### Development
```bash
flutter run                          # Run on device
flutter run -v                       # Verbose (debug)
flutter test                         # Run unit tests
flutter clean && flutter pub get     # Clean cache
```

### Firebase Functions
```bash
firebase deploy --only functions     # Deploy all functions
firebase deploy --only firestore:rules  # Deploy security rules
firebase deploy                      # Deploy everything
firebase functions:log               # View function logs
firebase emulators:start             # Test locally
```

### Build & Release
```bash
flutter build apk --release          # Build APK
flutter build aab --release          # Build App Bundle (Play Store)
flutter build appbundle              # Same as above
```

---

## 📂 Important Files Location

| File | Path | Purpose |
|------|------|---------|
| Models | `lib/models/` | Data classes |
| Services | `lib/services/` | Firebase operations |
| Screens | `lib/screens/` | UI (you build) |
| Security Rules | `firestore.rules` | Access control |
| Cloud Functions | `functions/index.js` | Backend logic |
| Config | `firebase.json` | Firebase settings |
| Dependencies | `pubspec.yaml` | Package list |

---

## 🔑 Service Usage Quick Start

### AuthService
```dart
import 'lib/services/auth_service.dart';
final auth = AuthService();

// Send OTP
await auth.verifyPhoneNumber(
  phoneNumber: '+91...',
  onCodeSent: (verificationId) { },
  onError: (error) { },
);

// Verify OTP
await auth.signInWithOTP('123456');

// Logout
await auth.signOut();
```

### FirestoreService
```dart
import 'lib/services/firestore_service.dart';
final fs = FirestoreService();

// Save property
String id = await fs.saveProperty(propertyModel);

// Get nearby properties
List<Property> nearby = await fs.getNearbyProperties(geohash);

// Send message
await fs.sendMessage(messageModel);

// Get messages stream
fs.getMessages(chatId).listen((messages) { });
```

---

## 🏗️ Directory Structure

```
lib/
├── main.dart                 # Entry point (update for your screens)
├── firebase_init.dart        # Firebase setup
├── models/                   # ✓ Data models (done)
│   ├── user_model.dart
│   ├── property_model.dart
│   ├── chat_model.dart
│   └── lead_model.dart
├── services/                 # ✓ Firebase services (done)
│   ├── auth_service.dart
│   └── firestore_service.dart
├── screens/                  # ⚙️ UI screens (you build)
│   ├── SCREEN_TEMPLATES.dart (copy these)
│   ├── auth/
│   ├── property/
│   ├── chat/
│   └── dashboard/
├── widgets/                  # ⚙️ Reusable UI components
├── utils/                    # ⚙️ Helpers
│   ├── constants.dart
│   ├── theme.dart
│   └── geohash_helper.dart
└── providers/                # ⚙️ State management
    └── auth_provider.dart
```

---

## 📱 Firestore Collections

```
users/{userId}
├── uid: string
├── role: "buyer" | "agent" | "builder" | "admin"
├── name: string
├── phone: string
┕ ... (see FIRESTORE_SCHEMA.md)

properties/{propertyId}
├── ownerId: string
├── title: string
├── price: number
├── geohash: string
├── imageUrls: [string]
└── status: "pending" | "approved"

chats/{chatId}
├── buyerId: string
├── agentId: string
├── messages/ (subcollection)
│   └── {messageId}
│       ├── text: string
│       ├── timestamp: date
│       └── senderId: string
└── ...

leads/{leadId}
├── propertyId: string
├── buyerId: string
├── agentId: string
├── status: string
└── ...
```

---

## 🔐 Firestore Security Rules Quick Reference

| Collection | Create | Read | Update | Delete |
|-----------|--------|------|--------|--------|
| users | Own | Own | Own | Own |
| properties | Auth | Approved + Own | Own | Own + Admin |
| chats | Auth | Participants | Participants | - |
| messages | Participants | Participants | - | - |
| leads | Buyers | Participants | Agent | - |

---

## 🧪 Firebase Emulator

```bash
# Start emulator
firebase emulators:start

# Run app pointing to emulator
flutter run

# In Firebase Console:
# Firestore → Rules → Emulator tab
# Test rules before deployment
```

---

## ⚠️ Common Errors & Quick Fixes

| Error | Fix |
|-------|-----|
| `google-services.json not found` | Download from Firebase Console → Place in `android/app/` |
| `Permission denied` on Firestore | Check `firestore.rules` or use test mode temporarily |
| `No FCM token` for notifications | Store token in users collection: `fcmToken` field |
| `Image upload fails` | Check Firebase Storage rules + internet |
| `OTP not sending` | Check Firebase Auth → Phone provider enabled |
| `Functions deploy fails` | Run `cd functions && npm install && firebase deploy --only functions` |

---

## 📊 Firestore Query Patterns

### Get nearby properties
```dart
final nearby = await fs.getNearbyProperties(
  geohashPrefix: 'ttnf',  // From user's location
  limit: 20,
);
```

### Get user's listings
```dart
final properties = await fs.getPropertiesByOwner(userId);
```

### Stream user's chats
```dart
fs.getUserChats(userId).listen((chats) {
  // Updates in real-time
});
```

### Get agent's leads
```dart
final leads = await fs.getLeadsForAgent(agentId);
```

---

## 🎯 10-Day Timeline (At-A-Glance)

- **Day 1**: Setup + Firebase config
- **Day 2**: OTP Auth screens
- **Day 3**: Property upload
- **Day 4**: Geo-feed
- **Day 5**: Property detail
- **Day 6**: Chat system
- **Day 7**: Leads + Dashboard
- **Day 8**: Admin panel
- **Day 9**: Push notifications
- **Day 10**: Payments + Deploy

---

## 📚 Documentation Map

```
docs/
├── GETTING_STARTED.md ← START HERE (Setup)
├── 10DAY_EXECUTION_PLAN.md (Daily tasks)
├── FIRESTORE_SCHEMA.md (Database help)
├── SECURITY_RULES.md (Permission issues)
├── DEVELOPMENT.md (This overview)
└── README.md (Quick ref)
```

---

## 🔗 Important Links

- **Firebase Console**: https://console.firebase.google.com
- **Flutter Docs**: https://flutter.dev/docs
- **Firebase Docs**: https://firebase.google.com/docs
- **Firestore Guide**: https://firebase.google.com/docs/firestore

---

## 💾 Git Commands

```bash
# Initialize git
git init

# Add files
git add .

# Commit
git commit -m "Day X: Description"

# Check status
git status

# View history
git log --oneline
```

---

## 🚨 Before Deployment

- [ ] Test all screens on device
- [ ] Verify OTP flow works
- [ ] Test property upload
- [ ] Check notifications work
- [ ] Verify security rules
- [ ] Load test with dummy data
- [ ] Check Firebase logs: `firebase functions:log`
- [ ] Verify all edge cases handled

---

## 💡 Pro Tips

1. **Use const constructors** - Better performance
2. **Test in emulator first** - Before deploying functions
3. **Check Firebase logs** - `firebase functions:log`
4. **Use Firestore playground** - Test rules before deployment
5. **Monitor Firestore usage** - Keep below free tier limits
6. **Use .limit() on queries** - Reduce read costs
7. **Batch operations** - Multiple writes together
8. **Archive old data** - Cleanup old chats monthly

---

## 🎓 Learning Checklist

- [ ] Understand Firestore collections structure
- [ ] Know how geohash works for location search
- [ ] Familiar with Firebase Auth OTP flow
- [ ] Know how Cloud Functions auto-trigger
- [ ] Understand security rules syntax
- [ ] Know Flutter Provider for state management
- [ ] Familiar with async/await in Dart
- [ ] Know how to use streams for realtime data

---

## 🆘 When You're Stuck

1. **Check logs**: `firebase functions:log`
2. **Read the docs**: `docs/` folder
3. **Test in emulator**: `firebase emulators:start`
4. **Check Firestore console**: See data
5. **Review templates**: `lib/screens/SCREEN_TEMPLATES.dart`
6. **Search Stack Overflow**: Tag [firebase] [flutter]

---

## ✅ Launch Checklist (Day 10)

- [ ] All screens built
- [ ] Database working
- [ ] Functions deployed
- [ ] Notifications tested
- [ ] Security rules deployed
- [ ] APK built: `flutter build apk --release`
- [ ] Signed: Use Android Studio or CLI
- [ ] Test on device
- [ ] Play Store listing created
- [ ] **DEPLOY!**

---

## 📞 Quick Support

| Issue | Where to Find Answer |
|-------|---------------------|
| Firebase setup | `docs/GETTING_STARTED.md` |
| Daily tasks | `docs/10DAY_EXECUTION_PLAN.md` |
| Database queries | `docs/FIRESTORE_SCHEMA.md` |
| Permission errors | `docs/SECURITY_RULES.md` |
| Code examples | `lib/screens/SCREEN_TEMPLATES.dart` |
| Project overview | `README.md` or this file |

---

## 🎊 Remember

- **You have everything you need**
- **The path is clear (10-day plan)**
- **Templates are provided**
- **Documentation is complete**
- **Backend is production-ready**

**Just follow the plan and build! 💪🚀**

---

**Print this page or bookmark it for quick reference!**

_RealGram - Ready to Launch_
