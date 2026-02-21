# PowerShell script to strip UTF-8 BOM from Lua files
# BOM causes Roblox scripts to fail silently

Write-Host "Stripping BOM from Lua files..." -ForegroundColor Yellow

$files = Get-ChildItem -Path . -Filter *.lua -Recurse

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    # Check if file starts with BOM (EF BB BF)
    $hasBom = $content.StartsWith([char]0xFEFF) -or $content.StartsWith([char]0xFFFE)
    
    if ($hasBom) {
        Write-Host "  Removing BOM from: $($file.FullName)" -ForegroundColor Red
        
        # Remove BOM by reading as ASCII/UTF8 without BOM
        $content = $content.TrimStart([char]0xFEFF).TrimStart([char]0xFFFE)
        
        # Write back without BOM
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.UTF8Encoding]::new($false))
    }
}

Write-Host "BOM stripping complete!" -ForegroundColor Green