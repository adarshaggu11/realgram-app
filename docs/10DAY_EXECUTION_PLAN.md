# RealGram - 10-Day Fast Execution Plan

## Launch Configuration
- **App**: RealGram (Real Estate Social)
- **First City**: Delhi
- **Property Types**: All (plots, apartments, houses, commercial)
- **Model**: Free first → premium features later
- **Admin Approval**: Yes, manual verification required
- **Reels Feed**: Phase 2 (after launch)

---

## DAY 1: Flutter Environment & Firebase Setup

### Time: 8 hours

**Tasks:**
- [ ] Install Flutter SDK (if not done)
- [ ] Setup Android Studio + Emulator
- [ ] Run `flutter doctor` ✓
- [ ] Create Firebase project in Console
- [ ] Create Android app in Firebase
- [ ] Download `google-services.json` → place in `android/app/`
- [ ] Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
- [ ] Run `flutterfire configure` → select all services
- [ ] Update `pubspec.yaml` with Firebase + geo dependencies ✓
- [ ] Run `flutter pub get`
- [ ] Test Firebase connection with simple Firestore read

**Deliverables:**
- Flutter project ready
- Firebase project connected
- All dependencies installed

---

## DAY 2: OTP Authentication Module

### Time: 6 hours

**Tasks:**
- [ ] Create `AuthService` class (firebase_auth) ✓
- [ ] Create OTP verification screen (UI)
- [ ] Create role selection screen (buyer/agent/builder)
- [ ] Create `UserModel` Firestore schema ✓
- [ ] On OTP success → save user data to `users` collection
- [ ] Create Auth Provider (State Management)
- [ ] Setup Firebase Security Rules for users collection ✓
- [ ] Test OTP flow end-to-end

**Screens to Build:**
1. `PhoneInputScreen` - Enter phone number
2. `OTPVerificationScreen` - Enter 6-digit OTP
3. `RoleSelectionScreen` - Select buyer/agent/builder
4. `ProfileCompletionScreen` - Name, location, city

**Firebase Collections:**
- `users` - created with schema ✓

**Deliverables:**
- Complete auth flow working
- Users saved in Firestore
- Ready for buyer/agent separation

---

## DAY 3: Property Upload Module

### Time: 7 hours

**Tasks:**
- [ ] Create `PropertyModel` with Firestore schema ✓
- [ ] Create `FirestoreService` class ✓
- [ ] Build Property Upload screen UI:
  - [ ] Title, description, price
  - [ ] Property type dropdown
  - [ ] Multiple image picker
  - [ ] Location picker (GPS + map)
  - [ ] Area size input
  - [ ] Amenities checkbox list
- [ ] Implement image upload to Firebase Storage:
  - [ ] Compress images before upload
  - [ ] Show upload progress
- [ ] Generate Geohash from lat/lng
- [ ] Save property to Firestore with geohash
- [ ] Show upload success message

**Dependencies:**
- `image_picker`
- `geolocator`
- `geohash`
- `firebase_storage`

**Deliverables:**
- Property upload flow complete
- Images stored in Storage
- Properties in Firestore with geohash

---

## DAY 4: Geo-Based Feed (Nearby Properties)

### Time: 6 hours

**Tasks:**
- [ ] Implement location permission request
- [ ] Get user's current GPS location
- [ ] Generate geohash from user location
- [ ] Implement geohash-based Firestore query
- [ ] Create property feed UI:
  - [ ] Grid/List view of nearby properties
  - [ ] Property card design (image, price, location)
  - [ ] Distance calculation
- [ ] Add filters:
  - [ ] Property type
  - [ ] Price range
  - [ ] Area size
- [ ] Add pull-to-refresh
- [ ] Show loading skeleton

**Dependencies:**
- `geoflutterfire2` (or manual geohash query)
- `google_maps_flutter`

**Firestore Query:**
```
properties where geohash >= "ttnf" AND geohash < "ttnfz"
  AND status == "approved"
  orderBy createdAt DESC
  limit 20
```

**Deliverables:**
- Buyers see 20 nearby properties
- Auto-updates based on location

---

## DAY 5: Property Detail Page

### Time: 5 hours

**Tasks:**
- [ ] Create PropertyDetailScreen:
  - [ ] Image slider (PageView)
  - [ ] Property info (title, price, type, area)
  - [ ] Full description
  - [ ] Amenities list
  - [ ] Owner contact card (name, rating)
  - [ ] Google Map view
  - [ ] Similar properties carousel
- [ ] Add action buttons:
  - [ ] "Contact Agent" → Create Lead + Chat
  - [ ] "Save" → Add to favorites (Firestore)
  - [ ] "Share" → Share property link
  - [ ] "Report" → Flag listing
