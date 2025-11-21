# Analysis: `start_bank1` and `game` Label Issues

## Summary

Both `start_bank1` and `game` are showing as unresolved symbols in the build output, preventing successful assembly.

## Issue 1: `start_bank1` - Conditional Definition vs. Universal Reference

### Problem
- `start_bank1` is **conditionally defined** only for Bank 1 (in `Tools/batariBASIC/statements.c` lines 1854-1856 and 2600bas.c lines 392-393)
- `start_bank1` is **unconditionally referenced** in `Tools/batariBASIC/includes/banksw.asm` line 71:
  ```asm
  echo "Change to ", [. - start_bank1]d, " and try again."
  ```
- `banksw.asm` is included in **all banks** via `bankswitch.inc` → `banksw.asm`
- When banks other than Bank 1 are assembled, `start_bank1` is undefined, causing unresolved symbol errors

### Root Cause
The size warning check in `banksw.asm` assumes `start_bank1` exists, but it's only defined for Bank 1.

### Solution Options
1. **Guard the reference** in `banksw.asm`:
   ```asm
   ifconst start_bank1
     echo "Change to ", [. - start_bank1]d, " and try again."
   endif
   ```

2. **Define `start_bank1` for all banks** (set to Bank 1's start address):
   - Define it once globally, or
   - Define it conditionally in each bank's context

3. **Remove the size check** (not recommended - useful for debugging)

## Issue 2: `game` - Label Definition Context

### Problem
- `game` is defined at line 1 of generated assembly (`Tools/batariBASIC/2600bas.c` line 222):
  ```c
  printf("game\n");  // label for start of game
  ```
- It appears **before any ORG/RORG directives**, so it's at address `$0000`
- The symbol table shows: `game  0000 ????` (unresolved)
- No explicit references found in the codebase, but DASM is reporting it as unresolved

### Root Cause
The `game` label is defined before any address space context is established. In DASM, labels defined before ORG/RORG may not resolve correctly if they're referenced in a different address space context.

### Solution Options
1. **Export `game` as an assembly label** explicitly:
   ```asm
   game:
   ```
   Or ensure it's properly defined in the assembly context where it's needed.

2. **Move `game` definition** to after the first ORG/RORG is set (if it needs to be in a specific address space).

3. **Remove `game` if unused** - check if anything actually references it. If not, it may be legacy code.

## Recommended Fixes

### Fix 1: Guard `start_bank1` reference in `banksw.asm`
```asm
if ((. & $1FFF) > ((bankswitch_hotspot & $1FFF) - 1))
  echo "WARNING: size parameter in banksw.asm too small - the program probably will not work."
  ifconst start_bank1
    echo "Change to ", [. - start_bank1]d, " and try again."
  else
    echo "Change size parameter and try again."
  endif
endif
```

### Fix 2: Ensure `game` is properly defined
- Check if `game` is actually referenced anywhere
- If referenced, ensure it's defined in the correct address space context
- If not referenced, consider removing it or marking it as unused

## Files to Modify

1. `Tools/batariBASIC/includes/banksw.asm` - Add conditional check for `start_bank1`
2. `Tools/batariBASIC/2600bas.c` - Review `game` label definition (line 222)
3. Verify no other code references `game` or `start_bank1` in contexts where they're undefined


