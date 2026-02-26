#!/usr/bin/env powershell
<#
.SYNOPSIS
    RealGram GitHub Actions APK Build Automation
.DESCRIPTION
    This script automates the process of pushing code to GitHub and triggering the APK build.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$GitHubUsername,
    
    [Parameter(Mandatory=$true)]
    [string]$PersonalAccessToken,
    
    [string]$RepositoryName = "realgram-app"
)

$ErrorActionPreference = "Stop"
$projectPath = "C:\Users\Adarsh Kumar Aggu\Downloads\RealGram\realgram_app"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RealGram APK Build Automation" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: Verify we're in the right directory
Write-Host "✓ Project Path: $projectPath`n" -ForegroundColor Green
Set-Location $projectPath

# Step 2: Check git status
Write-Host "[1/5] Checking git repository..." -ForegroundColor Yellow
if (!(Test-Path .git)) {
    Write-Host "✗ Git not initialized!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Git repository found`n" -ForegroundColor Green

# Step 3: Configure git credentials (use token for HTTPS)
Write-Host "[2/5] Configuring GitHub credentials..." -ForegroundColor Yellow
$remoteUrl = "https://${GitHubUsername}:${PersonalAccessToken}@github.com/${GitHubUsername}/${RepositoryName}.git"
git remote remove origin 2>$null
git remote add origin $remoteUrl
Write-Host "✓ GitHub remote configured`n" -ForegroundColor Green

# Step 4: Push code to GitHub
Write-Host "[3/5] Pushing code to GitHub..." -ForegroundColor Yellow
Write-Host "Repository: https://github.com/${GitHubUsername}/${RepositoryName}" -ForegroundColor Cyan
try {
    git push -u origin main --force
    Write-Host "✓ Code successfully pushed to GitHub`n" -ForegroundColor Green
} catch {
    Write-Host "✗ Push failed: $_`n" -ForegroundColor Red
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "- Verify GitHub username is correct: $GitHubUsername"
    Write-Host "- Verify Personal Access Token is valid"
    Write-Host "- Verify repository exists: https://github.com/${GitHubUsername}/${RepositoryName}"
    exit 1
}

# Step 5: Trigger workflow
Write-Host "[4/5] Triggering GitHub Actions build..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "token ${PersonalAccessToken}"
    "Accept" = "application/vnd.github.v3+json"
}

try {
    # Get the workflow ID
    $workflowResponse = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/${GitHubUsername}/${RepositoryName}/actions/workflows" `
        -Headers $headers `
        -Method GET
    
    $workflowId = $workflowResponse.workflows | Where-Object { $_.name -eq "Flutter APK Build" } | Select-Object -ExpandProperty id
    
    if ($workflowId) {
        # Trigger the workflow
        Invoke-RestMethod `
            -Uri "https://api.github.com/repos/${GitHubUsername}/${RepositoryName}/actions/workflows/${workflowId}/dispatches" `
            -Headers $headers `
            -Method POST `
            -Body (@{ ref = "main" } | ConvertTo-Json) `
            -ContentType "application/json" | Out-Null
        
        Write-Host "✓ Build workflow triggered`n" -ForegroundColor Green
    } else {
        Write-Host "! Warning: Could not automatically trigger workflow" -ForegroundColor Yellow
        Write-Host "  Please manually trigger from Actions tab: https://github.com/${GitHubUsername}/${RepositoryName}/actions`n" -ForegroundColor Yellow
    }
} catch {
    Write-Host "! Warning: Could not trigger workflow via API: $_" -ForegroundColor Yellow
    Write-Host "  Please manually trigger from Actions tab: https://github.com/${GitHubUsername}/${RepositoryName}/actions`n" -ForegroundColor Yellow
}

# Step 5: Wait and show monitoring instructions
Write-Host "[5/5] APK Build Status" -ForegroundColor Yellow
Write-Host "============================================`n" -ForegroundColor Cyan
Write-Host "Workflow Status: https://github.com/${GitHubUsername}/${RepositoryName}/actions" -ForegroundColor Cyan
Write-Host "`nBuild will take approximately 5-10 minutes.`n" -ForegroundColor Green

Write-Host "What to expect:" -ForegroundColor Yellow
Write-Host "1. Go to Actions tab on GitHub"
Write-Host "2. Click on 'Flutter APK Build' workflow"
Write-Host "3. Watch the build progress (takes 5-10 minutes)"
Write-Host "4. Download APK files when build completes (green checkmark)"
Write-Host "`nAPK files will be available as:" -ForegroundColor Yellow
Write-Host "  - app-release.apk (Production build, ~50MB)"
Write-Host "  - app-debug.apk (Debug build, ~80MB)`n" -ForegroundColor Cyan

Write-Host "Alternatively, download from Releases:" -ForegroundColor Yellow
Write-Host "https://github.com/${GitHubUsername}/${RepositoryName}/releases`n" -ForegroundColor Cyan

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup Complete! ✓" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
