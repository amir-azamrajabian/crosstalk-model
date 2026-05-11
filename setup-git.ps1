# =============================================================================
# setup-git.ps1
# One-time Git initialisation and push script for the Crosstalk Project
#
# USAGE (run from PowerShell as Administrator, or standard PowerShell):
#   cd "E:\Power Electronics\Crosstalk Project"
#   .\setup-git.ps1
#
# WHAT THIS SCRIPT DOES:
#   1. Initialises a local Git repository (if not already done)
#   2. Sets your author identity
#   3. Renames the branch to 'main'
#   4. Adds the GitHub remote
#   5. Stages only the clean source files (.m, .csv, .md, .gitignore, .ps1)
#   6. Creates the initial commit
#   7. Force-pushes to GitHub, overwriting any previous repo content
#
# PRE-REQUISITES:
#   - Git for Windows installed (https://git-scm.com/download/win)
#   - GitHub account: amir-azamrajabian
#   - Either SSH key configured, OR use HTTPS with a Personal Access Token (PAT)
#     when prompted for the password.
#
#   To generate a PAT: GitHub -> Settings -> Developer Settings ->
#   Personal Access Tokens -> Tokens (classic) -> Generate new token
#   (scope: repo)
# =============================================================================

# Do NOT use Stop for native git commands - use $LASTEXITCODE checks instead
$ErrorActionPreference = "Continue"
$ProjectRoot = "E:\Power Electronics\Crosstalk Project"

Write-Host "`n=== Crosstalk Project - Git Setup ===" -ForegroundColor Cyan
Set-Location $ProjectRoot

# --- Step 1: Initialise repo -------------------------------------------------
# Check whether git actually recognises a valid repo (not just whether .git exists)
$repoValid = $false
git rev-parse --git-dir 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) { $repoValid = $true }

if (-Not $repoValid) {
    # Remove any leftover corrupt .git folder before re-initialising
    if (Test-Path ".git") {
        Write-Host "Found broken .git folder - removing and re-initialising..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force ".git"
    }

    # Detect Git version: use -b main flag (Git 2.28+) or symbolic-ref fallback
    $gitVersion = (git --version) -replace "git version ", ""
    $parts = $gitVersion.Split(".")
    $gitMajor = [int]$parts[0]
    $gitMinor = [int]$parts[1]

    if ($gitMajor -gt 2 -or ($gitMajor -eq 2 -and $gitMinor -ge 28)) {
        git init -b main
    } else {
        git init
        git symbolic-ref HEAD refs/heads/main
    }
    Write-Host "[OK] Git repository initialised on branch 'main'." -ForegroundColor Green
} else {
    Write-Host "[OK] Git repository is valid." -ForegroundColor Yellow
    # Ensure branch is named 'main' (harmless if already set)
    git symbolic-ref HEAD refs/heads/main
}

# --- Step 2: Set author identity ---------------------------------------------
git config user.name  "Amir Azam Rajabian"
git config user.email "am.azrajabian@gmail.com"
Write-Host "[OK] Author identity set." -ForegroundColor Green

# (Branch already set to 'main' in Step 1)

# --- Step 4: Set the GitHub remote -------------------------------------------
$RemoteURL = "https://github.com/amir-azamrajabian/crosstalk-model.git"
$existing = git remote 2>&1
if ($existing -match "origin") {
    git remote set-url origin $RemoteURL
    Write-Host "[OK] Remote 'origin' updated." -ForegroundColor Green
} else {
    git remote add origin $RemoteURL
    Write-Host "[OK] Remote 'origin' added." -ForegroundColor Green
}

# --- Step 5: Stage all project files -----------------------------------------
# git add . stages everything not excluded by .gitignore
# The updated .gitignore allows: .opj .DSN .cir .sim .net .out .dat .prb
#   .als .prp .csv .m .md .ps1
# It excludes: .DBK backups, .mrk/.mif/.1OP run artefacts, GPUCache/, images
Write-Host "`nStaging all project files (respecting .gitignore)..." -ForegroundColor Cyan

git add .

Write-Host "[OK] Files staged." -ForegroundColor Green

# --- Show what will be committed ---------------------------------------------
Write-Host "`nFiles to be committed:" -ForegroundColor Cyan
git status --short

# --- Step 6: Initial commit --------------------------------------------------
$timestamp = Get-Date -Format "yyyy-MM-dd"
git commit -m "feat: initial clean repository

Organised MATLAB code, PSpice CSV exports, and full documentation
for the Si-IGBT/SiC-MOSFET phase-leg crosstalk research project.

Publications:
  [C1] PEDSTC 2022  doi:10.1109/PEDSTC53976.2022.9767324
  [C2] EPE 2022     doi:10.1109/EPE22ECCEEurope50083.2022.9907736
  [J1] JESTIE 2024  doi:10.1109/JESTIE.2024.3476274
  [TPEL] In Preparation

Author: Amir Azam Rajabian <am.azrajabian@gmail.com>
Date:   $timestamp"

Write-Host "[OK] Commit created." -ForegroundColor Green

# --- Step 7: Force-push to GitHub --------------------------------------------
Write-Host "`nPushing to GitHub (force - this overwrites remote content)..." -ForegroundColor Yellow
Write-Host "You will be prompted for your GitHub credentials." -ForegroundColor Yellow
Write-Host "Use your Personal Access Token (PAT) as the password.`n" -ForegroundColor Yellow

git push --force origin main

Write-Host "`n=== Done! ===" -ForegroundColor Green
Write-Host "Repository is live at: https://github.com/amir-azamrajabian/crosstalk-model`n" -ForegroundColor Cyan
