# Simple verification script for fresh build

Write-Host "=== Verifying Roblox MMO Fresh Build ===" -ForegroundColor Cyan

$errorList = @()

# Check 1: Required files exist
Write-Host "1. Checking required files..." -ForegroundColor Yellow
$requiredFiles = @(
    "default.project.json",
    "build.rbxlx",
    "src\ServerScriptService\MapSetup.server.lua",
    "src\ServerScriptService\PlayerSpawn.server.lua",
    "README.md",
    "TEST_PLAN.md"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "   [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "   [ERROR] $file (MISSING)" -ForegroundColor Red
        $errorList += "Missing file: $file"
    }
}

# Check 2: Lua files don't have BOM
Write-Host "2. Checking Lua files for BOM..." -ForegroundColor Yellow
$luaFiles = Get-ChildItem -Path . -Filter *.lua -Recurse

foreach ($file in $luaFiles) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $hasBom = $bytes.Count -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
    
    if ($hasBom) {
        Write-Host "   [ERROR] $($file.Name) has BOM" -ForegroundColor Red
        $errorList += "File has BOM: $($file.Name)"
    } else {
        Write-Host "   [OK] $($file.Name) (no BOM)" -ForegroundColor Green
    }
}

# Check 3: Build file size is reasonable
Write-Host "3. Checking build file..." -ForegroundColor Yellow
if (Test-Path "build.rbxlx") {
    $fileSize = (Get-Item "build.rbxlx").Length
    if ($fileSize -gt 1000) {
        $sizeKB = [math]::Round($fileSize / 1KB, 1)
        Write-Host "   [OK] build.rbxlx ($sizeKB KB)" -ForegroundColor Green
    } else {
        Write-Host "   [ERROR] build.rbxlx is too small ($fileSize bytes)" -ForegroundColor Red
        $errorList += "Build file is too small"
    }
}

# Check 4: Project JSON has $ignoreUnknownInstances
Write-Host "4. Checking project configuration..." -ForegroundColor Yellow
if (Test-Path "default.project.json") {
    $jsonContent = Get-Content "default.project.json" -Raw
    if ($jsonContent -match '\"\$ignoreUnknownInstances\"\s*:\s*true') {
        Write-Host "   [OK] default.project.json has proper ignoreUnknownInstances" -ForegroundColor Green
    } else {
        Write-Host "   [ERROR] default.project.json missing ignoreUnknownInstances" -ForegroundColor Red
        $errorList += "Missing ignoreUnknownInstances in project.json"
    }
}

# Summary
Write-Host "`n=== Verification Summary ===" -ForegroundColor Cyan

if ($errorList.Count -eq 0) {
    Write-Host "[SUCCESS] ALL CHECKS PASSED" -ForegroundColor Green
    Write-Host "The build is ready for testing in Roblox Studio" -ForegroundColor White
    Write-Host "`nNext steps:"
    Write-Host "1. Open 'build.rbxlx' in Roblox Studio"
    Write-Host "2. Check Output window for script messages"
    Write-Host "3. Enter Play mode to test spawning"
    Write-Host "4. Follow TEST_PLAN.md for complete testing"
} else {
    Write-Host "[FAILURE] FOUND $($errorList.Count) ISSUES:" -ForegroundColor Red
    foreach ($err in $errorList) {
        Write-Host "   - $err" -ForegroundColor Red
    }
    Write-Host "`nPlease fix these issues before testing." -ForegroundColor Yellow
    exit 1
}