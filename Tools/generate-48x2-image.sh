#!/bin/bash
# Generate 48x2_N_image.s files from Art.*.s and Art.*.colors.s files.
#
# Usage: generate-48x2-image.sh <art_file> <colors_file> <output_file> <bitmap_num>

set -e

if [ $# -ne 4 ]; then
    echo "Usage: $0 <art_file> <colors_file> <output_file> <bitmap_num>" >&2
    exit 1
fi

ART_FILE="$1"
COLORS_FILE="$2"
OUTPUT_FILE="$3"
BITMAP_NUM="$4"

if [ ! -f "$ART_FILE" ]; then
    echo "Error: $ART_FILE does not exist" >&2
    exit 1
fi

if [ ! -f "$COLORS_FILE" ]; then
    echo "Error: $COLORS_FILE does not exist" >&2
    exit 1
fi

# Extract window and height from art file
WINDOW=$(grep -E "^bmp_48x2_${BITMAP_NUM}_window\s*=" "$ART_FILE" | sed 's/.*=\s*\([0-9]*\).*/\1/')
HEIGHT=$(grep -E "^bmp_48x2_${BITMAP_NUM}_height\s*=" "$ART_FILE" | sed 's/.*=\s*\([0-9]*\).*/\1/')

if [ -z "$WINDOW" ] || [ -z "$HEIGHT" ]; then
    echo "Error: Could not find window/height constants in $ART_FILE" >&2
    exit 1
fi

# Extract color bytes from colors file
COLOR_BYTES=$(awk "/^bmp_48x2_${BITMAP_NUM}_colors/,/^bmp_48x2_${BITMAP_NUM}_[^c]/ { if (/^bmp_48x2_${BITMAP_NUM}_colors/) next; if (/^bmp_48x2_${BITMAP_NUM}_[^c]/) exit; if (/BYTE/) print }" "$COLORS_FILE" | sed -n 's/.*BYTE[[:space:]]*\([^;]*\).*/\1/p' | tr '\n' ' ')

# Extract PF1, PF2, background
PF1=$(awk "/^bmp_48x2_${BITMAP_NUM}_PF1/,/^bmp_48x2_${BITMAP_NUM}_/ { if (/BYTE/) { print; exit } }" "$COLORS_FILE" | sed -n 's/.*BYTE[[:space:]]*\([^;]*\).*/\1/p')
PF2=$(awk "/^bmp_48x2_${BITMAP_NUM}_PF2/,/^bmp_48x2_${BITMAP_NUM}_/ { if (/BYTE/) { print; exit } }" "$COLORS_FILE" | sed -n 's/.*BYTE[[:space:]]*\([^;]*\).*/\1/p')
BG=$(awk "/^bmp_48x2_${BITMAP_NUM}_background/,/^bmp_48x2_${BITMAP_NUM}_/ { if (/endif/) { getline; if (/BYTE/) { print; exit } } }" "$COLORS_FILE" | sed -n 's/.*BYTE[[:space:]]*\([^;]*\).*/\1/p')

# Default values if not found
PF1=${PF1:-"%00000000"}
PF2=${PF2:-"%00000000"}
BG=${BG:-"\$00"}

# Create output file
{
    echo ""
    echo " ;*** The height of the displayed data..."
    echo "bmp_48x2_${BITMAP_NUM}_window = ${WINDOW}"
    echo ""
    echo " ;*** The height of the bitmap data. This can be larger than "
    echo " ;*** the displayed data height, if you're scrolling or animating "
    echo " ;*** the data..."
    echo "bmp_48x2_${BITMAP_NUM}_height = ${HEIGHT}"
    echo ""
    echo "          if >. != >[.+(bmp_48x2_${BITMAP_NUM}_height)]"
    echo "          align 256"
    echo "          endif"
    echo "          BYTE 0 ; leave this here!"
    echo ""
    echo ""
    echo " ;*** The color of each line in the bitmap, in reverse order..."
    echo "bmp_48x2_${BITMAP_NUM}_colors "
    
    # Format color bytes (10 per line)
    if [ -n "$COLOR_BYTES" ]; then
        echo "$COLOR_BYTES" | tr ' ' '\n' | grep -v '^$' | \
            awk 'BEGIN {count=0} {if (count > 0 && count % 10 == 0) printf "\n"; if (count % 10 == 0) printf "          BYTE "; else printf ", "; printf "%s", $1; count++} END {if (count > 0) printf "\n"}'
    fi
    
    echo ""
    echo "          ifnconst bmp_48x2_${BITMAP_NUM}_PF1"
    echo "bmp_48x2_${BITMAP_NUM}_PF1"
    echo "          endif"
    echo "          BYTE ${PF1}"
    echo "          ifnconst bmp_48x2_${BITMAP_NUM}_PF2"
    echo "bmp_48x2_${BITMAP_NUM}_PF2"
    echo "          endif"
    echo "          BYTE ${PF2}"
    echo "          ifnconst bmp_48x2_${BITMAP_NUM}_background"
    echo "bmp_48x2_${BITMAP_NUM}_background"
    echo "          endif"
    echo "          BYTE ${BG}"
    echo ""
    
    # Extract and format bitmap columns (00-05)
    for col in 0 1 2 3 4 5; do
        col_label=$(printf "bmp_48x2_${BITMAP_NUM}_%02d" $col)
        next_col=$(printf "%02d" $((col + 1)))
        next_label=$(printf "bmp_48x2_${BITMAP_NUM}_%02d" $next_col)
        echo "          if >. != >(* + bmp_48x2_${BITMAP_NUM}_height)"
        echo "          align 256"
        echo "          endif"
        echo ""
        echo ""
        echo "${col_label}"
        
        # Extract bytes for this column (stop at next column or next bmp_48x2 label)
        if [ $col -lt 5 ]; then
            awk "/^${col_label}/,/^${next_label}/ { if (/^${col_label}/) next; if (/^${next_label}/) exit; if (/BYTE/) print }" "$ART_FILE" | \
                sed -n 's/.*BYTE[[:space:]]*\([^;]*\).*/\1/p' | \
                awk 'BEGIN {count=0} {if (count > 0 && count % 5 == 0) printf "\n"; if (count % 5 == 0) printf "          BYTE "; else printf ", "; printf "%s", $1; count++} END {if (count > 0) printf "\n"}'
        else
            awk "/^${col_label}/,/^bmp_48x2_/ { if (/^${col_label}/) next; if (/^bmp_48x2_/ && !/^${col_label}/) exit; if (/BYTE/) print }" "$ART_FILE" | \
                sed -n 's/.*BYTE[[:space:]]*\([^;]*\).*/\1/p' | \
                awk 'BEGIN {count=0} {if (count > 0 && count % 5 == 0) printf "\n"; if (count % 5 == 0) printf "          BYTE "; else printf ", "; printf "%s", $1; count++} END {if (count > 0) printf "\n"}'
        fi
        
        echo ""
        echo ""
    done
} > "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE"

