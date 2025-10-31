# Compiler Errors Fix Plan

## Critical Blockers (Must Fix First)

### 1. Bank 1 Overflow (#302) - **HIGHEST PRIORITY**
**Status:** CRITICAL BLOCKER
**Issue:** Bank 1 exceeded 3.5kiB (3584 bytes = $E00) boundary

**Errors:**
- `jmp skipswapGfxtable` addresses exceed $10000 (likely address space calculation issue)
- `CharacterBankTable` and `AnimationFrameBankOffsets` references exceed boundaries

**Note:** Each bank is **3.5kiB (3584 bytes = $E00)**, not 4kiB, and that's **before overhead**. 
- Bank overhead (bank switching code, vectors, etc.) further reduces available space
- The $10000 error suggests address calculations exceed 16-bit boundaries
- Actual usable space per bank is likely ~3kiB or less after overhead
- Start address is $f800, must end before $fff0 or so (probably sooner)

**Solution:**
1. Move routines from Bank 1 to less used banks (need to verify actual free space)
2. Relocate `CharacterArt.s` tables to a different bank accessible via bank switching
3. Ensure `skipswapGfxtable` label is within Bank 1's 3.5kiB boundary
4. Consider moving less frequently used routines to Bank 2/3
5. Verify batariBASIC bank usage reporting - may be misleading

**Affected Files:**
- `Source/Banks/Bank1.bas` - Too many includes for 3.5kiB bank
- `Source/Routines/CharacterArt.s` - Tables need accessible location
- `Tools/batariBASIC/includes/multisprite_kernel.asm` - Label location

---

### 2. Missing LoadSpecialSprite Function (#296) - **HIGH PRIORITY**
**Status:** COMPILATION BLOCKER
**Issue:** Function referenced but not implemented

**Location:** `Source/Routines/SpriteLoader.bas` lines 46, 49, 52

**Solution:**
Implement function to load special sprites (QuestionMark, CPU, No) from `Source/Data/SpecialSprites.bas`:
- Use temp6 as sprite index selector
- Load appropriate sprite data based on index
- Set player sprite pointers accordingly

**Dependencies:**
- `Source/Data/SpecialSprites.bas` - Contains data tables
- Constants in `Source/Common/Constants.bas`

---

## Syntax Errors (Block Compilation)

### 3. INPT0{7} Bit Field Syntax (#297) - **HIGH PRIORITY**
**Status:** SYNTAX ERROR
**Issue:** Bit field syntax not converting to assembly

**Errors:**
- `INPT0{7}` and `INPT2{7}` causing "Illegal character" errors
- batariBASIC bit field syntax not being processed correctly

**Affected Files:**
- `Source/Routines/TitleSequence.bas` - 8 instances
- `Source/Routines/AuthorPreamble.bas` - 2 instances

**Solution:**
usually indicates being used in improper compound operations

---

### 4. rem Comments with Colons (#298) - **MEDIUM PRIORITY**
**Status:** SYNTAX ERROR  
**Issue:** Colons in rem comments causing assembly parser errors

**Location:** `Source/Routines/LevelData.bas` - Multiple `rem Arena X: NAME` comments

**Solution:**
- Remove colons from rem comments (replace with dash or comma)
- Example: `rem Arena 7: DRAGON TOWER` → `rem Arena 7 - DRAGON TOWER`
- Ensure blank lines before `data`/`playfield` blocks (already fixed in generator)

---

### 5. rem Comments in Assembly Output (#300) - **MEDIUM PRIORITY**
**Status:** SYNTAX ERROR
**Issue:** rem comments from bank files appearing as-is in assembly

**Solution:**
usually indicates improper indentation or rem in a context where remarks are not allowed (e.g. data block)

---

### 6. data Blocks Not Converting (#301) - **MEDIUM PRIORITY**
**Status:** SYNTAX ERROR
**Issue:** `data` statements appearing as literal keywords in assembly

**Affected:**
- `Source/Routines/SpriteLoader.bas` - `data PlayerColorsDark`
- `Source/Data/SpecialSprites.bas` - `data CPUSprite`, `data NoSprite`

**Solution:**
- batariBASIC should convert `data` to `.byte` directives
- Check if these are inside functions/routines where they shouldn't be
- May need manual conversion or fix preprocessing

---

## Data/Value Errors

### 7. Magic Numbers Exceed 8-bit Limits (#299) - **MEDIUM PRIORITY**
**Status:** VALUE ERROR
**Issue:** Values >255 used in 8-bit contexts

**Errors:**
- `ldy #9999` - Should be <$100
- `lda #$682` - Should be <$100

**Solution:**
1. Search codebase for these literal values
2. Replace with proper correct values

---

## Fix Priority Order

1. **Bank 1 Overflow (#302)** - Complete blocker, must fix first
2. **Missing LoadSpecialSprite (#296)** - Functionality blocker
3. **INPT0{7} Syntax (#297)** - Affects controller input
4. **Magic Numbers (#299)** - Compilation error
5. **rem Colons (#298)** - Compilation error  
6. **rem in Assembly (#300)** - Compilation error
7. **data Blocks (#301)** - Compilation error

---

## Implementation Strategy

### Phase 1: Critical Blockers
1. **Bank 1 Overflow (#302):** Analyze Bank 1 contents and identify code to move
2. **Bank 1 Overflow (#302):** Move `CharacterArt.s` tables to appropriate bank location
3. **Missing LoadSpecialSprite (#296):** Implement `LoadSpecialSprite` function

### Phase 2: Syntax Fixes
1. **INPT0{7} Syntax (#297):** Fix improper compound operations with bit field syntax
2. **rem Colons (#298):** Remove/replace colons in rem comments
3. **rem in Assembly (#300):** Fix improper indentation or rem in disallowed contexts
4. **data Blocks (#301):** Fix data block locations/syntax

### Phase 3: Value Fixes
1. **Magic Numbers (#299):** Find and fix magic number issues, replace with proper values
2. Verify all 8-bit operations use valid ranges

---

## Testing Checklist
- [ ] Project compiles without errors
- [ ] All banks within size limits
- [ ] Special sprites load correctly
- [ ] Controller input works (bit field tests)
- [ ] No assembly syntax errors in generated files
- [ ] All data blocks compile correctly

