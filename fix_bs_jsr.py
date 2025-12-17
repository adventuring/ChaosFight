#!/usr/bin/env python3
"""Script to fix BS_jsr encoding patterns across all files."""

import re
import subprocess
import sys

# Map of files to their banks (caller banks)
# Format: "Source/Routines/Filename.s": (bank_number, bank_hex_encoding)
# bank_hex_encoding is $c0 for bank 12, $d0 for bank 13, etc.
FILE_TO_BANK = {}

# First, let's find which bank each file is in
def find_file_banks():
    """Find which bank each .s file is in."""
    result = subprocess.run(['grep', '-r', '\.include.*Routines/', 'Source/Banks/*.s'], 
                          capture_output=True, text=True)
    lines = result.stdout.split('\n')
    
    current_bank = None
    for line in lines:
        # Extract bank number from file name or current_bank setting
        if 'Bank' in line and '.s:' in line:
            # Extract bank number from filename like Bank12.s
            match = re.search(r'Bank(\d+)\.s', line)
            if match:
                bank_num = int(match.group(1))
                bank_hex = f"${bank_num:x}0"  # e.g., 12 -> $c0
                current_bank = (bank_num, bank_hex)
        
        # Extract routine name from include
        match = re.search(r'Routines/([^/]+)\.s', line)
        if match and current_bank:
            routine = f"Source/Routines/{match.group(1)}.s"
            FILE_TO_BANK[routine] = current_bank
    
    return FILE_TO_BANK

# Pattern to match BS_jsr calls with raw return addresses
BS_JSR_PATTERN = re.compile(
    r'(\s+;;[^\n]*\n)?'  # Optional comment
    r'(\s+lda # >\(([A-Za-z][A-Za-z0-9]*-1)\)\s+;;[^\n]*\n)?'  # Optional encoded return hi
    r'(\s+lda # >\(([A-Za-z][A-Za-z0-9]*-1)\)\s*\n)'  # Return hi (may be raw)
    r'\s+pha\s*\n'
    r'\s+lda # <\(([A-Za-z][A-Za-z0-9]*-1)\)\s*\n'  # Return lo
    r'\s+pha\s*\n'
    r'(\s+;;[^\n]*\n)?'  # Optional comment
    r'\s+lda # >\(([A-Za-z][A-Za-z0-9]*-1)\)\s*\n'  # Target hi (should be raw)
    r'\s+pha\s*\n'
    r'\s+lda # <\(([A-Za-z][A-Za-z0-9]*-1)\)\s*\n'  # Target lo
    r'\s+pha\s*\n'
    r'\s+ldx # (\d+)\s*\n'  # Target bank
    r'\s+jmp BS_jsr',
    re.MULTILINE
)

if __name__ == '__main__':
    find_file_banks()
    print(f"Found {len(FILE_TO_BANK)} file-to-bank mappings")
    for f, (bank, hex_val) in sorted(FILE_TO_BANK.items())[:20]:
        print(f"  {f}: Bank {bank} ({hex_val})")

