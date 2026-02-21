#!/usr/bin/env python3
"""
Simple script to add timeouts to WaitForChild calls in Lua files
"""

import os
import re

def update_file(filepath):
    """Update WaitForChild calls in a single file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # Pattern 1: :WaitForChild("name")
    pattern1 = r':WaitForChild\("([^"]+)"\)'
    replacement1 = r':WaitForChild("\1", 5)'
    content = re.sub(pattern1, replacement1, content)
    
    # Pattern 2: :WaitForChild(variable)
    pattern2 = r':WaitForChild\(([^),]+)\)'
    replacement2 = r':WaitForChild(\1, 5)'
    content = re.sub(pattern2, replacement2, content)
    
    # Pattern 3: WaitForChild("name") (without colon)
    pattern3 = r'WaitForChild\("([^"]+)"\)'
    replacement3 = r'WaitForChild("\1", 5)'
    content = re.sub(pattern3, replacement3, content)
    
    if content != original:
        with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
            f.write(content)
        return True
    return False

def main():
    project_root = r"C:\Users\alfre\.openclaw\workspace\projects\roblox-mmo"
    src_dir = os.path.join(project_root, "src")
    
    updated_files = []
    
    for root, dirs, files in os.walk(src_dir):
        for file in files:
            if file.endswith('.lua'):
                filepath = os.path.join(root, file)
                try:
                    if update_file(filepath):
                        updated_files.append(filepath)
                        print(f"Updated: {os.path.relpath(filepath, src_dir)}")
                except Exception as e:
                    print(f"Error updating {filepath}: {e}")
    
    print(f"\nTotal files updated: {len(updated_files)}")
    
    # Create a summary of changes
    summary_path = os.path.join(project_root, "error_handling_summary.txt")
    with open(summary_path, 'w', encoding='utf-8') as f:
        f.write("Error Handling Updates Summary\n")
        f.write("=" * 40 + "\n\n")
        f.write(f"Files updated: {len(updated_files)}\n\n")
        for filepath in updated_files:
            f.write(f"- {os.path.relpath(filepath, project_root)}\n")
        
        f.write("\n\nChanges made:\n")
        f.write("1. Added 5-second timeouts to all WaitForChild calls\n")
        f.write("2. Created ErrorHandler module for centralized error handling\n")
        f.write("3. Updated DataManager with comprehensive error handling\n")
        f.write("4. Updated RangedCombatManager with error handling\n")
        f.write("\nNext steps:\n")
        f.write("1. Rebuild project with: rojo build -o build.rbxlx\n")
        f.write("2. Test in Roblox Studio\n")
        f.write("3. Monitor console for any remaining errors\n")

if __name__ == '__main__':
    main()