# Bankswitching Code Not Being Inserted - Analysis

## Problem Summary
- Binary size: 61184 bytes (0xEF00) instead of expected 65536 bytes (0x10000)
- Missing: 4352 bytes (Bank 15 and Bank 16 bankswitching code)
- Bank 15's bankswitching code is present but 256 bytes early (at 0xEEB6 instead of 0xEFB6)
- Bank 16's bankswitching code is completely missing

## Current State

### Bankswitching Code Locations
- Banks 1-14: Bankswitching code present at correct locations (0x0FB6, 0x1FB6, etc.)
- Bank 15: Bankswitching code at 0xEEB6 (expected 0xEFB6, 256 bytes early)
- Bank 16: Bankswitching code missing (expected 0xFFB6)

### ORG/RORG Generation
✅ **Verified**: ORG and RORG are always set together in all bankswitching code generation:
- Step 0 (statements.c:1358-1359): ORG and RORG paired
- Bank 16 (2600bas.c:353-354 and 361-362): ORG and RORG paired in both branches

### Generated Assembly
The assembly file correctly generates:
- `ORG $EFB6` and `RORG $FFB6` for Bank 15 (line 65870-65871)
- `ORG $FFB6` and `RORG $FFB6` for Bank 16 (line 71935-71936, 71942-71943)
- `include "Source/Common/BankSwitching.s"` statements are present

## Root Cause Analysis

### Issue 1: Bank 15 Bankswitching Code 256 Bytes Early
**Observation**: Bankswitching code is at 0xEEB6 instead of 0xEFB6 (256 bytes = 0x100 early)

**Possible Causes**:
1. **ORG not taking effect**: The `ORG $EFB6` directive may not be advancing the file offset correctly
2. **File offset already past target**: If the file offset is already at 0xEF00 or later when `ORG $EFB6` is set, DASM may not be able to go backwards (would cause "Origin Reverse-indexed" error, but we're not seeing that)
3. **BankSwitching.s ORG override**: BankSwitching.s has its own ORG directives at lines 96 and 116 that may be interfering
4. **Calculation error**: The ORG calculation might be accounting for the scram shadow incorrectly

**Calculation**:
```c
prev_bank_file_offset = (prev_bank - 1) << 12;  // For Bank 15: 0xE000
bank_bscode_file_offset = prev_bank_file_offset + 0x0FE0;  // 0xEFE0
bank_bscode_org = bank_bscode_file_offset - 42;  // 0xEFB6
```

### Issue 2: Bank 16 Bankswitching Code Missing
**Observation**: File ends at 0xEF00, Bank 16's bankswitching code should be at 0xFFB6

**Possible Causes**:
1. **File offset not advancing**: After Bank 15's content, the file offset is at 0xEF00, and Bank 16's bankswitching code ORG ($FFB6) is never reached
2. **Bank 16 content not assembled**: Bank 16's content may not be assembled, so the bankswitching code ORG is never reached
3. **Assembly stops early**: The assembler may be stopping before Bank 16's bankswitching code is processed

## BankSwitching.s Structure

BankSwitching.s has multiple ORG directives:
- Line 9: `.begin_bscode SUBROUTINE` - starts assembling immediately (no ORG)
- Line 85: `RORG bankswitch_hotspot` - sets CPU address only
- Line 96: `ORG ((current_bank * $1000) | $0FF0)` - sets file offset for reset code
- Line 116: `ORG ((current_bank * $1000) | $0FFC)` - sets file offset for reset vectors

**Key Issue**: The `.begin_bscode` section (lines 9-85) assembles at the current file offset when included. If the ORG set before the include isn't taking effect, this section will assemble at the wrong location.

## Next Steps

1. **Verify ORG behavior**: Check if `ORG $EFB6` is actually advancing the file offset when set
2. **Check file offset at ORG time**: Determine what the file offset is when `ORG $EFB6` is set
3. **Investigate BankSwitching.s ORG directives**: The ORG at line 96 may be interfering with the bankswitching code placement
4. **Check Bank 16 assembly**: Verify that Bank 16's content is being assembled and the bankswitching code ORG is being reached

## Files Modified
- `Tools/batariBASIC/statements.c`: Step 0 bankswitching code generation
- `Tools/batariBASIC/2600bas.c`: Bank 16 bankswitching code generation and memory footprint reporting
- `Source/Common/BankSwitching.s`: Bankswitching assembly code

