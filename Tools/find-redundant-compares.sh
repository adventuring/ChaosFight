#!/bin/bash
# Find redundant cmp/cpx/cpy # 0 operations
# These are redundant when the Z flag is already set by a previous operation

# Operations that set Z flag: lda, and, ora, eor, adc, sbc, asl, lsr, rol, ror, inc, dec, bit, tax, tay, txa, tya

find Source -name "*.s" -type f | while read file; do
    awk '
    BEGIN {
        # Operations that set Z flag
        zflag_ops["lda"] = 1
        zflag_ops["and"] = 1
        zflag_ops["ora"] = 1
        zflag_ops["eor"] = 1
        zflag_ops["adc"] = 1
        zflag_ops["sbc"] = 1
        zflag_ops["asl"] = 1
        zflag_ops["lsr"] = 1
        zflag_ops["rol"] = 1
        zflag_ops["ror"] = 1
        zflag_ops["inc"] = 1
        zflag_ops["dec"] = 1
        zflag_ops["bit"] = 1
        zflag_ops["tax"] = 1
        zflag_ops["tay"] = 1
        zflag_ops["txa"] = 1
        zflag_ops["tya"] = 1
        zflag_ops["tsx"] = 1
        zflag_ops["txs"] = 1
    }
    {
        # Store previous line
        if (prev_line != "") {
            prev_prev_line = prev_line
        }
        prev_line = $0
        prev_line_num = NR
        
        # Check for cmp/cpx/cpy # 0
        if (match($0, /^\s*(cmp|cpx|cpy)\s+#\s*0/)) {
            op = $1
            # Look back at previous lines (skip comments and blank lines)
            found_zflag = 0
            for (i = prev_lines_count; i >= 1 && i > prev_lines_count - 5; i--) {
                line = prev_lines[i]
                # Extract operation (first word after optional label)
                if (match(line, /^\s*[A-Za-z0-9_]*:?\s*([a-z]{3,4})\s/)) {
                    prev_op = tolower(substr(line, RSTART, RLENGTH))
                    gsub(/[^a-z]/, "", prev_op)
                    if (prev_op in zflag_ops) {
                        found_zflag = 1
                        print FILENAME ":" (prev_line_num - (prev_lines_count - i)) ": " line
                        print FILENAME ":" prev_line_num ": " $0 " <- REDUNDANT"
                        print ""
                        break
                    }
                }
            }
        }
        
        # Store last 5 non-comment, non-blank lines
        if (!match($0, /^\s*;;|^\s*$|^\s*\./)) {
            prev_lines[++prev_lines_count] = $0
            if (prev_lines_count > 5) {
                delete prev_lines[prev_lines_count - 5]
            }
        }
    }
    ' "$file"
done
