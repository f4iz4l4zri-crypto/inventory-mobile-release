# PowerShell Script: Automate APK Release with Git LFS & GitHub Release
# Usage: .\release_apk.ps1 -ApkPath "path/to/app-release.apk" -Changelog "changelog.txt" -Tag "v2026-04-01"

param(
    [string]$ApkPath = "",
    [string]$Changelog = "",
    [string]$Tag = ""
)

if (-not $ApkPath -or -not (Test-Path $ApkPath)) {
    Write-Host "[ERROR] APK file not found: $ApkPath" -ForegroundColor Red
    exit 1
}

# Versioning: Copy APK with date tag
date = Get-Date -Format "yyyyMMdd-HHmm"
$dest = "updates/app-release-$date.apk"
Copy-Item $ApkPath $dest -Force
Write-Host "[INFO] APK copied to $dest"

# Git add, commit, push (LFS)
git add $dest
$commitMsg = "Release APK $date"
git commit -m $commitMsg
Write-Host "[INFO] Git commit: $commitMsg"
git push
Write-Host "[INFO] Git push completed"

# Optional: Create GitHub Release (requires gh CLI)
if ($Tag) {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Host "[WARN] GitHub CLI (gh) not found. Skipping GitHub Release upload."
    } else {
        $releaseTitle = "Release $Tag"
        $releaseNotes = if ($Changelog -and (Test-Path $Changelog)) { Get-Content $Changelog -Raw } else { $commitMsg }
        gh release create $Tag $dest --title "$releaseTitle" --notes "$releaseNotes"
        Write-Host "[INFO] GitHub Release created: $Tag"
    }
}
