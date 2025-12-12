#!/bin/bash
# Find redundant store/load patterns:
# - sta n followed by lda n (same variable)
# - lda n followed by sta n (same variable)
# - stx n followed by ldx n (same variable)
# - ldx n followed by stx n (same variable)
# - sty n followed by ldy n (same variable)
# - ldy n followed by sty n (same variable)

find Source/ -name "*.s" -o -name "*.bas" | while read file; do
    # Extract variable names from sta/lda/stx/ldx/sty/ldy instructions
    # Look for patterns where same variable appears in consecutive store/load
    
    awk '
    /^\s*(sta|lda|stx|ldx|sty|ldy)\s+/ {
        # Extract instruction and variable
        match($0, /^\s*(sta|lda|stx|ldx|sty|ldy)\s+([a-zA-Z0-9_\[\]]+)/, arr)
        if (arr[1] != "" && arr[2] != "") {
            instr = arr[1]
            var = arr[2]
            
            # Normalize variable name (remove array indices for comparison)
            gsub(/\[.*\]/, "", var)
            
            # Check for redundant patterns
            if (prev_instr == "sta" && instr == "lda" && prev_var == var) {
                print FILENAME ":" NR-1 ": " prev_line
                print FILENAME ":" NR ": " $0
                print "---"
            }
            if (prev_instr == "lda" && instr == "sta" && prev_var == var) {
                print FILENAME ":" NR-1 ": " prev_line
                print FILENAME ":" NR ": " $0
                print "---"
            }
            if (prev_instr == "stx" && instr == "ldx" && prev_var == var) {
                print FILENAME ":" NR-1 ": " prev_line
                print FILENAME ":" NR ": " $0
                print "---"
            }
            if (prev_instr == "ldx" && instr == "stx" && prev_var == var) {
                print FILENAME ":" NR-1 ": " prev_line
                print FILENAME ":" NR ": " $0
                print "---"
            }
            if (prev_instr == "sty" && instr == "ldy" && prev_var == var) {
                print FILENAME ":" NR-1 ": " prev_line
                print FILENAME ":" NR ": " $0
                print "---"
            }
            if (prev_instr == "ldy" && instr == "sty" && prev_var == var) {
                print FILENAME ":" NR-1 ": " prev_line
                print FILENAME ":" NR ": " $0
                print "---"
            }
            
            prev_instr = instr
            prev_var = var
            prev_line = $0
        }
    }
    ' "$file"
done | head -200
