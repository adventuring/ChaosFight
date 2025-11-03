#!/usr/bin/env python3
"""Identify all user variable assignments that need LET keyword."""

import os
import re
import sys
from collections import defaultdict

# System variables to exclude
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

# TIA register patterns (all caps)
TIA_PATTERN = re.compile(r'^(COLUP[0-9A-F]|COLUPF|COLUBK|NUSIZ[0-9A-F]|NUSIZF|RESP[0-9A-F]|RESMP[0-9A-F]|HMOVE|HMM[0-9A-F]|VDEL[0-9A-F]|GRP[0-9A-F]|ENAM[0-9A-F]|ENABL|PF[0-2]|CTRLPF|REFP[0-9A-F]|AUDF[0-9A-F]|AUDC[0-9A-F]|AUDV[0-9A-F])$')

def is_system_var(varname):
    """Check if variable is a system variable."""
    # Single letter variables (a-z, A-Z)
    if len(varname) == 1 and varname.isalpha():
        return True
    
    # Check explicit system vars
    if varname in SYSTEM_VARS:
        return True
    
    # Check var0-var95 pattern
    if re.match(r'^var\d+$', varname):
        return True
    
    # Check TIA registers (all caps)
    if TIA_PATTERN.match(varname):
        return True
    
    return False

# BASIC keywords that shouldn't be treated as variables
BASIC_KEYWORDS = {
    'if', 'then', 'else', 'goto', 'gosub', 'return', 'for', 'next', 'on',
    'dim', 'const', 'set', 'autodim', 'asm', 'end', 'rem', 'def', 'function',
    'bank', 'data', 'sdata', 'includesfile', 'include', 'inline',
    'playfield', 'pfpixel', 'pfhline', 'pfclear', 'pfvline', 'pfscroll',
    'pfcolors', 'pfheights', 'bkcolors', 'scorecolors',
    'drawscreen', 'lives', 'vblank', 'reboot', 'dec', 'let'
}

def extract_var_name(line):
    """Extract variable name from assignment line."""
    # Remove optional "let " at start (case insensitive)
    line = re.sub(r'^\s*let\s+', '', line, flags=re.IGNORECASE)
    
    # Extract everything before = (and any array brackets)
    match = re.match(r'^\s*([A-Za-z][A-Za-z0-9]*)\[?', line)
    if match:
        varname = match.group(1)
        # Skip if it's a BASIC keyword
        if varname.lower() in BASIC_KEYWORDS:
            return None
        return varname
    
    # Try without brackets
    match = re.match(r'^\s*([A-Za-z][A-Za-z0-9]*)\s*=', line)
    if match:
        varname = match.group(1)
        # Skip if it's a BASIC keyword
        if varname.lower() in BASIC_KEYWORDS:
            return None
        return varname
    
    return None

def find_user_vars():
    """Find all user variable assignments in .bas files."""
    results = defaultdict(list)
    
    # Walk Source directory
    for root, dirs, files in os.walk('Source'):
        for filename in files:
            if not filename.endswith('.bas'):
                continue
            
            filepath = os.path.join(root, filename)
            
            try:
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    for line_num, line in enumerate(f, 1):
                        # Skip comment lines
                        if re.match(r'^\s*rem', line, re.IGNORECASE):
                            continue
                        
                        # Look for assignment patterns
                        if '=' not in line:
                            continue
                        
                        # Extract variable name
                        varname = extract_var_name(line)
                        if not varname:
                            continue
                        
                        # Skip system variables
                        if is_system_var(varname):
                            continue
                        
                        # Check if already has LET
                        has_let = bool(re.match(r'^\s*let\s+', line, re.IGNORECASE))
                        
                        # Store result
                        results[varname].append({
                            'file': filepath,
                            'line': line_num,
                            'has_let': has_let,
                            'content': line.strip()
                        })
            except Exception as e:
                print(f"Error reading {filepath}: {e}", file=sys.stderr)
    
    return results

def main():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    results = find_user_vars()
    
    # Sort by variable name
    sorted_vars = sorted(results.keys())
    
    # Output summary
    print(f"Found {len(sorted_vars)} unique user variables")
    print(f"Total assignments: {sum(len(v) for v in results.values())}")
    print()
    
    # Group by file for reporting
    by_file = defaultdict(list)
    for varname in sorted_vars:
        for entry in results[varname]:
            by_file[entry['file']].append((varname, entry))
    
    # Output detailed list
    for filepath in sorted(by_file.keys()):
        print(f"\n{filepath}:")
        # Sort by line number
        for varname, entry in sorted(by_file[filepath], key=lambda x: x[1]['line']):
            status = "✓ HAS LET" if entry['has_let'] else "✗ NEEDS LET"
            print(f"  Line {entry['line']:4d}: {status:12s} {varname}")
            print(f"            {entry['content'][:80]}")
    
    # Summary statistics
    needs_let = sum(1 for entries in results.values() 
                    for entry in entries if not entry['has_let'])
    has_let = sum(1 for entries in results.values() 
                  for entry in entries if entry['has_let'])
    
    print(f"\n\nSummary:")
    print(f"  Variables needing LET: {needs_let}")
    print(f"  Variables already have LET: {has_let}")

if __name__ == '__main__':
    main()

