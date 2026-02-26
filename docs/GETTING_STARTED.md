# RealGram - Getting Started Guide

## Welcome! 🎉

You have a **complete Flutter + Firebase real estate app** ready to build. This guide walks you through setup and launch.

---

## STEP 1: Firebase Setup (15 min)

### 1.1 Create Firebase Project
1. Go to **[console.firebase.google.com](https://console.firebase.google.com)**
2. Click "Add Project" → Name it **"realgram"**
3. Skip Google Analytics for now
4. Click "Create Project"

### 1.2 Add Android App to Firebase
1. In Firebase Console, click **"Add app"** → Select **Android**
2. Enter Package Name: `com.realgram.app`
3. Download **`google-services.json`**
4. Place it in: **`android/app/google-services.json`**

### 1.3 Enable Firebase Services
Go to **Firebase Console** and enable:
- ✓ **Authentication** → Provider → Phone
- ✓ **Firestore Database** → Create database (Start in test mode)
- ✓ **Cloud Storage** → Create bucket (Default settings)
- ✓ **Cloud Messaging** (FCM) → Enable
- ✓ **Cloud Functions** → Enable

### 1.4 Setup Firebase CLI Locally
```bash
npm install -g firebase-tools
firebase login
firebase projects:list
```

---

## STEP 2: Configure FlutterFire (10 min)

```bash
cd realgram_app

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure your project
flutterfire configure

# Select your Firebase project: "realgram"
# Select all services when prompted
```

**This generates `lib/firebase_options.dart` automatically**

---

## STEP 3: Get Flutter Dependencies (5 min)

```bash
cd realgram_app
flutter pub get
```

---

## STEP 4: Deploy Cloud Functions (5 min)

```bash
cd functions
npm install
firebase deploy --only functions
```

Check deployment:
```bash
firebase functions:list
firebase functions:log
```

You should see 8 functions deployed:
1. ✓ sendLeadNotificationToAgent
2. ✓ sendMessageNotification
3. ✓ updateAgentLeadStats
4. ✓ incrementPropertyViews
5. ✓ expireBoosts
6. ✓ cleanupOldChats
7. ✓ handlePaymentWebhook
8. ✓ autoApproveProperty

---

## STEP 5: Deploy Firestore Security Rules (3 min)

```bash
firebase deploy --only firestore:rules
```

✓ Security rules are now active: Only approved properties visible, role-based access.

---

## STEP 6: Test on Emulator (10 min)

```bash
# Terminal 1: Start emulator
firebase emulators:start

# Terminal 2: Run app
flutter run
```

**Test OTP**:
- Phone: `+91-9876543210` (use any number)
- Firebase will allow any OTP in test mode
- Check Firestore emulator for user created

---

## STEP 7: First Run on Device

```bash
# Plug in Android device
flutter run
```

The app should:
1. Load with OTP screen
2. Send OTP on submit
3. Allow verification
4. Create user in Firestore
5. Show role selection screen

✓ **You now have auth working!**

---

## STEP 8: Start Building Screens (Day 1 onwards)

### Day 1-2: Auth Screens
Build these screens (templates in `lib/screens/SCREEN_TEMPLATES.dart`):
- [ ] PhoneInputScreen
- [ ] OTPVerificationScreen  
- [ ] RoleSelectionScreen
- [ ] ProfileCompletionScreen

**Reference**: Open `docs/10DAY_EXECUTION_PLAN.md` → Day 2

### Day 3: Property Upload
Build PropertyUploadScreen with:
- [ ] Image picker
- [ ] Location selector
- [ ] Save to Firestore + Storage

**Reference**: Day 3 in execution plan + templates

---

## 📁 Key Files to Know

### Backend (✓ Already Done)
- `lib/models/` - Data models (User, Property, Chat, Lead)
- `lib/services/` - Firebase Auth & Firestore services
- `functions/index.js` - Cloud Functions
- `docs/FIRESTORE_SCHEMA.md` - Database design
- `docs/SECURITY_RULES.md` - Access control

### You Build (⚙️ Start Here)
- `lib/screens/` - UI screens (templates provided)
- `lib/widgets/` - Reusable UI components
- `lib/utils/` - Helper functions, theme, constants

---

## 🧪 Testing Checklist

After each day's work:
- [ ] Run `flutter run` on device
- [ ] Test OTP flow (if auth)
- [ ] Check Firestore console for new data
- [ ] Verify no console errors
- [ ] Check Firebase Functions logs: `firebase functions:log`

---

## 🚨 Common Issues

### Issue: "google-services.json not found"
**Fix**: Download from Firebase Console → Place in `android/app/`

### Issue: "Firestore permission denied"
**Fix**: Security rules are too strict. Use test mode first:
```
Firestore → Rules → switch to test mode (anyone can read/write)
```

### Issue: "FlutterFire configure failed"
**Fix**: 
```bash
dart pub global deactivate flutterfire_cli
dart pub global activate flutterfire_cli
flutterfire configure
```

### Issue: "Cloud Functions deploy failed"
**Fix**: 
```bash
cd functions
npm install firebase-admin firebase-functions
firebase deploy --only functions --force
```

### Issue: "OTP not sending"
**Fix**: 
- Check Firestore → Authentication → Providers → Enable Phone
- In test mode, any OTP works
- In production, test via Firebase phone numbers list

---

## 📋 Development Workflow

Every day:
1. Pick a feature from the 10-day plan
2. Use screen templates as starting point
3. Build & test on device
4. Commit to git: `git add . && git commit -m "Day X: Feature"`
5. Check next day's tasks

---

## 🎯 Example: Building Day 3 (Property Upload)

### Step 1: Copy Template
```dart
// From: lib/screens/SCREEN_TEMPLATES.dart
// Copy PropertyUploadScreen to: lib/screens/property/property_upload_screen.dart
```

### Step 2: Fill in TODOs
```dart
// Replace TODOs with actual Firebase calls:

// TODO: Implement image picker + Firebase Storage upload
Future<void> _pickAndUploadImages() async {
  final ImagePicker picker = ImagePicker();
  final List<XFile>? images = await picker.pickMultiImage();
  // Upload each image to storage using FirestoreService
}

// TODO: Create PropertyModel and save to Firestore
Future<void> _submitProperty() async {
  PropertyModel property = PropertyModel(
    ownerId: currentUser.uid,
    title: _titleController.text,
    // ... other fields
    createdAt: DateTime.now(),
  );
  String propertyId = await firestoreService.saveProperty(property);
}
```

### Step 3: Test on Device
```bash
flutter run
```

### Step 4: Verify Firestore
- Go to **Firebase Console → Firestore**
- Check **properties** collection
- Should see new document with your data

✓ **Feature complete!**

---

## 📊 Daily Progress Checklist

### Day 1: Environment
- [ ] Firebase project created
- [ ] google-services.json placed
- [ ] FlutterFire configured
- [ ] Cloud Functions deployed
- [ ] Security rules deployed
- [ ] `flutter run` works

### Day 2: OTP Auth
- [ ] PhoneInputScreen built
- [ ] OTPVerificationScreen built
- [ ] RoleSelectionScreen built
- [ ] ProfileCompletionScreen built
- [ ] User saved to Firestore
- [ ] Auth provider working

### Day 3: Property Upload
- [ ] PropertyUploadScreen built
- [ ] Image picker working
- [ ] Location picker working
- [ ] Property saved to Firestore
- [ ] Images saved to Storage
- [ ] Geohash calculated

### Days 4-7: Continuing...
Follow the same pattern:
1. Read day's tasks in 10DAY_EXECUTION_PLAN.md
2. Build screens using templates
3. Test on device
4. Move to next day

---

## 🚀 Deployment (Day 10)

### Build Release APK
```bash
flutter build apk --release
# Output: build/app/outputs/apk/release/app-release.apk
```

### Deploy All Firebase Services
```bash
firebase deploy
# Deploys: functions, firestore:rules, hosting
```

### Upload to Google Play Store
1. Create Google Play Developer account ($25 one-time)
2. Create app listing → Upload APK
3. Fill app details, screenshots, etc.
4. Submit for review (takes 2-4 hours)

---

## 💡 Pro Tips

1. **Use Emulator for Testing**
   ```bash
   firebase emulators:start
   ```
   Test locally before deploying

2. **Check Logs Often**
   ```bash
   firebase functions:log
   ```
   Catches errors early

3. **Use Firestore Rules Playground**
   - Go to Firestore → Rules
   - Click "Rules Playground"
   - Test permission rules before deployment

4. **Version Control**
   ```bash
   git init
   git add .
   git commit -m "Initial commit: RealGram setup"
   ```

5. **Monitor Costs**
   - Firestore free tier: $0 for 1000 writes/day
   - Functions: $0 for 2M invocations/month
   - Storage: $0 for 5GB/month
   - Usually free first 2 months

---

## 📞 When You're Stuck

1. **Check the docs**:
   - README.md - Overview
   - 10DAY_EXECUTION_PLAN.md - Daily tasks
   - FIRESTORE_SCHEMA.md - Database questions
   - SECURITY_RULES.md - Permission errors

2. **Check Google**:
   - Firebase documentation: https://firebase.google.com/docs
   - Stack Overflow: Tag [firebase], [flutter]
   - Flutter docs: https://flutter.dev

3. **Test in Emulator**:
   ```bash
   firebase emulators:start
   ```
   All test data is isolated, safe to experiment

---

## ✅ Ready to Launch?

1. ✓ Firebase setup done (Step 1)
2. ✓ FlutterFire configured (Step 2)
3. ✓ Cloud Functions deployed (Step 4)
4. ✓ Security rules deployed (Step 5)
5. Start building screens following 10-day plan

**Next**: Open `docs/10DAY_EXECUTION_PLAN.md` → Start DAY 1

---

## 📱 Test Accounts

Create these for testing:

```json
{
  "admin": {
    "role": "admin",
    "name": "Admin RealGram",
    "verified": true
  },
  "agent": {
    "role": "agent",
    "phone": "+91-9876543210",
    "verified": true,
    "subscriptionType": "agent_pro"
  },
  "buyer": {
    "role": "buyer",
    "phone": "+91-9876543211",
    "verified": true
  }
}
```

Add to Firestore manually in Firebase Console for testing.

---

## 🎊 Congratulations!

You now have:
- ✓ Complete Flutter project setup
- ✓ Firebase backend configured
- ✓ Cloud Functions running
- ✓ Data models ready
- ✓ Security rules active
- ✓ 10-day execution plan

**Time to build! 🚀**

Follow the 10-day plan and you'll have a complete real estate app in 2 weeks.

---

**Questions?** Check `README.md` → Resources → All links provided.

**Ready?** Open `docs/10DAY_EXECUTION_PLAN.md` and START DAY 1 now! 💪
