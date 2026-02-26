# 🚀 Automated APK Build - Complete Guide

## Prerequisites

✅ **Git is initialized** (already done)  
✅ **GitHub Actions workflow ready** (already created)  
✅ **Automation script ready** (auto-push-and-build.ps1)

---

## Step 1: Create GitHub Personal Access Token (2 minutes)

### 1.1 Go to GitHub Settings
1. Open: https://github.com/settings/tokens
2. Click **"Generate new token"** (top right)
3. Select **"Tokens (classic)"**

### 1.2 Configure Token Permissions
- **Token name**: `realgram-apk-build`
- **Expiration**: 90 days (or longer)
- **Scopes** - Check these boxes:
  - ✅ `repo` (full control of repositories)
  - ✅ `workflow` (update GitHub Actions)
  - ✅ `write:packages` (optional)

### 1.3 Generate and Copy Token
1. Click **"Generate token"**
2. **COPY the token immediately** (you won't see it again!)
3. Keep it safe - it's like a password

**Example token format** (yours will look different):
```
ghp_1234abcd5678efgh9012ijkl3456mnop7890
```

---

## Step 2: Create GitHub Repository (2 minutes)

### 2.1 Create New Repository
1. Go to: https://github.com/new
2. Fill in:
   - **Repository name**: `realgram-app`
   - **Description**: Real Estate Social App with Firebase
   - **Public** (easier for testing) or **Private** (your choice)
   - ✅ Set to empty (don't initialize with README)
3. Click **"Create repository"**

### 2.2 Note Your GitHub Username
You'll see your repo at: `https://github.com/YOUR_USERNAME/realgram-app`  
Save `YOUR_USERNAME` for the script

---

## Step 3: Run the Automation Script (1 minute)

### 3.1 Open PowerShell
```powershell
# Navigate to project
cd "C:\Users\Adarsh Kumar Aggu\Downloads\RealGram\realgram_app"

# Run the automation script
powershell -ExecutionPolicy Bypass -File .\auto-push-and-build.ps1 -GitHubUsername YOUR_USERNAME -PersonalAccessToken ghp_xxxxxxxxxxxx
```

### 3.2 Replace with YOUR Values
- `YOUR_USERNAME`: Your GitHub username
- `ghp_xxxxxxxxxxxx`: The token you copied in Step 1

**Example** (not real):
```powershell
powershell -ExecutionPolicy Bypass -File .\auto-push-and-build.ps1 -GitHubUsername adarsh-kumar -PersonalAccessToken ghp_1234abcd5678efgh9012
```

---

## Step 4: Monitor the Build (5-10 minutes)

### 4.1 Watch GitHub Actions
1. Go to: `https://github.com/YOUR_USERNAME/realgram-app/actions`
2. Click on the running workflow
3. Watch the build progress in real-time

### 4.2 Build Stages (What You'll See)
```
✓ Checkout code
✓ Setup Java
✓ Setup Flutter
✓ Get dependencies
✓ Build APK Release
✓ Build APK Debug
✓ Upload artifacts
```

---

## Step 5: Download Your APK 🎉

### 5.1 When Build Completes (Green Checkmark ✅)

**Option A: From Artifacts**
1. Go to Actions tab → Click the completed workflow
2. Scroll to **"Artifacts"** section
3. Download:
   - `app-release.apk` (Production - use this!)
   - `app-debug.apk` (Debug info)

**Option B: From Releases**
1. Go to: `https://github.com/YOUR_USERNAME/realgram-app/releases`
2. Click the draft release
3. Download APK files

### 5.2 Verify APK
```powershell
# Check APK size
ls -l "C:\path\to\app-release.apk"

# Should be around 50-70MB
```

---

## Troubleshooting

### ❌ "Token authentication failed"
- ✓ Verify token is copied correctly (no extra spaces)
- ✓ Token hasn't expired (create a new 90-day token)
- ✓ Username is correct (case-sensitive on GitHub)

### ❌ "Repository not found"
- ✓ Make sure you created the GitHub repo first
- ✓ Repository name should be exactly: `realgram-app`
- ✓ Check the URL: `https://github.com/YOUR_USERNAME/realgram-app`

### ❌ "Workflow not found"
- ✓ Go to Actions tab manually
- ✓ Click "Run workflow" → "Run workflow" button
- ✓ It will trigger the build

### ❌ "Build fails in GitHub Actions"
- ✓ Check the workflow logs for error details
- ✓ Common fixes already applied to the code
- ✓ Usually takes 1-2 more attempts to succeed

---

## Complete Automation Flow

```
┌─────────────────────────────────┐
│ Step 1: Get PAT Token           │  ← 2 min
│ (github.com/settings/tokens)    │
└──────────────┬──────────────────┘
               ↓
    ┌──────────────────────┐
    │ Step 2: Create Repo  │  ← 2 min
    │ (github.com/new)     │
    └──────────┬───────────┘
               ↓
    ┌─────────────────────────────┐
    │ Step 3: Run Script          │  ← 1 min
    │ auto-push-and-build.ps1     │
    └──────────┬──────────────────┘
               ↓
    ┌──────────────────────────────┐
    │ Step 4: Watch Build          │  ← 5-10 min
    │ GitHub Actions (in browser)  │
    └──────────┬───────────────────┘
               ↓
    ┌──────────────────────────────┐
    │ Step 5: Download APK ✅      │  ← Done!
    │ From Artifacts or Releases   │
    └──────────────────────────────┘
```

---

## What Happens When You Run the Script

```powershell
# The script will:
1. Verify project directory ✓
2. Check git repository ✓
3. Configure GitHub credentials ✓
4. Push code to GitHub ✓
5. Trigger GitHub Actions workflow ✓
6. Show you the monitoring URL ✓
```

---

## Next Steps After APK Download

1. **Transfer to Android Device**:
   ```powershell
   adb install app-release.apk
   ```

2. **Test the App**:
   - Launch RealGram on your phone
   - Test Firebase login
   - Check push notifications
   - Verify maps work

3. **Enable Geolocator** (currently disabled):
   - Uncomment in pubspec.yaml
   - Re-enable imports
   - Rebuild APK for full features

4. **Deploy to Play Store**:
   - Sign APK with your keystore
   - Upload to Google Play Console
   - Submit for review

---

## Security Notes

⚠️ **Never share your Personal Access Token**
- Store securely
- Can revoke anytime from GitHub settings
- Only valid for this repository

✅ **Good practices**:
- Use token only on trusted machines
- Set expiration date (90 days recommended)
- Delete old tokens you no longer use

---

## Need Help?

1. **Script fails?** → Check GitHub token and username
2. **Build fails?** → Check workflow logs in Actions tab
3. **APK won't install?** → Check Android version (min SDK 21)
4. **Feature not working?** → Geolocator temporarily disabled (re-enable after)

---

**You're ready! Follow Steps 1-5 above and your APK will be ready in ~20 minutes total.**
