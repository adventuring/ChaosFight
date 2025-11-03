#!/usr/bin/env python3
"""Automated script to add LET keyword to user variable assignments."""

import os
import re
import sys
from pathlib import Path

# System variables that should NOT get LET
SYSTEM_VARS = {
    'temp1', 'temp2', 'temp3', 'temp4', 'temp5', 'temp6',
    'frame', 'qtcontroller', 'rand', 'score', 'scorecolor', 'scorepointers',
    'player0x', 'player0y', 'player1x', 'player1y',
    'missile0x', 'missile0y', 'missile1x', 'missile1y',
    'ballx', 'bally', 'objecty',
    'currentpaddle', 'paddle',
    'player0pointer', 'player0pointerlo', 'player0pointerhi',
    'player1pointer', 'player1pointerlo', 'player1pointerhi',
    'player0height', 'player1height', 'missile0height', 'missile1height',
    'player0color', 'player1color', 'player0colorstore',
}

# TIA register pattern (all caps)
TIA_PATTERN = re.compile(r'^(COLUP[0-9A-F]|COLUPF|COLUBK|NUSIZ[0-9A-F]|NUSIZF|RESP[0-9A-F]|RESMP[0-9A-F]|HMOVE|HMM[0-9A-F]|VDEL[0-9A-F]|GRP[0-9A-F]|ENAM[0-9A-F]|ENABL|PF[0-2]|CTRLPF|REFP[0-9A-F]|AUDF[0-9A-F]|AUDC[0-9A-F]|AUDV[0-9A-F])$')

# BASIC keywords
BASIC_KEYWORDS = {
    'if', 'then', 'else', 'goto', 'gosub', 'return', 'for', 'next', 'on',
    'dim', 'const', 'set', 'autodim', 'asm', 'end', 'rem', 'def', 'function',
    'bank', 'data', 'sdata', 'includesfile', 'include', 'inline',
    'playfield', 'pfpixel', 'pfhline', 'pfclear', 'pfvline', 'pfscroll',
    'pfcolors', 'pfheights', 'bkcolors', 'scorecolors',
    'drawscreen', 'lives', 'vblank', 'reboot', 'dec', 'let'
}

def is_system_var(varname):
    """Check if variable is a system variable."""
    # Single letter variables (a-z, A-Z)
    if len(varname) == 1 and varname.isalpha():
        return True
    
    # Check explicit system vars
    if varname.lower() in SYSTEM_VARS:
        return True
    
    # Check var0-var95 pattern
    if re.match(r'^var\d+$', varname):
        return True
    
    # Check TIA registers (all caps)
    if TIA_PATTERN.match(varname):
        return True
    
    # Check BASIC keywords
    if varname.lower() in BASIC_KEYWORDS:
        return True
    
    return False

def needs_let(line):
    """Check if line needs LET keyword added."""
    # Skip comment lines
    if re.match(r'^\s*rem', line, re.IGNORECASE):
        return False, None
    
    # Check if already has LET
    if re.match(r'^\s*let\s+', line, re.IGNORECASE):
        return False, None
    
    # Must have = sign
    if '=' not in line:
        return False, None
    
    # Extract variable name (everything before =, handling arrays)
    # Remove leading whitespace
    stripped = line.lstrip()
    
    # Pattern: variable_name [optional array brackets] = value
    match = re.match(r'^([A-Za-z][A-Za-z0-9]*)(\[.*?\])?\s*=', stripped)
    if not match:
        return False, None
    
    varname = match.group(1)
    
    # Skip system variables
    if is_system_var(varname):
        return False, None
    
    return True, varname

def add_let_to_line(line):
    """Add LET keyword to a line if needed."""
    needs, varname = needs_let(line)
    
    if not needs:
        return line
    
    # Find the start of the variable name (after leading whitespace)
    stripped = line.lstrip()
    indent = line[:len(line) - len(stripped)]
    
    # Add LET at the start (preserving indentation)
    # For batariBASIC, we use lowercase "let"
    new_line = indent + 'let ' + stripped
    
    return new_line

def process_file(filepath, dry_run=False):
    """Process a single .bas file."""
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading {filepath}: {e}", file=sys.stderr)
        return 0
    
    modified_lines = []
    changes = 0
    
    for line in lines:
        new_line = add_let_to_line(line)
        if new_line != line:
            changes += 1
            if not dry_run:
                modified_lines.append(new_line)
            else:
                modified_lines.append(f"{line.rstrip()}  # -> {new_line.rstrip()}")
        else:
            modified_lines.append(line)
    
    if changes > 0:
        if not dry_run:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(modified_lines)
            print(f"✓ {filepath}: Added LET to {changes} lines")
        else:
            print(f"Would modify {filepath}: {changes} lines")
            print('\n'.join(modified_lines[:10]))  # Show first 10 changes
            if len(modified_lines) > 10:
                print(f"... ({len(modified_lines) - 10} more)")
    
    return changes

def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--dry-run':
        dry_run = True
    else:
        dry_run = False
    
    base_dir = Path(__file__).parent
    source_dir = base_dir / 'Source'
    
    if not source_dir.exists():
        print(f"Error: Source directory not found at {source_dir}", file=sys.stderr)
        sys.exit(1)
    
    total_changes = 0
    files_modified = 0
    
    # Process all .bas files
    for filepath in source_dir.rglob('*.bas'):
        changes = process_file(filepath, dry_run=dry_run)
        if changes > 0:
            files_modified += 1
            total_changes += changes
    
    print(f"\n{'[DRY RUN] ' if dry_run else ''}Summary:")
    print(f"  Files modified: {files_modified}")
    print(f"  Total lines changed: {total_changes}")
    
    if dry_run:
        print("\nRun without --dry-run to apply changes")

if __name__ == '__main__':
    main()

