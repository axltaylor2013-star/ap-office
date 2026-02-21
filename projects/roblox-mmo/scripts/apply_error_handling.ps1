# PowerShell script to apply error handling fixes to Roblox MMO project

Write-Host "Applying comprehensive error handling fixes..." -ForegroundColor Green

# Define paths
$projectRoot = "C:\Users\alfre\.openclaw\workspace\projects\roblox-mmo"
$srcDir = Join-Path $projectRoot "src"

# Files to update with error handling
$filesToUpdate = @(
    "ServerScriptService\CombatManager.server.lua",
    "ServerScriptService\FletchingManager.server.lua",
    "ServerScriptService\MonsterManager.server.lua",
    "ServerScriptService\RangedCombatManager.server.lua",
    "ServerScriptService\TradeManager.server.lua",
    "StarterPlayerScripts\FletchingUI.client.lua",
    "StarterPlayerScripts\RangedCombat.client.lua",
    "StarterPlayerScripts\HealthBar.client.lua",
    "StarterPlayerScripts\MiniMap.client.lua"
)

# Function to add error handling imports
function Add-ErrorHandlerImport {
    param([string]$filePath)
    
    $content = Get-Content $filePath -Raw
    $lines = $content -split "`n"
    
    # Check if ErrorHandler is already imported
    if ($content -match "local ErrorHandler") {
        return $false
    }
    
    # Find a good place to add the import (after other requires)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "require.*Modules") {
            # Add ErrorHandler import after this line
            $newLines = @()
            $newLines += $lines[0..$i]
            $newLines += 'local ErrorHandler = require(Modules:WaitForChild("ErrorHandler"))'
            $newLines += $lines[($i+1)..($lines.Count-1)]
            
            $newContent = $newLines -join "`n"
            Set-Content -Path $filePath -Value $newContent -NoNewline
            return $true
        }
    }
    
    # If no require found, add at top
    $newContent = 'local ErrorHandler = require(Modules:WaitForChild("ErrorHandler"))' + "`n" + $content
    Set-Content -Path $filePath -Value $newContent -NoNewline
    return $true
}

# Function to replace WaitForChild with SafeWaitForChild
function Update-WaitForChildCalls {
    param([string]$filePath)
    
    $content = Get-Content $filePath -Raw
    $updated = $false
    
    # Pattern 1: :WaitForChild("name")
    if ($content -match ':WaitForChild\("([^"]+)"\)') {
        $content = $content -replace ':WaitForChild\("([^"]+)"\)', ':WaitForChild("$1", 5)'
        $updated = $true
    }
    
    # Pattern 2: :WaitForChild(variable)
    if ($content -match ':WaitForChild\((\w+)\)') {
        $content = $content -replace ':WaitForChild\((\w+)\)', ':WaitForChild($1, 5)'
        $updated = $true
    }
    
    if ($updated) {
        Set-Content -Path $filePath -Value $content -NoNewline
    }
    
    return $updated
}

# Function to add nil checks to critical variables
function Add-NilChecks {
    param([string]$filePath)
    
    $content = Get-Content $filePath -Raw
    $lines = $content -split "`n"
    $updated = $false
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Look for common patterns that need nil checks
        if ($line -match '(\w+)\.(\w+)\s*=' -and $line -notmatch 'local') {
            $varName = $matches[1]
            
            # Check if this variable is used without nil check
            for ($j = $i+1; $j -lt $lines.Count; $j++) {
                if ($lines[$j] -match "$varName\." -and $lines[$j] -notmatch "if.*$varName") {
                    # Add nil check before this line
                    $checkLine = "if $varName then"
                    $lines[$j] = "    " + $lines[$j]
                    
                    $newLines = @()
                    $newLines += $lines[0..($j-1)]
                    $newLines += $checkLine
                    $newLines += $lines[$j]
                    $newLines += "end"
                    $newLines += $lines[($j+1)..($lines.Count-1)]
                    
                    $lines = $newLines
                    $updated = $true
                    break
                }
            }
        }
    }
    
    if ($updated) {
        $newContent = $lines -join "`n"
        Set-Content -Path $filePath -Value $newContent -NoNewline
    }
    
    return $updated
}

