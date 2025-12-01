# Final Stack Overflow Analysis - $5:fb63

## Current Status
**Stack overflow persists at `$5:fb63` with SP at `$ef` (17 bytes used, 1 byte over 16-byte limit)**

## Call Chain Analysis

### Actual Call Chain (from debugger evidence)
1. **Kernel** → `VblankHandlerTrampoline` (jsr, **2 bytes**)
2. **VblankHandlerTrampoline** → `VblankHandlerDispatcher` (gosub bank11, **4 bytes**)
3. **VblankHandlerDispatcher** → `VblankModeTitleScreen` (on gosub, **4 bytes**)
4. **VblankModeTitleScreen** → `VblankSharedUpdateCharacterAnimations` (goto, **0 bytes**) ✅ FIXED
5. **VblankUpdateSprite_Bank5Dispatch** → `SetPlayerCharacterArtBank5 bank5` (gosub bank5, **4 bytes**)

**Calculated Total**: 2 + 4 + 4 + 0 + 4 = **14 bytes** (should be safe)

**Actual Stack Usage**: **17 bytes** (SP at `$ef`)

**Discrepancy**: **3 bytes unaccounted for**

## Possible Causes

### 1. `on gosub` pushes more than 4 bytes
- May push additional bytes for jump table lookup
- Need to verify actual implementation

### 2. Kernel entry point uses cross-bank call
- If kernel uses `gosub` instead of `jsr`, adds 2 more bytes
- Total would be: 4 + 4 + 4 + 0 + 4 = **16 bytes** (at limit)
- But we're seeing 17 bytes, so still 1 byte over

### 3. Additional stack usage in `SetPlayerCharacterArtBank5`
- May have hidden `pha` instructions or temporary stack usage
- Need to verify all assembly code paths

### 4. Different call path entirely
- May not be going through vblank handlers
- Could be called from a different entry point
- Need to trace actual execution path

## Next Steps

1. **Verify kernel call mechanism**: Check if kernel uses `jsr` or `gosub` for vblank_bB_code
2. **Check `on gosub` implementation**: Verify if it pushes 4 bytes or more
3. **Trace actual execution**: Use debugger to trace back from `$5:fb63` to find actual call chain
4. **Check for hidden stack usage**: Look for `pha` instructions or temporary stack pushes in Bank 5 code

## Files Modified (Attempted Fixes)

1. `Source/Routines/VblankHandlers.bas` - Inlined UpdateCharacterAnimations into shared routine
2. `Source/Routines/AnimationSystem.bas` - Inlined HandleAnimationTransition and SetPlayerAnimation
3. `Source/Routines/CharacterArtBank2/3/4/5.s` - Inlined LocateCharacterArtBankX, removed pha instructions

## Status
⚠️ **Stack overflow still occurring** - Need to identify the 3 missing bytes in call chain

