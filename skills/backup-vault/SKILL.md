---
name: backup-vault
description: Automated workspace snapshots — versioned, compressed, restorable. One command to back up, one command to restore any point in time.
---

# Backup Vault

## Paths

- **Workspace:** `C:\Users\alfre\.openclaw\workspace`
- **Backup dir:** `C:\Users\alfre\backups\openclaw\`
- **Manifest:** `C:\Users\alfre\backups\openclaw\manifest.json`

## Exclusions

Always exclude from backups:

```
node_modules/
venv/
.git/
__pycache__/
*.pyc
media/inbound/
.env
*.tmp
*.log
```

Custom exclusions can be added to `C:\Users\alfre\backups\openclaw\exclusions.txt` (one pattern per line).

## Commands

### Backup Workspace (Full)

**Triggers:** "Backup workspace" / "Full backup" / "Snapshot everything"

1. Check disk space (warn if < 1GB free on backup drive)
2. Create backup dir if needed
3. Collect all workspace files (respecting exclusions)
4. Create `backup-YYYY-MM-DD-HHMMSS-full.zip`
5. Generate metadata and add to zip
6. Update manifest
7. Report summary

```powershell
# Ensure backup directory exists
New-Item -ItemType Directory -Force -Path "C:\Users\alfre\backups\openclaw"

# Get current git hash (if available)
$gitHash = git -C "C:\Users\alfre\.openclaw\workspace" rev-parse --short HEAD 2>$null

# Build exclusion patterns
$excludePatterns = @('node_modules', 'venv', '.git', '__pycache__', '*.pyc', 'media\inbound', '.env', '*.tmp', '*.log')

# Collect files (exclude patterns)
$workspace = "C:\Users\alfre\.openclaw\workspace"
$allFiles = Get-ChildItem -Path $workspace -Recurse -File | Where-Object {
    $rel = $_.FullName.Substring($workspace.Length + 1)
    $dominated = $false
    foreach ($p in $excludePatterns) {
        if ($rel -like "*$p*") { $dominated = $true; break }
    }
    -not $dominated
}

# Create zip
$timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
$zipName = "backup-$timestamp-full.zip"
$zipPath = "C:\Users\alfre\backups\openclaw\$zipName"
Compress-Archive -Path $allFiles.FullName -DestinationPath $zipPath -CompressionLevel Optimal

# Report
$zipSize = (Get-Item $zipPath).Length
$fileCount = $allFiles.Count
Write-Host "✅ Full backup: $zipName ($fileCount files, $([math]::Round($zipSize/1MB, 2)) MB)"
```

### Backup Specific Directory (Selective)

**Triggers:** "Backup dashboard/" / "Backup skills/" / "Back up cartoon/"

Same as full but scoped to a specific subdirectory.

- Zip name: `backup-YYYY-MM-DD-HHMMSS-selective-{dirname}.zip`
- Same exclusion rules apply
- Metadata notes which directory was backed up

```powershell
# Example for "dashboard"
$targetDir = "dashboard"
$workspace = "C:\Users\alfre\.openclaw\workspace"
$sourcePath = Join-Path $workspace $targetDir

$allFiles = Get-ChildItem -Path $sourcePath -Recurse -File | Where-Object {
    $rel = $_.FullName.Substring($workspace.Length + 1)
    $dominated = $false
    foreach ($p in $excludePatterns) {
        if ($rel -like "*$p*") { $dominated = $true; break }
    }
    -not $dominated
}

$timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
$zipName = "backup-$timestamp-selective-$targetDir.zip"
$zipPath = "C:\Users\alfre\backups\openclaw\$zipName"
Compress-Archive -Path $allFiles.FullName -DestinationPath $zipPath -CompressionLevel Optimal
```

### Incremental Backup

**Triggers:** "Incremental backup" / "Backup changes only"

Only files modified since the last backup (any type).

1. Read manifest → find latest backup timestamp
2. Collect files with `LastWriteTime` after that timestamp
3. Zip name: `backup-YYYY-MM-DD-HHMMSS-incremental.zip`
4. If no files changed, report "Nothing changed since last backup"

```powershell
# Get last backup time from manifest
$manifest = Get-Content "C:\Users\alfre\backups\openclaw\manifest.json" | ConvertFrom-Json
$lastBackup = ($manifest.backups | Sort-Object timestamp -Descending | Select-Object -First 1).timestamp
$since = [datetime]::Parse($lastBackup)

# Find changed files
$changedFiles = $allFiles | Where-Object { $_.LastWriteTime -gt $since }