- [ ] Implement Google Maps integration
- [ ] Track property views (increment counter)

**Dependencies:**
- `google_maps_flutter`
- `smooth_page_indicator`

**Deliverables:**
- Full property details UI
- Contact agent flow ready for Day 6

---

## DAY 6: Chat & Messaging System

### Time: 7 hours

**Tasks:**
- [ ] Create `ChatModel` with schema ✓
- [ ] Create `MessageModel` with schema ✓
- [ ] Build ChatScreen UI:
  - [ ] Message list (realtime)
  - [ ] Input field with send button
  - [ ] Date separators
  - [ ] Typing indicator
- [ ] Implement Firestore realtime listeners:
  - [ ] `getMessages(chatId)` stream
  - [ ] `sendMessage(message)` function
  - [ ] Update `lastMessage` in chat
- [ ] Create ChatListScreen:
  - [ ] All chats for user
  - [ ] Last message preview
  - [ ] Unread badge
  - [ ] Swipe to archive
- [ ] Auto-create Lead when chat starts

**Firestore Structure:**
```
chats/{chatId}
  └── messages/{messageId}
```

**Deliverables:**
- Realtime messaging working
- Chat list with notifications ready (day 9)

---

## DAY 7: Leads & Agent Dashboard

### Time: 8 hours

### Part A: Lead Creation
- [ ] Create lead when:
  - [ ] "Contact Agent" clicked
  - [ ] Chat started
  - [ ] Schedule visit
- [ ] Lead sources: contact_button, chat_started, schedule_visit
- [ ] Save to `leads` collection

### Part B: Agent Dashboard
- [ ] Build `AgentHomeScreen`:
  - [ ] My Listings count & list
  - [ ] Leads received count & list
  - [ ] Earnings/stats (if premium feature)
- [ ] Build `MyListingsScreen`:
  - [ ] Grid of own properties
  - [ ] Edit property
  - [ ] Delete property
  - [ ] View count
  - [ ] Boost property (payment integration - Day 10)
- [ ] Build `LeadsScreen`:
  - [ ] Filter by status (new, contacted, visited, interested, rejected, closed)
  - [ ] Lead detail with buyer info
  - [ ] Update status
  - [ ] Notes field
  - [ ] Quick contact action

**Deliverables:**
- Agents can manage listings & leads

---

## DAY 8: Admin Panel (Firebase Hosting)

### Time: 4 hours

**Options:**
1. **Flutter Web** (1-2 hours)
   - Same Flutter codebase
   - Admin role-specific screens
   
2. **HTML + JS + Firebase SDK** (2-3 hours)
   - Simpler, lighter
   - Recommended

### Tasks (HTML Option):
- [ ] Create `index.html` dashboard
- [ ] List pending properties approval
- [ ] Approve/Reject buttons
- [ ] Verify agent accounts
- [ ] Delete fake listings
- [ ] Feature/Unfeature listings
- [ ] View analytics (total users, listings)
- [ ] Deploy to Firebase Hosting: `firebase deploy`

**Deliverables:**
- Admin can approve properties
- Listings go live after approval

---

## DAY 9: Push Notifications & Cloud Functions

### Time: 5 hours

### Part A: FCM Setup ✅ COMPLETE
- [x] Enable FCM in Firebase Console
- [x] Get Server Key from Firebase Console
- [x] Request notification permission in Flutter app
- [x] Store FCM token in users collection
- [x] Create NotificationService class
- [x] Initialize notifications in main.dart
- [x] Handle foreground/background/terminated states
- [x] Setup local notifications for offline messages

**Files Created/Modified:**
- `lib/services/notification_service.dart` - Complete FCM service
- `lib/main.dart` - Initialize notifications
- `lib/models/user_model.dart` - Added fcmToken field
- `lib/screens/auth/profile_completion_screen.dart` - Save token on profile complete
- `docs/FCM_SETUP_GUIDE.md` - Complete setup guide

**Notification Types Implemented:**
1. New Lead Notification (Agent receives lead)
2. New Message Notification (Chat message received)
3. Property Approval Notification (Owner property approved)
4. Daily Digest (Scheduled 8 AM IST)
5. Location-Based Notifications (Properties near user)

### Part B: Cloud Functions ✅ COMPLETE
Deploy 8 functions:
- [x] Send FCM on New Lead (leads/{leadId} onCreate)
- [x] Send FCM on New Message (chats/{chatId}/messages/{messageId} onCreate)
- [x] Notify on Property Approval (properties/{propertyId} onUpdate)
- [x] Send Daily Digest (pubsub schedule every day 08:00)
- [x] Update FCM Token on Change (tracking)
- [x] Cleanup Invalid Tokens (weekly)
- [x] Location-Based Notifications (callable function)
- [x] Razorpay Payment Webhook (for Day 10)

