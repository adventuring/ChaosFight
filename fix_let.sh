#!/bin/bash
# Script to fix LET statement violations in batariBASIC files

# Find all files with violations
files=$(grep -r "^[[:space:]]*temp[1-6][[:space:]]*=[[:space:]][^=]" Source/Routines/ | grep -v "if " | grep -v "for " | cut -d: -f1 | sort | uniq)

for file in $files; do
    echo "Fixing $file"
    # Use sed to replace temp[1-6] = with let temp[1-6] = 
    # But only for lines that start with whitespace and have temp assignment
    sed -i 's/^\([[:space:]]*\)\(temp[1-6][[:space:]]*=[[:space:]]*\)/\1let \2/g' "$file"
done
