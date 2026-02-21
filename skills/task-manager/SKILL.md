---
name: task-manager
description: Manage the task board at dashboard/tasks.json. Use when starting, completing, assigning, or querying tasks. Handles task creation, status updates, and ID management for the Office and Task Board apps.
---

# Task Manager

## Task Board Location

`dashboard/tasks.json`

Both the Office app and Task Board read from this file. Always update it when work begins, completes, or is assigned.

## JSON Schema

```json
[
  {
    "id": 1,
    "agent": "jarvis|forge|mule",
    "task": "Description of the work",
    "status": "queued|in-progress|completed",
    "date": "YYYY-MM-DD",
    "category": "dev|research|content|design|ops",
    "path": "relative/path/to/output"
  }
]
```

## Rules

1. **Auto-increment IDs** — Read existing tasks, find max ID, add 1.
2. **Status transitions**: `queued` → `in-progress` → `completed`. Never skip or reverse.
3. **Always set `date`** to today when creating or updating a task.
4. **Set `path`** to the primary output file/folder when completing a task.
5. **One task per unit of work** — don't bundle unrelated work into one task.
6. **Validate before writing** — Run `scripts/validate-tasks.py` or manually verify JSON is valid array of objects with all required fields.

## Workflow

### Starting work
1. Read `dashboard/tasks.json`
2. Find or create the task entry, set status to `in-progress`
3. Write back the file

### Completing work
1. Read `dashboard/tasks.json`
2. Update the task: status → `completed`, set `path` and `date`
3. Write back the file

### Adding new tasks
1. Read existing tasks
2. Create new entry with `id = max(existing ids) + 1`, status `queued`
3. Write back the file

## Task Breakdown Best Practices

### NEVER: Large Batches
❌ **BAD**: "Build Friend System + Achievement System + Leaderboard"
✅ **GOOD**: "Build Friend System", "Build Achievement System", "Build Leaderboard" (3 separate tasks)

### Why Small Tasks Matter
- **Easier debugging** — One system = isolate issues quickly
- **Better testing** — Can verify each piece works before moving on
- **Rollback safety** — Can revert one feature without losing others
- **Progress tracking** — Clear wins vs. "80% done but nothing works"

### Task Size Guidelines
- **MAX 1 day per task** — If longer, break it down
- **1 system per task** — UI system, combat system, data system (separate tasks)
- **Testable completion** — "Can be tested in isolation" = good task size
- **Single output** — Each task produces ONE deliverable (script, UI, system)

### Good Task Descriptions
- **Specific**: "Fix NPCs spawning underground" not "Fix NPCs"
- **Testable**: "Mining nodes give XP and ore" not "Improve mining"
- **Bounded**: "Add inventory sorting button" not "Improve inventory"

### Emergency Lessons (2026-02-18)
After the Great Debug Disaster, we learned: **batch tasks = cascading failures**. When 10 systems are built simultaneously, 1 bug becomes 100 error messages. Always build incrementally.

## Validation

Run `scripts/validate-tasks.py <path-to-tasks.json>` to check format. It verifies:
- Valid JSON array
- Each task has all required fields
- Valid status values
- IDs are unique integers
