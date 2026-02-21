#!/usr/bin/env python3
"""Validate dashboard/tasks.json format."""
import json, sys

REQUIRED = {"id", "agent", "task", "status", "date", "category", "path"}
VALID_STATUS = {"queued", "in-progress", "completed"}

def validate(path):
    with open(path, "r", encoding="utf-8-sig") as f:
        data = json.load(f)
    if not isinstance(data, list):
        return ["Root must be a JSON array"]
    errors = []
    ids = set()
    for i, t in enumerate(data):
        if not isinstance(t, dict):
            errors.append(f"[{i}] Not an object")
            continue
        missing = REQUIRED - set(t.keys())
        if missing:
            errors.append(f"[{i}] Missing fields: {missing}")
        if "id" in t:
            if not isinstance(t["id"], int):
                errors.append(f"[{i}] id must be integer")
            elif t["id"] in ids:
                errors.append(f"[{i}] Duplicate id: {t['id']}")
            else:
                ids.add(t["id"])
        if "status" in t and t["status"] not in VALID_STATUS:
            errors.append(f"[{i}] Invalid status: {t['status']}")
    return errors

if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else "dashboard/tasks.json"
    try:
        errs = validate(path)
    except FileNotFoundError:
        print(f"FAIL: {path} not found"); sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"FAIL: Invalid JSON - {e}"); sys.exit(1)
    if errs:
        print("FAIL:"); [print(f"  {e}") for e in errs]; sys.exit(1)
    else:
        print("OK: tasks.json is valid"); sys.exit(0)
