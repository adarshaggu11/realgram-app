#!/usr/bin/env powershell
<#
.SYNOPSIS
    Interactive RealGram APK Build Setup
.DESCRIPTION
    This script interactively guides you through pushing code to GitHub and triggering APK build.
#>

$ErrorActionPreference = "Continue"
$projectPath = "C:\Users\Adarsh Kumar Aggu\Downloads\RealGram\realgram_app"

Clear-Host
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  RealGram APK Build - GitHub Actions Setup    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow
if (!(Test-Path $projectPath\.git)) {
    Write-Host "✗ Git not initialized" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Git repository found`n" -ForegroundColor Green

# Get GitHub credentials interactively
Write-Host "STEP 1: GitHub Credentials" -ForegroundColor Yellow
Write-Host "────────────────────────────────────────────────────" -ForegroundColor Gray

Write-Host "`nBefore proceeding, you need:" -ForegroundColor Cyan
Write-Host "  1. GitHub username"
Write-Host "  2. Personal Access Token (created at https://github.com/settings/tokens)`n" -ForegroundColor Gray

$username = Read-Host "GitHub Username"
Write-Host "`n📌 To create a Personal Access Token:" -ForegroundColor Yellow
Write-Host "   1. Go to https://github.com/settings/tokens" 
Write-Host "   2. Click 'Generate new token' → 'Tokens (classic)'"
Write-Host "   3. Name: 'realgram-apk-build'"
Write-Host "   4. Check: 'repo' and 'workflow' scopes"
Write-Host "   5. Click 'Generate token' and copy it`n" -ForegroundColor Gray

$token = Read-Host "Personal Access Token" -AsSecureString
$tokenPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUni($token))

$repoName = Read-Host "`nRepository name (default: realgram-app)" 
if (-not $repoName) { $repoName = "realgram-app" }

Write-Host "`n📌 You also need to create a GitHub repository:" -ForegroundColor Yellow
Write-Host "   1. Go to https://github.com/new"
Write-Host "   2. Name: '$repoName'"
Write-Host "   3. Do NOT initialize with README/gitignore"
Write-Host "   4. Click 'Create repository'`n" -ForegroundColor Gray

$continue = Read-Host "Have you created the GitHub repository? (yes/no)"
if ($continue -ne "yes") {
    Write-Host "`n❌ Please create the repository first at https://github.com/new" -ForegroundColor Red
    exit 1
}

# Step 2: Configure Git Remote
Write-Host "`nSTEP 2: Configuring GitHub..." -ForegroundColor Yellow
Write-Host "────────────────────────────────────────────────────" -ForegroundColor Gray

Set-Location $projectPath

$remoteUrl = "https://${username}:${tokenPlain}@github.com/${username}/${repoName}.git"
git remote remove origin 2>$null | Out-Null
git remote add origin $remoteUrl

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to configure remote" -ForegroundColor Red
    exit 1
}
Write-Host "✓ GitHub remote configured`n" -ForegroundColor Green

# Step 3: Push Code
Write-Host "STEP 3: Pushing code to GitHub..." -ForegroundColor Yellow
Write-Host "────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "Repository: https://github.com/$username/$repoName`n" -ForegroundColor Cyan

git push -u origin main 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Code successfully pushed to GitHub`n" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to push code" -ForegroundColor Red
    Write-Host "Possible issues:" -ForegroundColor Yellow
    Write-Host "  - Invalid token or username"
    Write-Host "  - Repository doesn't exist"
    Write-Host "  - Repository is private but token has limited scope"
    Write-Host "`nTry creating a new token with 'repo' and 'workflow' scopes.`n" -ForegroundColor Gray
    exit 1
}

# Step 4: Trigger Workflow
Write-Host "STEP 4: Triggering GitHub Actions build..." -ForegroundColor Yellow
Write-Host "────────────────────────────────────────────────────" -ForegroundColor Gray

$headers = @{
    "Authorization" = "token $tokenPlain"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "RealGram-APK-Builder"
}

try {
    # Get workflow ID
    $workflowResponse = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/${username}/${repoName}/actions/workflows" `
        -Headers $headers `
        -Method GET -ErrorAction Stop
    
    $workflowId = $workflowResponse.workflows | Where-Object { $_.name -eq "Flutter APK Build" } | Select-Object -ExpandProperty id
    
    if ($workflowId) {
        Invoke-RestMethod `
            -Uri "https://api.github.com/repos/${username}/${repoName}/actions/workflows/${workflowId}/dispatches" `
            -Headers $headers `
            -Method POST `
            -Body (@{ ref = "main" } | ConvertTo-Json) `
            -ContentType "application/json" -ErrorAction Stop | Out-Null
        
        Write-Host "✓ Build workflow triggered successfully`n" -ForegroundColor Green
    } else {
        Write-Host "⚠ Could not find Flutter APK Build workflow" -ForegroundColor Yellow
        Write-Host "Please manually trigger from GitHub Actions tab`n" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠ Could not trigger workflow via API" -ForegroundColor Yellow
    Write-Host "Error: $_" -ForegroundColor Gray
    Write-Host "`nManual trigger: https://github.com/$username/$repoName/actions`n" -ForegroundColor Yellow
}

# Summary
Clear-Host
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║         ✓ Setup Complete!                      ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════╝`n" -ForegroundColor Green

Write-Host "Your APK Build Status:" -ForegroundColor Cyan
Write-Host "📍 https://github.com/$username/$repoName/actions`n" -ForegroundColor Blue

Write-Host "What happens next:" -ForegroundColor Yellow
Write-Host "  1️⃣  Build starts automatically (takes 5-10 minutes)"
Write-Host "  2️⃣  Check GitHub Actions → Flutter APK Build workflow"
Write-Host "  3️⃣  Download APK when build completes (green ✓)`n" -ForegroundColor Green

Write-Host "Download options:" -ForegroundColor Yellow
Write-Host "  📦 From Artifacts: Click workflow → scroll to Artifacts"
Write-Host "  📦 From Releases: https://github.com/$username/$repoName/releases`n" -ForegroundColor Cyan

Write-Host "APK Files:" -ForegroundColor Yellow
Write-Host "  📱 app-release.apk (Production, ~50MB) ← Use this!"
Write-Host "  🐛 app-debug.apk (Debug, ~80MB)`n" -ForegroundColor Green

Write-Host "Next step:" -ForegroundColor Cyan
Write-Host "  → Open Actions tab in your browser (link above)" -ForegroundColor White
Write-Host "  → Watch the build progress`n" -ForegroundColor White

# Cleanup
Remove-Variable tokenPlain -ErrorAction SilentlyContinue

Write-Host "Press Enter to open GitHub Actions in browser..." -ForegroundColor Gray
Read-Host | Out-Null

# Open in browser
Start-Process "https://github.com/$username/$repoName/actions"
