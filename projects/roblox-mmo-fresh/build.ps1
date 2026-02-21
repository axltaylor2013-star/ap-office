# Build script for fresh Roblox MMO project
# Removes BOM and builds .rbxlx file

Write-Host "=== Building Roblox MMO Fresh Start ===" -ForegroundColor Cyan

# Step 1: Strip BOM from Lua files
Write-Host "1. Stripping BOM from Lua files..." -ForegroundColor Yellow
$files = Get-ChildItem -Path . -Filter *.lua -Recurse

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    # Check if file starts with BOM
    $hasBom = $content.StartsWith([char]0xFEFF) -or $content.StartsWith([char]0xFFFE)
    
    if ($hasBom) {
        Write-Host "   Removing BOM from: $($file.Name)" -ForegroundColor Red
        $content = $content.TrimStart([char]0xFEFF).TrimStart([char]0xFFFE)
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.UTF8Encoding]::new($false))
    }
}

# Step 2: Build with Rojo
Write-Host "2. Building with Rojo..." -ForegroundColor Yellow
& "C:\Users\alfre\bin\rojo.exe" build -o build.rbxlx

if ($LASTEXITCODE -eq 0) {
    $fileSize = (Get-Item "build.rbxlx").Length / 1KB
    Write-Host "   Build successful! File: build.rbxlx ($($fileSize.ToString('0.0')) KB)" -ForegroundColor Green
} else {
    Write-Host "   Build failed!" -ForegroundColor Red
    exit 1
}

# Step 3: Show summary
Write-Host "3. Project Summary:" -ForegroundColor Yellow
Write-Host "   - MapSetup.server.lua: Creates terrain and spawn area"
Write-Host "   - PlayerSpawn.server.lua: Handles player spawning"
Write-Host "   - Spawn position: Y=3.5 (on platform above ground)"
Write-Host "   - Ready for testing in Roblox Studio" -ForegroundColor Green

Write-Host "`n=== Build Complete ===" -ForegroundColor Cyan
Write-Host "Open 'build.rbxlx' in Roblox Studio and test Play mode" -ForegroundColor White