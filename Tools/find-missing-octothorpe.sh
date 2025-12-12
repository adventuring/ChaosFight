#!/bin/bash
# Find assembly instructions with numbers missing octothorpe (#) prefix
# These are likely bugs where immediate values should be used instead of addresses

# Instructions that support immediate mode
IMMEDIATE_INSTRUCTIONS="lda|ldx|ldy|cmp|cpx|cpy|and|ora|eor|adc|sbc"

# Find all matches
grep -rnE "\b($IMMEDIATE_INSTRUCTIONS)\s+([0-9]+|[$][0-9a-fA-F]+)(\s|$|;|,)" Source/ --include="*.s" | \
while IFS=: read file line_num line; do
    # Skip comments (lines starting with ;; or containing only ;;)
    if echo "$line" | grep -qE '^\s*;;'; then
        continue
    fi
    
    # Skip if already has octothorpe
    echo "$line" | grep -qE "\b($IMMEDIATE_INSTRUCTIONS)\s+#" && continue
    
    # Extract the instruction and operand
    if echo "$line" | grep -qE "\b($IMMEDIATE_INSTRUCTIONS)\s+([0-9]+|[$][0-9a-fA-F]+)"; then
        # Get the operand value
        operand=$(echo "$line" | sed -nE "s/.*\b($IMMEDIATE_INSTRUCTIONS)\s+([0-9]+|[$][0-9a-fA-F]+).*/\2/p")
        
        # Check if it's a 4-digit hex (likely absolute address) - these are probably valid
        if echo "$operand" | grep -qE '^\$[0-9a-fA-F]{4}$'; then
            continue  # Skip 4-digit hex addresses
        fi
        
        # Check if it's followed by a comma (indexed addressing) - these are valid
        if echo "$line" | grep -qE "\b($IMMEDIATE_INSTRUCTIONS)\s+([0-9]+|[$][0-9a-fA-F]+),"; then
            continue  # Skip indexed addressing
        fi
        
        # Everything else is suspicious
        printf "%s:%s: %s\n" "$file" "$line_num" "$line"
    fi
done | sort -u

