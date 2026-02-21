---
name: git-deployer
description: One-command deployment of workspace changes to GitHub Pages. Auto commit, push, and validate for repo axltaylor2013-star/ap-office on branch main.
---

# Git Deployer

## Repository

- **Repo:** `axltaylor2013-star/ap-office`
- **Branch:** `main`
- **Live URL:** `https://axltaylor2013-star.github.io/ap-office/`
- **Workspace root:** `C:\Users\alfre\.openclaw\workspace`

## Commands

### Deploy All

Deploy the entire workspace:

1. **Pre-deploy validation** (see below)
2. `git add -A`
3. `git commit -m "<descriptive message>"`
4. `git push origin main`
5. **Post-deploy confirmation**

**Example:** "Deploy everything" / "Push all changes"

### Deploy Directory

Deploy only specific directories:

1. **Pre-deploy validation** on target directory
2. `git add <directory>/`
3. `git commit -m "Deploy <directory>: <description>"`
4. `git push origin main`
5. **Post-deploy confirmation**

**Supported directories:**
- `dashboard/` → `https://axltaylor2013-star.github.io/ap-office/dashboard/`
- `website/` → `https://axltaylor2013-star.github.io/ap-office/website/`
- Any other subdirectory as needed

**Example:** "Deploy the dashboard" / "Push website changes"

### Deploy with Message

Specify a custom commit message:

**Example:** "Deploy dashboard with message 'Added revenue tab'"

## Pre-Deploy Validation

Before every deploy, run these checks:

### 1. Check for Broken Links (HTML files)
```powershell
# Find all .html files in target directory
# Parse for href="" and src="" attributes
# Verify local file references exist
# Flag any missing files
```

Report format:
```
✅ All links valid
— or —
⚠️ Broken links found:
  - dashboard/revenue.html → references missing chart.js
  - index.html → href="about.html" (file not found)
```

### 2. Check for Missing Files
- Verify all files referenced in HTML exist
- Check that JSON data files are valid JSON
- Ensure no empty HTML files

### 3. Check Git Status
```powershell
git status --porcelain
```
- Show what will be committed
- Warn if nothing to commit
- Warn if there are merge conflicts

### 4. Validate JSON Files
For any `.json` file being deployed, verify it's valid JSON:
```powershell
Get-Content <file> | ConvertFrom-Json
```

## Post-Deploy Confirmation

After successful push, report:

```
✅ Deployed successfully!

📦 Commit: <short hash> — <message>
📁 Files: <count> files changed
🌐 Live URL: https://axltaylor2013-star.github.io/ap-office/<path>
⏱️ Note: GitHub Pages may take 1-2 minutes to update

Changed files:
  - dashboard/revenue.html (modified)
  - dashboard/revenue.json (modified)
```

## Commit Message Format

Auto-generate descriptive messages based on what changed:

| Change Type | Message Format |
|------------|---------------|
| Dashboard updates | `Update dashboard: <specific changes>` |
| Website changes | `Update website: <specific changes>` |
| New skill added | `Add skill: <skill-name>` |
| Data file updates | `Update data: <which files>` |
| Multiple areas | `Update: <summary of all changes>` |
| Bug fixes | `Fix: <what was fixed>` |

## Error Handling

| Error | Action |
|-------|--------|
| Nothing to commit | Report "No changes to deploy" |
| Auth failure | Ask user to check GitHub credentials/token |
| Merge conflict | Show conflicted files, ask user to resolve |
| Validation failure | Show issues, ask user whether to deploy anyway |
| Network error | Retry once, then report failure |

## Workflow Example

User: "Deploy the dashboard"

```
🔍 Running pre-deploy validation on dashboard/...

Checking HTML files...
  ✅ dashboard/hub.html — 4 links, all valid
  ✅ dashboard/revenue.html — 2 links, all valid
  ✅ dashboard/tasks.html — 3 links, all valid

Checking JSON files...
  ✅ dashboard/revenue.json — valid
  ✅ dashboard/tasks.json — valid

📦 Staging files...
  git add dashboard/

💬 Committing...
  git commit -m "Update dashboard: revenue tab and task board refresh"

🚀 Pushing to origin/main...
  git push origin main

✅ Deployed successfully!
📦 Commit: a3f7b2c — Update dashboard: revenue tab and task board refresh
📁 Files: 3 files changed
🌐 Live: https://axltaylor2013-star.github.io/ap-office/dashboard/
⏱️ GitHub Pages updates in 1-2 min
```

## Rules

1. **Always validate before deploying** — never skip pre-deploy checks
2. **Never force push** — use regular `git push` only
3. **Descriptive commits** — no "update" or "fix" without context
4. **Report live URL** after every deploy
5. **Check git status first** — don't commit if nothing changed
6. **Handle errors gracefully** — always report what went wrong