if ($changedFiles.Count -eq 0) {
    Write-Host "ℹ️ No files changed since last backup ($lastBackup)"
} else {
    # Create incremental zip
    $zipName = "backup-$timestamp-incremental.zip"
    Compress-Archive -Path $changedFiles.FullName -DestinationPath "C:\Users\alfre\backups\openclaw\$zipName"
}
```

### List Backups

**Triggers:** "List backups" / "Show backups" / "Backup history"

Read manifest and display formatted table:

```
📦 Backup Vault — 12 backups (847 MB total)

ID  | Date                | Type        | Size    | Files | Description
----|---------------------|-------------|---------|-------|------------------
12  | 2026-02-15 14:30    | full        | 89 MB   | 342   | Full workspace
11  | 2026-02-14 09:00    | selective   | 12 MB   | 45    | dashboard/
10  | 2026-02-13 22:15    | incremental | 3 MB    | 8     | 8 files changed
...
```

Optional filters:
- "List backups from last week" → filter by date range
- "List full backups" → filter by type
- "List backups matching dashboard" → filter by description

### Restore Backup

**Triggers:** "Restore backup 7" / "Restore backup from Feb 14" / "Restore latest backup"

**⚠️ ALWAYS confirm before restoring.**

Steps:
1. Find backup by ID or date (closest match)
2. Show what will be restored (dry run preview)
3. **Ask user for confirmation**
4. Create safety backup of current state: `backup-YYYY-MM-DD-HHMMSS-pre-restore.zip`
5. Extract to workspace (or custom path if specified)
6. Report what was restored

```
🔍 Found: Backup #7 — 2026-02-14 09:00 (full, 89 MB, 342 files)

📋 Dry run — files that will be restored:
  - dashboard/hub.html (will overwrite — modified since backup)
  - dashboard/revenue.json (will overwrite — modified since backup)
  - skills/backup-vault/SKILL.md (identical, skip)
  ... and 339 more files

⚠️ This will overwrite 45 files in the workspace.
🔒 A safety backup will be created first.

Proceed? (yes/no)
```

Restore to custom path:
- "Restore backup 7 to C:\temp\restore-test" → extracts there instead

### Verify Backup

**Triggers:** "Verify latest backup" / "Verify backup 5" / "Check backup integrity"

1. Test zip can be opened: `Expand-Archive -Path $zip -DestinationPath $temp -WhatIf` or use `[System.IO.Compression.ZipFile]::OpenRead()`
2. Count files in zip, compare to manifest entry
3. Report result

```
🔍 Verifying backup #12 (backup-2026-02-15-143000-full.zip)...

✅ Zip integrity: OK
✅ File count: 342 (matches manifest)
✅ Size: 89 MB (matches manifest)
📅 Created: 2026-02-15 14:30:00
```

### Compare with Current Workspace

**Triggers:** "What changed since last backup?" / "Diff since backup" / "Compare backup"

1. Get latest backup timestamp from manifest
2. Find all files modified after that timestamp (respecting exclusions)
3. Report changes

```
📊 Changes since last backup (2026-02-15 14:30):

Modified (3):
  - dashboard/hub.html (2.1 KB → 2.4 KB)
  - skills/backup-vault/SKILL.md (new file)
  - MEMORY.md (+15 lines)

New (1):
  - cartoon/episode5.json

Deleted (0): none

Summary: 3 modified, 1 new, 0 deleted
```

### Clean Old Backups (Retention)

**Triggers:** "Clean old backups, keep last 10" / "Delete backups older than 30 days" / "Backup retention"

1. Read manifest
2. Sort by date, identify backups to remove
3. **Never delete the last remaining backup**
4. Show what will be deleted, ask confirmation
5. Delete zip files and update manifest

```
🧹 Retention: Keep last 10 backups

Will delete 5 backups (312 MB):
  #1 — 2026-01-10 (full, 78 MB)
  #2 — 2026-01-12 (incremental, 2 MB)
  #3 — 2026-01-15 (full, 80 MB)
  #4 — 2026-01-18 (selective, 15 MB)
  #5 — 2026-01-20 (full, 82 MB)

