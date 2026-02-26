# GitHub Actions APK Build Setup Guide

## Step 1: Initialize Git Repository (LOCAL MACHINE)

Open PowerShell in your project directory and run:

```powershell
cd "C:\Users\Adarsh Kumar Aggu\Downloads\RealGram\realgram_app"

# Initialize git
git init

# Add all files
git add .

# Create first commit
git commit -m "Initial commit: RealGram app with Firebase and notifications"

# Set main branch
git branch -M main
```

---

## Step 2: Create GitHub Repository

1. **Go to GitHub**: https://github.com/new
2. **Create repository**:
   - **Repository name**: `realgram-app` (or your choice)
   - **Description**: Real Estate Social App with Firebase
   - **Public** or **Private** (your choice)
   - ❌ Do NOT initialize with README/gitignore (you already have these)
3. **Click "Create repository"**

You'll see instructions like:
```
git remote add origin https://github.com/YOUR_USERNAME/realgram-app.git
git branch -M main
git push -u origin main
```

---

## Step 3: Push Code to GitHub

Copy and run the commands GitHub shows (replace `YOUR_USERNAME`):

```powershell
cd "C:\Users\Adarsh Kumar Aggu\Downloads\RealGram\realgram_app"

# Add remote (copy exact URL from GitHub)
git remote add origin https://github.com/YOUR_USERNAME/realgram-app.git

# Push to GitHub
git push -u origin main
```

**You'll be prompted for authentication:**
- Option A: **GitHub Personal Access Token** (recommended):
  1. Go to https://github.com/settings/tokens
  2. Click "Generate new token"
  3. Select scopes: `repo`, `workflow`
  4. Copy the token
  5. Paste as password when prompted
  
- Option B: **GitHub CLI** (easiest):
  ```powershell
  # Install GitHub CLI (if not already installed)
  choco install gh -y
  
  # Authenticate
  gh auth login
  # Select: GitHub.com → HTTPS → Authenticate with browser → Authorize
  ```

---

## Step 4: Trigger the Build

Once code is on GitHub:

1. **Go to your repository**: https://github.com/YOUR_USERNAME/realgram-app
2. **Click "Actions" tab** (top navigation)
3. **You should see "Flutter APK Build"** workflow
4. **Click the workflow** → **"Run workflow"** button → **"Run workflow"**

**OR** automatically trigger by pushing code:
```powershell
git add .
git commit -m "Trigger APK build"
git push
```

---

## Step 5: Monitor Build Progress

1. Stay on **Actions** tab
2. Click the running workflow (yellow circle)
3. Watch the build progress in real-time
4. **Build takes 5-10 minutes**

---

## Step 6: Download APK

When build completes (green checkmark ✅):

1. **Scroll down** to "Artifacts" section
2. **Download**:
   - `app-release.apk` (Optimized, ~50MB)
   - `app-debug.apk` (Full debug info, ~80MB)

The APK files are ready to install on Android devices! 🎉

---

## Alternative: Download from Release

If the workflow succeeds:

1. **Click "Releases"** (right sidebar)
2. **Click "Draft"** release
3. **Download APK files** directly

---

## Troubleshooting

### ❌ Build fails in GitHub Actions

**Most common causes**:

1. **Missing Firebase credentials**:
   - Already included in `firebase_options.dart` ✅

2. **Key signing not configured**:
   - Release build tries to sign by default
   - GitHub Actions provides test signing key (fine for testing)

3. **Geolocator plugin errors**:
   - Already commented out in pubspec.yaml ✅

4. **Missing environment files**:
   - .env file not committed
   - Add to git or commit as placeholder

### ✅ How to fix

If build fails:
1. Check **Actions** → **workflow logs** for error details
2. Fix the issue locally
3. Commit and push: `git add . && git commit -m "Fix..." && git push`
4. Workflow re-runs automatically

---

## Next Steps After APK Generated

✅ **Download APK from GitHub Actions**
✅ **Install on Android device**: `adb install app-release.apk`
✅ **Test the app**
✅ **Re-enable geolocator plugin** (currently disabled)
✅ **Rebuild with full features** for production

---

## Future Optimizations

Once working, you can:
- **Auto-upload to Google Play Console**
- **Send Slack notifications** on build completion
- **Create GitHub Releases** automatically
- **Sign APK** with your keystore
- **Run Firebase tests** before building

---

**Build will run on GitHub's Linux servers** ✅  
**No local Developer Mode needed** ✅  
**APK ready for testing** ✅

Questions? Check the workflow logs in the Actions tab for detailed error messages.
