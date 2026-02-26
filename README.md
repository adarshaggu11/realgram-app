# RealGram - Real Estate Social App

### Flutter + Firebase + Geo-Location

Complete developer execution kit for building a scalable real estate social app. All backend infrastructure, data models, and 10-day execution plan included.

---

## ⚡ Quick Start (5 min)

```bash
# 1. Install dependencies
cd realgram_app
flutter pub get

# 2. Configure Firebase
flutterfire configure

# 3. Deploy Cloud Functions & Rules
cd functions && npm install && firebase deploy --only functions
firebase deploy --only firestore:rules

# 4. Run app
flutter run
```

---

## 📁 What's Included (✓ DONE)

### Backend Configuration
✓ **Firestore Schema** - 5 collections with production indexes  
✓ **Security Rules** - Role-based access (buyer/agent/builder/admin)  
✓ **Cloud Functions** - 8 auto-running functions (notifications, leads, views)  
✓ **Firebase Auth** - Phone OTP with Firebase Authentication  
✓ **Cloud Storage** - Image upload pipeline setup  

### Data Models
✓ **UserModel** - Users with roles and subscriptions  
✓ **PropertyModel** - Listings with geohash for geo-queries  
✓ **ChatModel & MessageModel** - Realtime messaging  
✓ **LeadModel** - Sales lead tracking  

### Services
✓ **AuthService** - Firebase Phone Auth  
✓ **FirestoreService** - Complete CRUD for all collections  

### Documentation
✓ **FIRESTORE_SCHEMA.md** - Complete database design  
✓ **SECURITY_RULES.md** - Production security rules  
✓ **10DAY_EXECUTION_PLAN.md** - Day-by-day tasks + timeline  
✓ **Screen Templates** - Ready-to-customize Flutter screens  

---

## 📂 Project Structure

```
realgram_app/
├── lib/
│   ├── models/
│   │   ├── user_model.dart ✓
│   │   ├── property_model.dart ✓
│   │   ├── chat_model.dart ✓
│   │   └── lead_model.dart ✓
│   ├── services/
│   │   ├── auth_service.dart ✓
│   │   └── firestore_service.dart ✓
│   ├── screens/
│   │   └── SCREEN_TEMPLATES.dart ✓
│   ├── widgets/ (build these)
│   └── utils/
├── functions/
│   ├── index.js ✓ (8 Cloud Functions)
│   └── package.json ✓
├── docs/
│   ├── FIRESTORE_SCHEMA.md ✓
│   ├── SECURITY_RULES.md ✓
│   └── 10DAY_EXECUTION_PLAN.md ✓
├── pubspec.yaml ✓ (all dependencies)
└── README.md
```

---

## 🎯 12-Features Included

1. **OTP Phone Authentication** - Firebase Auth
2. **Role-based system** - Buyer, Agent, Builder, Admin
3. **Property Upload** - Images, location, details to Firestore
4. **Geo-Feed** - Nearby properties using geohash
5. **Property Details** - Full info + Google Maps
6. **Chat System** - Realtime Firestore messaging
7. **Lead Management** - Auto-trigger on contact/chat
8. **Agent Dashboard** - Own listings & leads
9. **Push Notifications** - FCM for leads & messages
10. **Payment Integration** - Razorpay ready
11. **Admin Panel** - Property approval & verification
12. **Security** - Firestore rules + role checks

---

## 🚀 10-Day Execution Plan

| Day | Task | Hours | Status |
|-----|------|-------|--------|
| 1 | Firebase + Flutter Setup | 8 | 📋 Setup |
| 2 | OTP Authentication | 6 | 🔑 Auth |
| 3 | Property Upload | 7 | 📸 Upload |
| 4 | Geo-Feed | 6 | 📍 Feed |
| 5 | Property Detail | 5 | 🏠 Detail |
| 6 | Chat System | 7 | 💬 Chat |
| 7 | Leads + Dashboard | 8 | 📊 Dashboard |
| 8 | Admin Panel | 4 | ⚙️ Admin |
| 9 | Notifications | 5 | 🔔 Push |
| 10 | Payments + Deploy | 6 | 💳 Launch |
| | **TOTAL** | **62** | **🚀 LIVE** |

**Start Here:** Open `docs/10DAY_EXECUTION_PLAN.md` for detailed daily tasks

---

## 🔥 Firebase Setup (Required)

### 1. Create Firebase Project
```
firebase.google.com → New Project → "RealGram"
```

### 2. Add Android App
```
Project Settings → Add App → Android
Download google-services.json → Place in android/app/
```

### 3. Enable Services
- ✓ Authentication (Phone)
- ✓ Firestore Database
- ✓ Cloud Storage
- ✓ Cloud Functions
- ✓ Cloud Messaging (FCM)

### 4. Initialize Functions
```bash
firebase init functions
# Choose JavaScript
# Select your project
```

### 5. Deploy Rules
```bash
firebase deploy --only firestore:rules
```

---

## 💡 Key Services

### AuthService
```dart
final authService = AuthService();
await authService.verifyPhoneNumber('+919XXXXXXXXX');
```

### FirestoreService
```dart
final fs = FirestoreService();
String propertyId = await fs.saveProperty(property);
List<PropertyModel> nearby = await fs.getNearbyProperties(geohash);
```

