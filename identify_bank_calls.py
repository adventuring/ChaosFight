#!/usr/bin/env python3
"""Identify all gosub bankN calls that cross banks."""

import os
import re
from collections import defaultdict

def find_bank_calls():
    """Find all gosub bankN calls in .bas files."""
    results = []
    
    # Walk Source directory
    for root, dirs, files in os.walk('Source'):
        for filename in files:
            if not filename.endswith('.bas'):
                continue
            
            filepath = os.path.join(root, filename)
            
            try:
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    for line_num, line in enumerate(f, 1):
                        # Look for "gosub bank" pattern
                        match = re.search(r'gosub\s+bank(\d+)\s+(\w+)', line, re.IGNORECASE)
                        if match:
                            bank_num = match.group(1)
                            function_name = match.group(2)
                            results.append({
                                'file': filepath,
                                'line': line_num,
                                'bank': bank_num,
                                'function': function_name,
                                'content': line.strip()
                            })
            except Exception as e:
                print(f"Error reading {filepath}: {e}", file=sys.stderr)
    
    return results

def main():
    import sys
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    results = find_bank_calls()
    
    # Group by bank
    by_bank = defaultdict(list)
    for entry in results:
        by_bank[entry['bank']].append(entry)
    
    # Group by file
    by_file = defaultdict(list)
    for entry in results:
        by_file[entry['file']].append(entry)
    
    print("Bank-Crossing gosub Calls (Cannot be optimized to tail calls)")
    print("=" * 70)
    print()
    print(f"Total bank-crossing calls found: {len(results)}")
    print()
    
    print("By Bank:")
    print("-" * 70)
    for bank in sorted(by_bank.keys(), key=int):
        print(f"\nBank {bank} ({len(by_bank[bank])} calls):")
        for entry in sorted(by_bank[bank], key=lambda x: (x['file'], x['line'])):
            print(f"  {entry['file']}:{entry['line']}")
            print(f"    gosub bank{entry['bank']} {entry['function']}")
    
    print("\n\nBy File:")
    print("-" * 70)
    for filepath in sorted(by_file.keys()):
        print(f"\n{filepath}:")
        for entry in sorted(by_file[filepath], key=lambda x: x['line']):
            print(f"  Line {entry['line']:4d}: gosub bank{entry['bank']} {entry['function']}")
    
    print("\n\nEXCLUSION LIST (for tail call optimization):")
    print("-" * 70)
    print("All gosub bankN calls must be excluded from tail call optimization")
    print("because they cross bank boundaries.")
    print()
    print("Pattern to exclude:")
    print("  gosub bank[0-9]+ FunctionName")
    print()
    print("Examples:")
    for entry in results[:10]:
        print(f"  {entry['file']}:{entry['line']} - gosub bank{entry['bank']} {entry['function']}")

if __name__ == '__main__':
    main()