# Main update process
Write-Host "Updating files with error handling..." -ForegroundColor Yellow

foreach ($relativePath in $filesToUpdate) {
    $filePath = Join-Path $srcDir $relativePath
    
    if (Test-Path $filePath) {
        Write-Host "  Processing: $relativePath" -ForegroundColor Cyan
        
        $importAdded = Add-ErrorHandlerImport $filePath
        $waitForChildUpdated = Update-WaitForChildCalls $filePath
        $nilChecksAdded = Add-NilChecks $filePath
        
        if ($importAdded -or $waitForChildUpdated -or $nilChecksAdded) {
            Write-Host "    ✓ Updated" -ForegroundColor Green
        } else {
            Write-Host "    ○ No changes needed" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ✗ File not found: $relativePath" -ForegroundColor Red
    }
}

# Create a test script to verify error handling
$testScript = @'
-- ErrorHandlerTest.server.lua
-- Test script to verify error handling is working

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules", 5)
local ErrorHandler = require(Modules:WaitForChild("ErrorHandler", 5))

print("=== Error Handler Test ===")

-- Test 1: Logging functions
ErrorHandler:LogInfo("Test info message")
ErrorHandler:LogWarning("Test warning message")

-- Test 2: SafeWaitForChild with timeout
local nonExistent = ErrorHandler:SafeWaitForChild(ReplicatedStorage, "NonExistentChild", 1)
if nonExistent == nil then
    print("✓ SafeWaitForChild timeout works correctly")
else
    print("✗ SafeWaitForChild timeout failed")
end

-- Test 3: ValidateNotNil
local testValue = ErrorHandler:ValidateNotNil(nil, {context = "test"}, "default")
if testValue == "default" then
    print("✓ ValidateNotNil fallback works")
else
    print("✗ ValidateNotNil failed")
end

-- Test 4: SafeDataStoreOperation (simulated)
local dataStoreResult = ErrorHandler:SafeDataStoreOperation("TestOperation", function()
    error("Simulated DataStore failure")
end, "fallback_value")

if dataStoreResult == "fallback_value" then
    print("✓ SafeDataStoreOperation fallback works")
else
    print("✗ SafeDataStoreOperation failed")
end

print("=== Test Complete ===")
'@

$testScriptPath = Join-Path $srcDir "ServerScriptService\ErrorHandlerTest.server.lua"
Set-Content -Path $testScriptPath -Value $testScript

Write-Host "`nCreated test script: ErrorHandlerTest.server.lua" -ForegroundColor Green

# Update project.json to include ErrorHandler module
$projectJsonPath = Join-Path $projectRoot "project.json"
if (Test-Path $projectJsonPath) {
    $projectJson = Get-Content $projectJsonPath -Raw | ConvertFrom-Json
    
    # Check if ErrorHandler is already in tree
    $errorHandlerFound = $false
    function Check-Tree {
        param($node)
        
        if ($node.className -eq "ModuleScript" -and $node.name -eq "ErrorHandler") {
            return $true
        }
        
        if ($node.children) {
            foreach ($child in $node.children) {
                if (Check-Tree $child) {
                    return $true
                }
            }
        }
        
        return $false
    }
    
    $errorHandlerFound = Check-Tree $projectJson.tree
    
    if (-not $errorHandlerFound) {
        Write-Host "Warning: ErrorHandler not found in project.json tree" -ForegroundColor Yellow
        Write-Host "You may need to add it manually to the ReplicatedStorage/Modules folder" -ForegroundColor Yellow
    }
}

Write-Host "`nError handling update complete!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Rebuild project with: rojo build -o build.rbxlx" -ForegroundColor Cyan
Write-Host "2. Test in Roblox Studio" -ForegroundColor Cyan
Write-Host "3. Run ErrorHandlerTest.server.lua to verify" -ForegroundColor Cyan