**Deploy:**
```bash
cd functions
npm install
firebase deploy --only functions
firebase functions:list  # Verify deployment
```

**Testing:**
- Firebase Console → Cloud Messaging → Send test message
- Trigger events (new lead, message, approval)
- Check logs: `firebase functions:log`

**Deliverables:**
- ✅ Notifications sent on new leads & messages
- ✅ Background jobs running
- ✅ FCM tokens stored and updated
- ✅ Token cleanup scheduled weekly
- ✅ Complete setup documentation
- ✅ Zero compilation errors

---

## DAY 10: Payments & Deployment

### Time: 6 hours

### Part A: Razorpay Integration (Flutter)
- [ ] Install `razorpay_flutter`
- [ ] Add Razorpay Key ID from dashboard
- [ ] Build Boost Listing screen:
  - [ ] Select boost level (1-5)
  - [ ] Show cost: ₹100/level
  - [ ] Open Razorpay checkout
  - [ ] Payment success → trigger Cloud Function
- [ ] Build Subscription screen (optional for Phase 2)

### Part B: Deployment
- [ ] Build APK: `flutter build apk --release`
- [ ] Test on device
- [ ] Deploy Cloud Functions (if not done in Day 9)
- [ ] Deploy Firestore rules: `firebase deploy --only firestore:rules`
- [ ] Setup Firebase Hosting for admin panel

```bash
# Generate Release APK
flutter build apk --release

# Deploy functions & rules
firebase deploy --only functions,firestore:rules

# Deploy admin panel
firebase deploy --only hosting
```

**Deliverables:**
- Release APK ready for upload to Google Play Store
- All backend services live
- Ready for soft launch

---

## AFTER DAY 10: Pre-Launch Checklist

- [ ] Test end-to-end flows on real devices
- [ ] Verify all notifications work
- [ ] Test payment flow with test cards
- [ ] Load test with dummy data
- [ ] Onboard 50 agents with sample listings
- [ ] Create admin account
- [ ] Setup app marketing assets
- [ ] Create app store listing
- [ ] Setup analytics (Firebase Analytics)

---

## TIMELINE SUMMARY

| Day | Focus | Hours | Status |
|-----|-------|-------|--------|
| 1 | Env + Firebase | 8 | Setup |
| 2 | OTP Auth | 6 | Foundation |
| 3 | Property Upload | 7 | Core |
| 4 | Geo Feed | 6 | Core |
| 5 | Property Detail | 5 | MVP |
| 6 | Chat System | 7 | MVP |
| 7 | Leads + Dashboard | 8 | MVP |
| 8 | Admin Panel | 4 | Supporting |
| 9 | Notifications | 5 | Polish |
| 10 | Payments + Deploy | 6 | Launch |
| **Total** | | **62 hours** | **Ready** |

---

## PARALLEL WORK (Can Start After Day 2)

- Design marketing landing page
- Prepare agent onboarding docs
- Create tutorial videos
- Setup analytics dashboard
- Design push notification templates

---

## COST ESTIMATE (First Month)

| Service | Cost | Notes |
|---------|------|-------|
| Firebase (Firestore) | $0-50 | Free tier usually enough |
| Storage | $0-10 | 1GB free / month |
| Functions | $0-20 | 2M free invocations/month |
| Hosting | $0-5 | Free tier available |
| **Total** | **~$50-100** | Scales with growth |

---

## ROLLOUT PHASES

### Phase 1 (Day 10): Soft Launch
- One city (Delhi)
- 50 agents + 200 listings
- Invite-only or limited signup
- Monitor performance & bugs

### Phase 2 (Week 3-4): Expand
- Add reels feed
- Open to all buyers
- Add more cities
- Premium features (boost, featured listing)

### Phase 3 (Month 2): Premium
- Agent subscription plan
- Advanced analytics
- Lead management tools
- Ads system

---

## SUCCESS METRICS

Target by end of Month 1:
- [ ] 1000+ downloads
- [ ] 500+ registered users
- [ ] 200+ active listings
- [ ] 50+ daily active users
- [ ] <2s app load time
- [ ] <1% crash rate

---

## Next Steps

1. ✓ Create Flutter project
2. ✓ Setup Firestore schema
3. ✓ Create data models
4. ✓ Create services (Auth, Firestore)
5. ✓ Create Cloud Functions
6. Start building UI screens (Day 1 env)

**Ready to code? Start with Day 1!**
