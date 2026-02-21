# MEMORY.md — Long-Term Memory

## Jeremy
- Name: Jeremy Kermicle
- Telegram: @Ifakedit1 (ID: 8525420933)
- Email: alfred.pennyworth32@gmail.com
- GitHub: axltaylor2013-star
- Timezone: US Eastern
- Location: Owenton, Kentucky 40359
- Business: Kermicle Media — photo/video editing (kermiclemedia.com)
- Has kids (baseball + football), has a small dog
- Wants me professional, goal-oriented, funny, always looking to make him money
- Machine: i7-13700HX, RTX 4060 8GB, 16GB RAM, Windows 11

## Agents
- **Jarvis** (me) — Claude Opus, main brain, @howard32bot on Telegram
- **Mule** 🫏 — Llama 3.1 8B, general worker, @mule32bot, $0 cost
- **Forge** 🔨 — Qwen2.5-Coder 7B, coding specialist, Telegram configured, $0 cost

## Known Bugs
- **Scout session path error — RESOLVED**: Was "Session file path must be within sessions directory". Fixed after OpenClaw 2026.2.13 reinstall + session resets. Real issue was also grok-2 model 404ing. Now on Gemini 2.0 Flash and working.
- **Can't run Mule + Forge simultaneously — RESOLVED**: Both were local Ollama models, 16GB RAM not enough. Fixed by moving both to cloud (Gemini Flash).
- **Gateway crash chain (2026-02-17) — RESOLVED**: See Lessons Learned below.

## Lessons Learned

### Gateway Crash Chain (2026-02-17) — NEVER REPEAT
Root cause: A cascade of config mistakes that took the gateway down for ~20 minutes.
1. **nativeSkills: "auto"** tried to register 43 skills × 4 bot accounts as Telegram commands → hit Telegram's BOT_COMMANDS_TOO_MUCH limit (max ~100). **Fix:** Set `nativeSkills: false`.
2. **PowerShell Set-Content adds BOM** — Used PowerShell `-replace` + `Set-Content -Encoding UTF8` to edit openclaw.json. PowerShell's UTF8 encoding ADDS a BOM (EF BB BF). OpenClaw/Node can't parse JSON with BOM → gateway crashes on startup and won't recover. **NEVER use PowerShell to edit JSON config files. ALWAYS use Node.js:**
   ```
   node -e "const fs=require('fs'); const c=JSON.parse(fs.readFileSync('PATH','utf8')); c.key='val'; fs.writeFileSync('PATH',JSON.stringify(c,null,2));"
   ```
3. **DeepSeek provider crashed gateway** — Added DeepSeek as provider, set Forge to `deepseek/deepseek-chat`. OpenClaw threw "No API provider registered for api: undefined" when trying to start a Forge session → unhandled promise rejection → gateway crash. OpenClaw may not support DeepSeek's API format natively yet, or needs a specific `api` field value. **Fix for now:** Forge on Gemini Flash. Investigate DeepSeek config later (may need OpenRouter as proxy).
4. **Config validation values** — `nativeSkills` doesn't accept "off" or "none" — only `"auto"` or `false`. Always check valid values before patching.

**Prevention rules:**
- NEVER use PowerShell to edit openclaw.json (BOM kills it)
- ALWAYS use Node.js for JSON config edits
- TEST new providers with a simple `sessions_send` test message BEFORE deploying real work
- Keep gateway watchdog running to auto-recover from crashes
- When adding a new API provider, check OpenClaw docs for supported `api` field values first

