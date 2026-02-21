# Roblox Development Lessons Learned

**Never repeat these mistakes. Update this file when we learn new lessons.**

## The Great Debug Disaster (2026-02-18)

### What Happened
- Built 30+ new scripts simultaneously (Forge batch system)
- Created cascading failures where every bug broke every other system
- Game went from working to completely unplayable
- $100+ spent debugging what should have been simple issues
- Had to restore to previous working build

### Root Cause Analysis
1. **Built too much at once** — 3 agents adding systems simultaneously
2. **No incremental testing** — Massive batch builds without testing individual pieces
3. **Cascading dependencies** — When System A crashes, it breaks B, C, D, etc.
4. **Error amplification** — 1 missing function becomes 100 error messages

## CARDINAL RULES (Never Violate)

### 1. ONE THING AT A TIME
- Build ONE system, test it, make sure it works, THEN build the next
- Never have multiple agents building systems simultaneously  
- When debugging, fix ONE issue at a time

### 2. Always Test Incrementally
- After writing any script, build and test immediately
- Don't accumulate untested code
- Better to have 5 working systems than 20 broken ones

### 3. Systematic Debug Priority
When everything is broken, fix in this order:
1. **Syntax errors** (prevent scripts from loading)
2. **Missing functions/methods** (nil calls crash everything)
3. **Data type mismatches** (string where table expected)
4. **Positioning issues** (visual but harmless)
5. **UI polish** (functional but rough)

## Technical Gotchas (Production Bugs)

### Critical File Issues
- **BOM kills Roblox scripts silently** — Windows UTF-8 encoding adds BOM, Roblox can't parse it
- **Always strip BOM after writing .lua files**
- **Scripts can't return values** — Only ModuleScripts can export

### Syntax Traps
- **PaddingAll doesn't exist** — Use PaddingTop/Bottom/Left/Right individually
- **Forward declare functions** — Declare before callbacks that use them
- **Type check before pairs()** — Data might not always be a table
- **Use colon (:) for methods, dot (.) for functions**

### Common Nil Value Causes
- **Player instance type checks** — Check `type(player) == "userdata"` before `player:IsA()`
- **String concatenation** — Always `tostring()` variables that might be tables
- **Duplicate parameters** — Don't pass `ErrorHandler` twice to its own methods

### Positioning Issues
- **NPCs underground** — Make sure spawn Y positions match player spawn Y
- **Consistent coordinate systems** — If players spawn at Y=15, everything should be Y=15+

## Emergency Recovery Protocol

When everything breaks:
1. **STOP adding features** — Don't make it worse
2. **Restore last working build** — Get back to known good state  
3. **Disable automation** — Turn off agent build systems
4. **Fix simplest issue first** — Build confidence, reduce error noise
5. **Test each fix** before moving to the next

## Development Process Rules

### Task Breakdown
- **Max 1 day per task** — If longer, break it down
- **1 system per task** — Don't bundle unrelated work
- **Testable completion** — Can be verified in isolation
- **Specific descriptions** — "Fix NPC spawn positions" not "Fix NPCs"

### Build Process  
- Always build after changes: `rojo build -o build.rbxlx`
- Strip BOM from all .lua files after writing
- Check Output window for errors before declaring success
- Close and reopen Studio with fresh .rbxlx file

### Agent Coordination
- Only ONE agent builds systems at a time
- Other agents do research, testing, documentation, marketing
- Never run multiple development streams simultaneously

## Success Metrics

**Good signs:**
- Can play the game without crashes
- Individual systems work in isolation  
- Error count decreases with each fix
- Changes are predictable and contained

**Bad signs:**
- "Fixed one thing, broke three others"
- Error count increasing despite fixes
- "Everything worked yesterday, now nothing works"  
- Can't identify which change caused which problem

## Remember

**Slow and steady beats fast and broken.** It's better to have 3 working systems than 30 broken ones. Always prioritize stability over features.

When in doubt, stop and test what you have.