⚠️ Confirm deletion? (yes/no)
```

## Manifest Format

`C:\Users\alfre\backups\openclaw\manifest.json`:

```json
{
  "version": 1,
  "backups": [
    {
      "id": 1,
      "timestamp": "2026-02-15T14:30:00",
      "type": "full",
      "description": "Full workspace backup",
      "filename": "backup-2026-02-15-143000-full.zip",
      "path": "C:\\Users\\alfre\\backups\\openclaw\\backup-2026-02-15-143000-full.zip",
      "sizeBytes": 93323264,
      "fileCount": 342,
      "gitHash": "a3f7b2c",
      "directories": ["*"],
      "metadata": {
        "workspacePath": "C:\\Users\\alfre\\.openclaw\\workspace",
        "exclusions": ["node_modules/", "venv/", ".git/", "__pycache__/", "*.pyc", "media/inbound/"]
      }
    }
  ]
}
```

## Metadata File (inside each zip)

Every backup zip includes `_backup_metadata.json` at the root:

```json
{
  "timestamp": "2026-02-15T14:30:00",
  "type": "full",
  "workspace": "C:\\Users\\alfre\\.openclaw\\workspace",
  "fileCount": 342,
  "totalSizeBytes": 156000000,
  "gitHash": "a3f7b2c",
  "gitBranch": "main",
  "exclusions": ["node_modules/", "venv/", ".git/", "__pycache__/", "*.pyc", "media/inbound/"],
  "directories": ["*"],
  "description": "Full workspace backup"
}
```

## Safety Rules

1. **ALWAYS create a safety backup before any restore** — named `backup-*-pre-restore.zip`
2. **ALWAYS confirm before restore** — show dry run, wait for explicit "yes"
3. **Never delete the last remaining backup** — refuse and explain why
4. **Check disk space before backup** — warn if backup drive has < 1GB free:
   ```powershell
   $drive = (Get-PSDrive -Name C)
   $freeGB = [math]::Round($drive.Free / 1GB, 2)
   if ($freeGB -lt 1) { Write-Warning "⚠️ Only $freeGB GB free — backup may fail!" }
   ```
5. **Size monitoring** — warn if total backups exceed 5GB:
   ```powershell
   $totalSize = (Get-ChildItem "C:\Users\alfre\backups\openclaw\*.zip" | Measure-Object -Property Length -Sum).Sum
   if ($totalSize -gt 5GB) { Write-Warning "⚠️ Backups total $([math]::Round($totalSize/1GB, 2)) GB — consider cleanup" }
   ```
6. **Validate zip after creation** — quick open test to ensure it's not corrupt

## Pre-Deploy Integration

When using the `git-deployer` skill, trigger a backup first:

- Before any `git push`, create: `backup-YYYY-MM-DD-HHMMSS-pre-deploy.zip`
- This is a full backup tagged as type `pre-deploy`
- Ensures you can always roll back a bad deploy

## Scheduling Recommendations

| Schedule | Type | Purpose |
|----------|------|---------|
| Daily (morning) | Full | Baseline protection |
| Before deploy | Full (pre-deploy) | Rollback safety |
| After major changes | Incremental | Capture work-in-progress |
| Weekly | Retention cleanup | Keep last 20, delete older |

## Error Handling

| Error | Action |
|-------|--------|
| Backup dir doesn't exist | Create it automatically |
| Disk full | Abort, warn user, suggest cleanup |
| Corrupt zip | Report failure, don't update manifest |
| Manifest missing | Create new empty manifest |
| Manifest corrupt | Rebuild from zip files on disk |
| Backup file missing (in manifest but not on disk) | Mark as missing in manifest, warn user |
| No backups to restore | Report "No backups found" |
| Permission denied | Report the specific path and suggest fix |

## Manifest Recovery

If `manifest.json` is lost or corrupt, rebuild from zip files:

```powershell
# Scan backup directory for zips
$zips = Get-ChildItem "C:\Users\alfre\backups\openclaw\backup-*.zip"

# For each zip, read _backup_metadata.json from inside
# Rebuild manifest entries from metadata
# Save new manifest.json
```

## Workflow Examples

### Full Backup
```
User: "Backup workspace"

💾 Starting full workspace backup...

📂 Scanning workspace (excluding: node_modules, .git, venv, __pycache__, media/inbound)
📊 Found 342 files (156 MB uncompressed)
💿 Disk space: 45.2 GB free ✅

🗜️ Compressing → backup-2026-02-15-143000-full.zip
✅ Backup complete!

📦 backup-2026-02-15-143000-full.zip
   342 files | 89 MB compressed | git: a3f7b2c
   Saved to: C:\Users\alfre\backups\openclaw\
```

### Restore
```
User: "Restore backup from Feb 14"

🔍 Searching backups for Feb 14...
Found: Backup #11 — 2026-02-14 09:00 (full, 89 MB, 342 files)

📋 Preview — 45 files differ from current workspace:
  Modified: 40 files
  Missing (will be added): 3 files
  Extra (not in backup): 2 files

⚠️ Restore will overwrite 40 files and add 3 files.
🔒 Safety backup will be created first.

Proceed? (yes/no)

User: "yes"

🔒 Creating safety backup... backup-2026-02-15-144500-pre-restore.zip ✅
📂 Restoring from backup #11...
✅ Restored 342 files from backup #11 (Feb 14, 2026)
```
