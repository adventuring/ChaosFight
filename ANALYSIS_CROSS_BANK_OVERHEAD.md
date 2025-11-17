# Cross-Bank gosub Call Overhead Analysis

## Summary

**Total Overhead for Cross-Bank gosub Call:**
- **Code Size**: 30 bytes (call path) + 24 bytes (return path) = **54 bytes total**
- **CPU Cycles**: 38 cycles (call path) + 50 cycles (return path) = **88 cycles total**

## Call Path (gosub bankX FunctionName)

From generated assembly (example: `gosub LoadSongPointer bank1`):

| Instruction | Bytes | Cycles | Purpose |
|------------|-------|--------|---------|
| `sta temp7` | 3 | 3 | Save A register |
| `lda #(((>(ret_point1-1)) & $0F) \| $00)` | 3 | 2 | Encode return address high byte with bank |
| `pha` | 1 | 3 | Push encoded return address high |
| `lda #<(ret_point1-1)` | 2 | 2 | Get return address low byte |
| `pha` | 1 | 3 | Push return address low |
| `lda #>(LoadSongPointer-1)` | 2 | 2 | Get target function high byte |
| `pha` | 1 | 3 | Push target address high |
| `lda #<(LoadSongPointer-1)` | 2 | 2 | Get target function low byte |
| `pha` | 1 | 3 | Push target address low |
| `lda temp7` | 2 | 3 | Restore A register |
| `pha` | 1 | 3 | Push A register |
| `txa` | 1 | 2 | Transfer X to A |
| `pha` | 1 | 3 | Push X register |
| `ldx #1` | 2 | 2 | Load bank number (1-based) |
| `jmp BS_jsr` | 3 | 3 | Jump to bank switch code |
| **BS_jsr (BankSwitching.s:38-43)** | | | |
| `lda bankswitch_hotspot-1,x` | 3 | 4 | Load bank switch value (triggers hardware) |
| `pla` | 1 | 4 | Restore X register |
| `tax` | 1 | 2 | Transfer A to X |
| `pla` | 1 | 4 | Restore A register |
| `rts` | 1 | 6 | Return to target function |
| **CALL PATH TOTAL** | **30** | **38** | |

## Return Path (return from cross-bank function)

From BankSwitching.s BS_return (lines 17-37):

| Instruction | Bytes | Cycles | Purpose |
|------------|-------|--------|---------|
| `pha` | 1 | 3 | Save A register |
| `txa` | 1 | 2 | Transfer X to A |
| `pha` | 1 | 3 | Save X register |
| `tsx` | 1 | 2 | Get stack pointer |
| `lda 4,x` | 2 | 4 | Get encoded return address high byte |
| `tay` | 1 | 2 | Save encoded byte |
| `and #$F0` | 2 | 2 | Extract bank number from high nibble |
| `lsr` | 1 | 2 | Shift right once |
| `lsr` | 1 | 2 | Shift right twice |
| `lsr` | 1 | 2 | Shift right three times |
| `lsr` | 1 | 2 | Shift right four times (bank now in low nibble) |
| `pha` | 1 | 3 | Save bank number temporarily |
| `tya` | 1 | 2 | Get saved encoded byte |
| `and #$0F` | 2 | 2 | Mask low nibble with original address info |
| `ora #$F0` | 2 | 2 | Restore to $Fx format |
| `sta 4,x` | 2 | 4 | Store restored address back to stack |
| `pla` | 1 | 4 | Restore bank number |
| `tax` | 1 | 2 | Bank number (0-F) now in X |
| `inx` | 1 | 2 | Convert to 1-based index |
| **BS_jsr (BankSwitching.s:38-43)** | | | |
| `lda bankswitch_hotspot-1,x` | 3 | 4 | Load bank switch value (triggers hardware) |
| `pla` | 1 | 4 | Restore X register |
| `tax` | 1 | 2 | Transfer A to X |
| `pla` | 1 | 4 | Restore A register |
| `rts` | 1 | 6 | Return to original caller |
| **RETURN PATH TOTAL** | **24** | **50** | |

## Comparison: Same-Bank vs Cross-Bank

### Same-Bank gosub (standard JSR)
- **Code Size**: 3 bytes (`jsr FunctionName`)
- **CPU Cycles**: 6 cycles (JSR) + 6 cycles (RTS) = **12 cycles total**
- **Stack Usage**: 2 bytes (return address only)

### Cross-Bank gosub
- **Code Size**: 54 bytes (30 call + 24 return)
- **CPU Cycles**: 88 cycles (38 call + 50 return)
- **Stack Usage**: 7 bytes (encoded return address, target address, A, X, bank number)

## Overhead Ratio

- **Code Size**: 54 bytes vs 3 bytes = **18x larger**
- **CPU Cycles**: 88 cycles vs 12 cycles = **7.3x slower**
- **Stack Usage**: 7 bytes vs 2 bytes = **3.5x more**

## Implications for Inlining

For small functions that are:
- Only a few lines of code (< 10-15 bytes)
- Called from only 1-2 places
- Simple operations (arithmetic, assignments, single conditionals)

**Inlining is highly beneficial** because:
1. The 54-byte call overhead may exceed the function's code size
2. The 88-cycle overhead is significant on a 1.19 MHz CPU (73.9 microseconds)
3. Eliminates stack pressure (saves 5 bytes per call)
4. Improves code locality and cache behavior

**Example**: A 5-byte function called once would save:
- **49 bytes** of code (54 - 5)
- **83 cycles** of execution time (88 - 5)
- **5 bytes** of stack space

## Notes

- Bank switching hardware access (`lda bankswitch_hotspot-1,x`) triggers the actual ROM bank change
- The encoding scheme stores the bank number in the high nibble of the return address
- All registers (A, X) are preserved across bank boundaries
- The overhead is fixed regardless of function size or complexity