### Cloud Functions
- **sendLeadNotificationToAgent** - New lead → FCM to agent
- **sendMessageNotification** - New message → FCM to recipient
- **incrementPropertyViews** - Track property interest
- **expireBoosts** - Auto-reset boost level after expiry
- **handlePaymentWebhook** - Payment → Subscription/Boost update
- ... and 3 more

---

## 📋 What You Build

### Screens to Create (Using Templates)
1. `PhoneInputScreen` - Enter phone ✓ template
2. `OTPVerificationScreen` - Enter OTP
3. `RoleSelectionScreen` - Choose role
4. `PropertyUploadScreen` - Upload listing ✓ template
5. `GeoFeedScreen` - Nearby properties ✓ template
6. `PropertyDetailScreen` - Full details
7. `ChatListScreen` - Chat conversations
8. `ChatDetailScreen` - Messages
9. `AgentDashboardScreen` - Agent home
10. `AdminPanelScreen` - Approval UI

Templates provided in `lib/screens/SCREEN_TEMPLATES.dart`

---

## 📊 Database Schema Preview

### Collections
- **users** - User profiles with roles
- **properties** - Listings with geohash indexing
- **chats** - Chat rooms with messages subcollection
- **leads** - Sales leads for agents
- **Storage** - Images in `/properties/{propertyId}/`

### Security Rules
- ✓ Only approved properties are public
- ✓ Users can only edit own profile
- ✓ Only verified agents can create listings
- ✓ Chat only visible to participants
- ✓ Admin override access

See `docs/SECURITY_RULES.md` for complete rules

---

## 🎨 Customization

### Branding
- App name: **RealGram** (change in `pubspec.yaml`)
- Colors: Update in `lib/utils/theme.dart`
- Fonts: Add to `assets/fonts/`

### Geolocation
- Default city: **Delhi** (change in constants)
- Geohash precision: **7** (adjust in helper)
- Search radius: **50km** (configurable)

### Monetization
- Free listing + Premium boost
- Agent subscription: `agent_pro` role
- Start free, add payments in Phase 2

---

## 🧪 Testing

### Firestore Emulator (Local Testing)
```bash
firebase emulators:start
```

### Test User Accounts
```
Agent:
  Phone: +91-98XXXXXX00
  Role: agent

Buyer:
  Phone: +91-99XXXXXX00
  Role: buyer

Admin:
  Email: admin@realgram.com (manual set)
```

---

## 📈 Performance

### Firestore Optimization
- All queries have `.limit()` (default 20)
- Geohash indexes for fast proximity search
- Message pagination (load 20 at a time)
- Cloud Functions batch operations

### App Optimization
- Lazy load images with caching
- Use `const` constructors
- Minimize widget rebuilds with Provider
- Stream data for real-time updates

---

## ⚡ Deployment

### Build APK
```bash
flutter build apk --release
# Output: build/app/outputs/apk/release/app-release.apk
```

### Deploy Functions
```bash
firebase deploy --only functions
```

### Deploy Hosting (Admin Panel)
```bash
firebase deploy --only hosting
```

### Upload to Google Play
```
Play Console → Create Release → Upload APK
```

---

## 📚 Documentation

- **10DAY_EXECUTION_PLAN.md** - Day-by-day roadmap
- **FIRESTORE_SCHEMA.md** - Database design + queries
- **SECURITY_RULES.md** - Access control rules
- **SCREEN_TEMPLATES.dart** - Ready code templates

---

## 🤝 Support

- Flutter: [flutter.dev](https://flutter.dev)
- Firebase: [firebase.google.com/docs](https://firebase.google.com/docs)
- Provider: [pub.dev/packages/provider](https://pub.dev/packages/provider)
- Geohash: [pub.dev/packages/geohash](https://pub.dev/packages/geohash)

---

## 📊 Project Metrics

- **Team**: 1-2 developers
- **Timeline**: 10 days to MVP
- **Target Launch**: 1 city, 200 listings
- **Monthly Active Users**: 1000+ (target month 1)
- **Firestore Cost**: ~$50-100/month (free tier first 2mo)

---

## 🎯 Next Steps

1. **Setup Firebase** - Follow FIREBASE SETUP section
2. **Deploy Cloud Functions** - `firebase deploy`
3. **Create Auth Screens** - Use SCREEN_TEMPLATES.dart
4. **Follow 10-day plan** - `docs/10DAY_EXECUTION_PLAN.md`
5. **Test on device** - `flutter run`
6. **Deploy to Play Store** - Build APK + upload

---

## ✅ Launch Checklist

- [ ] Firebase configured
- [ ] Cloud Functions deployed
- [ ] Security rules deployed
- [ ] All screens built
- [ ] End-to-end testing done
- [ ] 50 agents onboarded
- [ ] 200 test listings created
- [ ] Notifications tested
- [ ] Payment integration tested
- [ ] APK signed & built
- [ ] Play Store listing created
- [ ] **LAUNCH! 🚀**

---

## 💬 Features Roadmap

### Phase 1 (Week 1) - MVP ✓
- OTP Auth, Properties, Geo-Feed, Chat, Leads

### Phase 2 (Week 3-4)
- Reels feed, Premium features, Analytics

### Phase 3 (Month 2+)
- AI recommendations, Algolia search, Multi-city

---

**RealGram - Built with Flutter + Firebase. Ready to Launch! 🚀**

---

## License

This project is provided as-is for RealGram. Modify and deploy freely.
