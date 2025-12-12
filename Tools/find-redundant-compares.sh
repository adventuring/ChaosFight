#!/bin/bash
# Find redundant cmp/cpx/cpy # 0 instructions
# These are redundant when the Z flag is already set by a previous operation

# Find all cmp/cpx/cpy # 0 with context
grep -rn -B 5 -A 2 "cmp # 0\|cpx # 0\|cpy # 0" Source/ | \
  grep -E "(lda|ldx|ldy|adc|sbc|and|ora|eor|tax|tay|txa|tya|asl|lsr|rol|ror|dec|inc|bit)" -B 1 -A 6 | \
  head -200
