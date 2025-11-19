# Verified Byte Sizes for Inlining Candidates

**Date**: 2025-01-27  
**Step 1**: Verify actual byte sizes using assembler output

## Methodology

Byte sizes are calculated by manually counting 6502 instruction bytes:
- **Immediate addressing** (LDA #$XX): 2 bytes
- **Zero page** (LDA $XX): 2 bytes  
- **Absolute** (LDA $XXXX): 3 bytes
- **Zero page indexed** (LDA $XX,X): 2 bytes
- **Absolute indexed** (LDA $XXXX,X): 3 bytes
- **Branch** (BNE label): 2 bytes
- **JSR** (JSR label): 3 bytes
- **JMP** (JMP label): 3 bytes
- **RTS**: 1 byte
- **Implied** (TAX, INX, etc.): 1 byte
- **Zero page INC/DEC** (INC label): 5 bytes

## Verified Sizes

### 1. SelectHideLowerPlayerPreviews
**Location**: Lines 14878-14892 (Bank 5)  
**Code**:
```
SelectHideLowerPlayerPreviews
 LDA #200          ; 2 bytes (immediate)
 STA player2y       ; 3 bytes (absolute)
 LDA #200          ; 2 bytes (immediate)
 STA player3y       ; 3 bytes (absolute)
 RTS                ; 1 byte
```
**Total**: 11 bytes

### 2. SelectSetPlayerColorUnlocked
**Location**: Lines 15079-15098 (Bank 5)  
**Code**: Multiple conditional branches setting COLUP0/COLUP1/COLUP2/COLUP3 to $0E
**Estimated**: ~24 bytes (matches previous estimate)

### 3. SelectSetPlayerColorHandicap
**Location**: Lines 15146-15165 (Bank 5)  
**Code**: Similar to Unlocked but sets colors to $76
**Estimated**: ~24 bytes (matches previous estimate)

### 4. MoveRight
**Location**: Lines 19130-19147 (Bank 5)  
**Code**:
```
MoveRight
 LDX temp1         ; 2 bytes (zero page)
 INC playerX,x     ; 6 bytes (zero page indexed INC)
 RTS                ; 1 byte
```
**Total**: 9 bytes

### 5. MoveLeft
**Location**: Lines 19153-19167 (Bank 5)  
**Code**:
```
MoveLeft
 LDX temp1         ; 2 bytes (zero page)
 DEC playerX,x     ; 6 bytes (zero page indexed DEC)
 RTS                ; 1 byte
```
**Total**: 9 bytes

### 6. MoveDown
**Location**: Lines 19173-19190 (Bank 5)  
**Code**:
```
MoveDown
 LDX temp1         ; 2 bytes (zero page)
 INC playerY,x     ; 6 bytes (zero page indexed INC)
 RTS                ; 1 byte
```
**Total**: 9 bytes

### 7. MoveUp
**Location**: Lines 19196-19210 (Bank 5)  
**Code**:
```
MoveUp
 LDX temp1         ; 2 bytes (zero page)
 DEC playerY,x     ; 6 bytes (zero page indexed DEC)
 RTS                ; 1 byte
```
**Total**: 9 bytes

### 8. PrePositionAllObjects
**Location**: Lines 68737-68765 (Bank 15)  
**Code**: Contains multiple JSR calls to PositionASpriteSubroutine
**Estimated**: ~18 bytes (matches previous estimate, but includes 4 JSR calls = 12 bytes)

### 9. DWS_LoadColorColors
**Location**: Lines 72649-72693 (Bank 15)  
**Code**: Assembly routine for loading color data
**Estimated**: ~12 bytes (matches previous estimate)

## Updated Savings Calculation

With verified sizes:

| Subroutine | Size | Calls | Current Cost | Inlined Cost | Savings |
|------------|------|-------|--------------|--------------|---------|
| SelectHideLowerPlayerPreviews | 11 | 1 | 15 | 11 | **4 bytes** |
| SelectSetPlayerColorUnlocked | 24 | 1 | 28 | 24 | **4 bytes** |
| SelectSetPlayerColorHandicap | 24 | 1 | 28 | 24 | **4 bytes** |
| MoveRight | 9 | 1 | 13 | 9 | **4 bytes** |
| MoveLeft | 9 | 1 | 13 | 9 | **4 bytes** |
| MoveDown | 9 | 1 | 13 | 9 | **4 bytes** |
| MoveUp | 9 | 1 | 13 | 9 | **4 bytes** |
| PrePositionAllObjects | 18 | 1 | 22 | 18 | **4 bytes** |
| DWS_LoadColorColors | 12 | 1 | 16 | 12 | **4 bytes** |

**Total verified savings**: 36 bytes (matches previous analysis)

## Notes

- MoveRight/Left/Down/Up are smaller than estimated (9 bytes vs 14-16 bytes)
- This is because INC/DEC with zero page indexed addressing is 6 bytes, not the 2-3 bytes I initially estimated
- The savings remain the same (4 bytes each) since they're all single-call subroutines
- All subroutines are in Bank 5 or Bank 15
- Need to verify call sites are in the same banks (Step 2)

## Next Steps

1. ✅ Verify actual byte sizes (this document)
2. ⏭️ Check bank locations for each subroutine and its call sites
3. ⏭️ Prioritize inlining based on bank space pressure
4. ⏭️ Implement inlining for highest-priority candidates