- NEVER uninstall/downgrade OpenClaw without asking Jeremy first
- PowerShell ConvertTo-Json mangles config files — always use config.patch instead
- VBS wrappers (WScript.Shell .Run with 0 flag) hide scheduled task windows on Windows
- Telegram plugin must be enabled at both channel AND plugin level
- Encoding issues: always write HTML files as proper UTF-8, avoid mojibake
- PowerShell can't handle special characters in inline commands — use .js script files instead
- Multi-agent Telegram: use accounts + bindings, set dmPolicy to allowlist with user ID
- Session file paths should be relative, not absolute (caused "must be within sessions directory" error)
- Always pull up the website after making changes (Jeremy's request)
- Always confirm when a task is done — never leave Jeremy hanging

### The Great Debug Disaster (2026-02-18) — NEVER REPEAT
**Root cause:** Built 30+ new Roblox scripts simultaneously via agent batch system. Created cascading failures where every bug broke every other system. Game went from working to completely unplayable despite $100 debugging effort.

**Critical lessons:**
- **NEVER build multiple systems at once** — ONE thing at a time, test thoroughly, THEN next
- **BOM kills Roblox scripts silently** — Windows UTF-8 encoding, always strip BOM from .lua files
- **Scripts can't return values** — Only ModuleScripts can export (caused FletchingUI syntax errors)
- **Forward declare functions** — Prevent "attempt to call nil value" in callbacks
- **Type check before pairs()** — Don't assume data is always a table (ErrorHandler crashes)
- **Use colon for methods, dot for functions** — DataManager:Method() not DataManager.Method()
- **NPCs spawning underground** — Match spawn Y coordinates between systems (Y=15 not Y=0)
- **Missing methods break everything** — AddToInventory, GetSkillLevel, etc. must exist before scripts call them

**Recovery protocol:** Stop adding features, restore last working build, disable agent automation, fix ONE issue at a time starting with simplest.

**New rule:** Slow and steady beats fast and broken. Better to have 3 working systems than 30 broken ones.

## Telegram Multi-Account Config (Working Pattern — 2026-02-14)
- Top-level `botToken` = default account (Jarvis/@howard32bot)
- Named accounts (mule, forge) in `channels.telegram.accounts` with own `botToken`
- Bindings for default use `accountId: "default"`, not a custom name
- NEVER duplicate same token in top-level AND accounts section
- `doctor --fix` re-adds `dmPolicy: "pairing"` as default — always check after running
- Gateway crashes silently sometimes — watchdog at `C:\Users\alfre\bin\gateway-watchdog.ps1` auto-restarts every 5 min

## GitHub Pages
- Office dashboard: https://axltaylor2013-star.github.io/ap-office/
- Repo: axltaylor2013-star/ap-office

## Agent Task Systems
- Forge: `workspace-forge/TASKS.md` — 8-task queue, completed 3 so far
- Mule: `TASKS-MULE.md` in main workspace — standing orders + on-demand
- Mule output: `mule-output/` in main workspace

## Roblox Game Dev
- Project: "Wilderness" — RuneScape-inspired MMO with full-loot PvP
- Path: workspace/projects/roblox-mmo/
- Using Rojo v7.6.1 (C:\Users\alfre\bin\rojo.exe) for file→Studio syncing
- CRITICAL: Always use `$ignoreUnknownInstances: true` on Workspace and services with Studio-placed content, or Rojo deletes Parts/Terrain
- File naming: .server.lua = Script, .client.lua = LocalScript, .lua = ModuleScript
- Can only `require()` ModuleScripts, NOT Scripts — shared logic must be ModuleScripts
- RemoteEvents defined in project.json, scripts use WaitForChild to get them
- Map parts (baseplate, spawn, border) must be created via Command Bar or manually in Studio — Rojo doesn't handle physical parts well
- **CRITICAL: DataStore requires a PUBLISHED place** — unpublished local files crash with "You must publish this place to the web to access DataStore." ALWAYS wrap DataStore in pcall with in-memory fallback for testing.
- New skill: roblox-game-builder (shared across Jarvis, Scout, Forge)

## Tools Installed
- Image Optimizer: `optimize` command (`C:\Users\alfre\bin\optimize.bat`), requires Pillow
- FFmpeg: installed via winget (Gyan.FFmpeg 8.0.1)
- Stable Diffusion: ComfyUI + SD 1.5 at C:\Users\alfre\stable-diffusion\ (PyTorch 2.6.0+cu124, CUDA working)

## Dashboard Hub
- 13 tabs: Command Center, Task Board, The Office, Revenue, Analytics, Calendar, Lead Pipeline, Inbox, Invoices, Goals, Quick Tools, Expenses, Client Portal
- Live at: https://axltaylor2013-star.github.io/ap-office/hub.html
- All pages fetch from JSON files (tasks.json, training.json, revenue.json, analytics.json, etc.)
- Rule: ALL new tools go as tabs in hub.html

## Team Quality Standards (2026-02-16)
- Created `docs/team-lessons.md` — 15 hard-won bug fixes, never repeat
- Created `docs/CODE-REVIEW-CHECKLIST.md` — mandatory pre/post-build verification
- Updated `roblox-game-builder` SKILL.md with inventory/item/armor/hotbar lessons
- All sub-agents must reference checklist before declaring work complete
- Scout integrating lessons into research recommendations
- Forge building reusable Roblox tools (admin, particles, leaderboard, weather, trading, achievements)

## Standing Permissions
- **Add new skills freely** — Jeremy authorized Jarvis to create new skills for any agent whenever needed, as long as they're safe. No need to ask first. (Granted 2026-02-16)

## Skills — 25 Total (Jarvis)
- task-manager, kermicle-web-builder, python-project-scaffold, local-lead-gen, content-research, animatic-pipeline, client-onboarding, portfolio-generator, social-media-autopilot, voiceover-studio, script-to-storyboard, thumbnail-factory, client-crm, revenue-dashboard, email-outreach, git-deployer, analytics-tracker, api-connector, backup-vault, client-portal, expense-tracker, scheduling-bot, template-vault, brand-kit-generator, proposal-generator

## Scout Agent
- Running Gemini 2.0 Flash (Google) — cheap/free, 1M context window
- Telegram bot WORKING (@scout32bot) + sessions_send
- Workspace: workspace-scout2
- 8 custom skills: web-researcher, trend-scout, lead-finder, price-intel, content-scout, news-briefing, tool-finder, opportunity-radar
- Google API key in agents/scout/agent/models.json

## Jeremy's Family
- Has a son who wears #22 on Owen County Runnin' Rebels basketball (3rd grade)
- Won 2026 NCKC Boys 3rd Grade Tournament Champions

## Lessons Learned (2026-02-16)
- **BOM kills Roblox scripts silently** — Windows writes UTF-8 BOM (U+FEFF) to .lua files. Roblox Luau can't parse it. ALWAYS strip BOM after writing files. Symptoms: script doesn't load, line 1 parse error mentioning U+feff.
- **DataManager uses UPPERCASE fields** — Skills, Inventory, Equipment, Gold, Bank, Quests. Skills are raw XP numbers, not tables. Inventory is array of {name, quantity}.
- **Always strip BOM from ALL .lua files** after batch writes — check every file, not just the ones you think you changed
- **Stats panel data contract**: Server returns flat level numbers for skills (not {level, xp} tables), inventory as {name, count, rarity} array, equipment as {Head="", Body=""...} map

## Lessons Learned (2026-02-17)
- **PaddingAll crash (2026-02-17)**: `UIPadding.PaddingAll` doesn't exist in Roblox. Used it in StatsPanel context menu → script died at line 788 → all inventory interactions (equip, drop, use, context menu, drag-drop) stopped working. Fix: use PaddingTop/Bottom/Left/Right individually. ALWAYS check Roblox API docs for property names.
- **Monster animation player filter (2026-02-17)**: MonsterMovementAnimations.client.lua was animating ALL models with Humanoids including the player character → player body parts flying everywhere. Fix: filter with `Players:GetPlayerFromCharacter(model)`.
- **Duplicate RemoteEvents (2026-02-17)**: AttackVisualHandler created RemoteEvents at ReplicatedStorage root with `Instance.new()`, but client listened on ones in Remotes folder (from project.json). Two separate instances = server fires one, client listens other = monster attack animations never played. Fix: ALL remotes in project.json, server uses `Remotes:WaitForChild()`.

## CURRENT PRIORITY: AI AUTOMATION BUSINESS (as of 2026-02-21)
- ALL agents focused on Jeremy's AI automation business success
- Roblox game development suspended - full team pivot to revenue generation
- 4 new business skills created: Lead Conversion Optimizer, Local Partnership Developer, Sales Funnel Automation, Testimonial Generator
- Pricing updated: 128GB package from $6,500 to $8,000
- SMS automation system in development (working on Gmail API integration)
- Complete Northern Kentucky marketing foundation ready (blogs, social calendar, sales materials)

## Business Pivot
- NOT selling photo/video editing yet (no portfolio samples)
- Focus: AI Setup-as-a-Service, Social Media Management, AI Consulting/Automation
- Dashboard is the portfolio — "I built this in 2 days with AI"
- Still need Jeremy's city + social handles to start lead gen
