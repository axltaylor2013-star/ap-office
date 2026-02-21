#!/usr/bin/env python3
"""
Script to fix WaitForChild calls in Lua files by adding timeouts
and replacing with SafeWaitForChild from ErrorHandler
"""

import os
import re
import sys

def fix_waitforchild_in_file(filepath):
    """Fix WaitForChild calls in a single Lua file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Pattern to find WaitForChild calls
    # Matches: :WaitForChild("name")
    # Matches: :WaitForChild("name", 10) (with timeout)
    pattern = r'(\w+):WaitForChild\(([^)]+)\)'
    
    def replace_match(match):
        parent = match.group(1)
        args = match.group(2)
        
        # Check if already has timeout
        if ',' in args:
            # Already has timeout, just ensure it's using ErrorHandler
            return f'ErrorHandler:SafeWaitForChild({parent}, {args})'
        else:
            # Add default timeout of 5 seconds
            return f'ErrorHandler:SafeWaitForChild({parent}, {args}, 5)'
    
    # Replace all WaitForChild calls
    new_content = re.sub(pattern, replace_match, content)
    
    # Add ErrorHandler import if not present
    if 'local ErrorHandler' not in new_content and 'ErrorHandler:SafeWaitForChild' in new_content:
        # Find a good place to add the import (after other requires)
        lines = new_content.split('\n')
        for i, line in enumerate(lines):
            if 'require(' in line and 'Modules' in line:
                # Add ErrorHandler import after this line
                lines.insert(i + 1, 'local ErrorHandler = require(Modules:WaitForChild("ErrorHandler"))')
                break
        new_content = '\n'.join(lines)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
            f.write(new_content)
        return True
    return False

def fix_all_lua_files(root_dir):
    """Fix all Lua files in directory tree"""
    fixed_files = []
    
    for dirpath, dirnames, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith('.lua'):
                filepath = os.path.join(dirpath, filename)
                try:
                    if fix_waitforchild_in_file(filepath):
                        fixed_files.append(filepath)
                        print(f"Fixed: {filepath}")
                except Exception as e:
                    print(f"Error processing {filepath}: {e}")
    
    return fixed_files

def add_nil_checks_to_file(filepath):
    """Add nil checks to variable accesses in Lua file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Pattern to find variable.property access
    # This is a simple pattern and might need refinement
    pattern = r'(\w+)\.(\w+)\s*[=\(\)\[\],;]'
    
    # This is a complex operation that would need more sophisticated
    # analysis. For now, we'll just note which files need manual review.
    
    lines = content.split('\n')
    issues = []
    
    for i, line in enumerate(lines):
        # Look for common nil access patterns
        if 'nil' in line.lower() and 'error' not in line.lower():
            issues.append(f"Line {i+1}: Possible nil issue - {line.strip()}")
    
    return issues

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python fix_waitforchild.py <directory>")
        sys.exit(1)
    
    root_dir = sys.argv[1]
    
    print(f"Fixing WaitForChild calls in {root_dir}...")
    fixed = fix_all_lua_files(root_dir)
    
    print(f"\nFixed {len(fixed)} files:")
    for f in fixed:
        print(f"  {f}")
    
    print("\nChecking for nil access issues...")
    for dirpath, dirnames, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith('.lua'):
                filepath = os.path.join(dirpath, filename)
                issues = add_nil_checks_to_file(filepath)
                if issues:
                    print(f"\n{filepath}:")
                    for issue in issues[:5]:  # Show first 5 issues
                        print(f"  {issue}")
                    if len(issues) > 5:
                        print(f"  ... and {len(issues)-5} more issues")