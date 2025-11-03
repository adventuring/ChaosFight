#!/bin/bash
# Script to identify all user variable assignments in .bas files
# Filters out system variables like temp1-6, var0-95, a-z, player0x, etc.

cd "$(dirname "$0")"

# Find all variable assignments in .bas files
# Pattern: variable_name = value (with or without LET)
find Source -name "*.bas" -type f | while read file; do
    # Match lines with assignments: optional "let ", then variable name, then =
    grep -Hn "^[[:space:]]*\(let[[:space:]]\+\)\?[A-Za-z][A-Za-z0-9\[\]]*[[:space:]]*=" "$file" 2>/dev/null | while IFS=: read -r filename line_num rest; do
        # Extract full line content
        content=$(sed -n "${line_num}p" "$filename" 2>/dev/null || echo "$rest")
        
        # Extract variable name (everything before =, removing optional LET)
        varname=$(echo "$content" | sed 's/^[[:space:]]*let[[:space:]]\+//i' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*=.*//' | sed 's/\[.*//')
        
        # Skip if empty
        [ -z "$varname" ] && continue
        
        # Skip system variables
        # Single letter variables (a-z, A-Z) - these are system vars
        if [[ "$varname" =~ ^[a-zA-Z]$ ]]; then
            continue
        fi
        
        # Skip temp1-6
        if [[ "$varname" =~ ^temp[1-6]$ ]]; then
            continue
        fi
        
        # Skip var0-var95
        if [[ "$varname" =~ ^var[0-9]+$ ]]; then
            continue
        fi
        
        # Skip player/missile system variables (lowercase)
        if [[ "$varname" =~ ^(player[01][xy]|missile[01][xy]|ball[xy]|currentpaddle|paddle|player[01]pointer|player[01]color|player[01]height|missile[01]height|missile[01]y|bally|objecty)$ ]]; then
            continue
        fi
        
        # Skip TIA registers (all caps)
        if [[ "$varname" =~ ^(COLUP[0-9A-F]|COLUPF|COLUBK|NUSIZ[0-9A-F]|NUSIZF|RESP[0-9A-F]|RESMP[0-9A-F]|HMOVE|HMM[0-9A-F]|VDEL[0-9A-F]|GRP[0-9A-F]|ENAM[0-9A-F]|ENABL|PF[0-2]|CTRLPF|REFP[0-9A-F]|AUDF[0-9A-F]|AUDC[0-9A-F]|AUDV[0-9A-F])$ ]]; then
            continue
        fi
        
        # Skip other built-in variables
        if [[ "$varname" =~ ^(frame|qtcontroller|rand|score|scorecolor|scorepointers)$ ]]; then
            continue
        fi
        
        # Skip commented lines (rem statements)
        if echo "$content" | grep -qi "^[[:space:]]*rem"; then
            continue
        fi
        
        # Check if it already has LET (case insensitive)
        has_let=""
        if echo "$content" | grep -qi "^[[:space:]]*let[[:space:]]"; then
            has_let="HAS_LET"
        fi
        
        # Output: filename:line:variable_name:has_let
        echo "$filename:$line_num:$varname:$has_let"
    done
done | sort -u | sort -t: -k3

